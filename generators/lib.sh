#!/bin/bash
# =============================================================================
# The AI Brain - Generator Library
# =============================================================================
# Shared functions used by all generator scripts.
# Source this file: source "$(dirname "$0")/lib.sh"
# =============================================================================

# Awk helper: extract a clean YAML scalar value from a raw line value.
# Handles: quoted strings (strips quotes, ignores inline comments),
#          unquoted values (strips inline comments), and booleans.
# Embedded in yaml_get awk scripts via this shared function block.
_AWK_CLEAN_VAL='
function clean_val(v) {
  # Strip leading/trailing whitespace
  gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
  # If value is double-quoted, extract content between first pair of double quotes
  if (v ~ /^"/) {
    sub(/^"/, "", v)
    sub(/".*/, "", v)
    return v
  }
  # If value is single-quoted, extract content between first pair of single quotes
  if (v ~ /^'"'"'/) {
    sub(/^'"'"'/, "", v)
    sub(/'"'"'.*/, "", v)
    return v
  }
  # Unquoted: strip inline comment (space + #)
  sub(/[[:space:]]+#.*/, "", v)
  # Strip trailing whitespace again
  gsub(/[[:space:]]+$/, "", v)
  return v
}
'

# Read a value from brain.yaml.
# Uses yq if available, falls back to grep/awk.
# Usage: yaml_get "owner.name" "$BRAIN_YAML"
yaml_get() {
  local key_path="$1"
  local yaml_file="$2"

  if command -v yq &>/dev/null; then
    yq -r ".${key_path} // \"\"" "$yaml_file" 2>/dev/null
    return
  fi

  # Fallback: parse simple key-value pairs with grep/awk.
  # Supports dotted paths up to 3 levels (e.g. "vault.structure.human_dir").
  # Does NOT support arrays or deeply nested structures.
  local section key
  if [[ "$key_path" == *.* ]]; then
    section="${key_path%%.*}"
    key="${key_path#*.}"
    # Handle two-level dotted keys like vault.structure.human_dir
    if [[ "$key" == *.* ]]; then
      local subsection="${key%%.*}"
      key="${key#*.}"
      awk -v sect="$section" -v subsect="$subsection" -v k="$key" \
        "$_AWK_CLEAN_VAL"'
        /^[a-z]/ { current_section = $0; sub(/:.*/, "", current_section) }
        /^  [a-z]/ { current_sub = $0; gsub(/^  /, "", current_sub); sub(/:.*/, "", current_sub) }
        current_section == sect && current_sub == subsect {
          pat = "^    " k ":"
          if ($0 ~ pat) {
            val = $0
            sub(/^[^:]+:[[:space:]]*/, "", val)
            print clean_val(val)
            exit
          }
        }
      ' "$yaml_file"
    else
      awk -v sect="$section" -v k="$key" \
        "$_AWK_CLEAN_VAL"'
        /^[a-z]/ { current_section = $0; sub(/:.*/, "", current_section) }
        current_section == sect {
          pat = "^  " k ":"
          if ($0 ~ pat) {
            val = $0
            sub(/^[^:]+:[[:space:]]*/, "", val)
            print clean_val(val)
            exit
          }
        }
      ' "$yaml_file"
    fi
  else
    awk -v k="$key_path" \
      "$_AWK_CLEAN_VAL"'
      /^[a-z]/ && $0 ~ "^" k ":" {
        val = $0
        sub(/^[^:]+:[[:space:]]*/, "", val)
        print clean_val(val)
        exit
      }
    ' "$yaml_file"
  fi
}

# Check if an agent is enabled in brain.yaml.
# Usage: agent_enabled "claude_code" "$BRAIN_YAML"
agent_enabled() {
  local agent="$1"
  local yaml_file="$2"
  local val

  if command -v yq &>/dev/null; then
    val=$(yq -r ".agents.${agent}.enabled // false" "$yaml_file" 2>/dev/null)
  else
    val=$(awk -v agent="$agent" '
      /^agents:/ { in_agents=1; next }
      in_agents && /^[a-z]/ { in_agents=0 }
      in_agents && $0 ~ "^  " agent ":" { in_target=1; next }
      in_agents && in_target && /^  [a-z]/ { in_target=0 }
      in_target && /enabled:/ {
        val = $0; sub(/.*enabled:[[:space:]]*/, "", val)
        print val; exit
      }
    ' "$yaml_file")
  fi

  [[ "$val" == "true" ]]
}

# Build format rules string from brain.yaml preferences.
# Usage: build_format_rules "$BRAIN_YAML"
build_format_rules() {
  local yaml_file="$1"
  local format wikilinks frontmatter date_format
  local rules=""

  format=$(yaml_get "preferences.format" "$yaml_file")
  wikilinks=$(yaml_get "preferences.wikilinks" "$yaml_file")
  frontmatter=$(yaml_get "preferences.frontmatter" "$yaml_file")
  date_format=$(yaml_get "preferences.date_format" "$yaml_file")

  if [[ "$format" == "obsidian" ]]; then
    rules+="- This vault uses Obsidian-compatible markdown."$'\n'
  else
    rules+="- This vault uses plain markdown."$'\n'
  fi

  if [[ "$wikilinks" == "true" ]]; then
    rules+="- Use [[wikilinks]] for internal references."$'\n'
  else
    rules+="- Use standard markdown links for internal references."$'\n'
  fi

  if [[ "$frontmatter" == "true" ]]; then
    rules+="- Include YAML frontmatter on every new file."$'\n'
  fi

  if [[ -n "$date_format" ]]; then
    rules+="- Date format: ${date_format}"$'\n'
  fi

  # Remove trailing newline
  printf '%s' "$rules"
}

# Resolve all standard template variables from brain.yaml.
# Sets global variables: BRAIN_NAME, OWNER_NAME, OWNER_ROLE, etc.
# Usage: resolve_vars "$BRAIN_YAML"
resolve_vars() {
  local yaml_file="$1"

  BRAIN_NAME=$(yaml_get "brain.name" "$yaml_file")
  OWNER_NAME=$(yaml_get "owner.name" "$yaml_file")
  OWNER_ROLE=$(yaml_get "owner.role" "$yaml_file")
  HUMAN_DIR=$(yaml_get "vault.structure.human_dir" "$yaml_file")
  MACHINE_DIR=$(yaml_get "vault.structure.machine_dir" "$yaml_file")
  DAILY_DIR=$(yaml_get "vault.structure.daily_dir" "$yaml_file")
  PROJECTS_DIR=$(yaml_get "vault.structure.projects_dir" "$yaml_file")
  ARCHIVE_DIR=$(yaml_get "vault.structure.archive_dir" "$yaml_file")
  SESSION_LOGS_DIR=$(yaml_get "vault.structure.session_logs_dir" "$yaml_file")
  MEMORY_DIR=$(yaml_get "vault.structure.memory_dir" "$yaml_file")
  RULES_DIR=$(yaml_get "vault.structure.rules_dir" "$yaml_file")
  TEMPLATES_DIR=$(yaml_get "vault.structure.templates_dir" "$yaml_file")
  GENERATED_DATE=$(date +"%Y-%m-%d %H:%M:%S")

  # Defaults
  BRAIN_NAME="${BRAIN_NAME:-My AI Brain}"
  OWNER_NAME="${OWNER_NAME:-Owner}"
  OWNER_ROLE="${OWNER_ROLE:-User}"
  HUMAN_DIR="${HUMAN_DIR:-Human}"
  MACHINE_DIR="${MACHINE_DIR:-Machine}"
  DAILY_DIR="${DAILY_DIR:-Human/Daily}"
  PROJECTS_DIR="${PROJECTS_DIR:-Human/Projects}"
  ARCHIVE_DIR="${ARCHIVE_DIR:-Human/Archive}"
  SESSION_LOGS_DIR="${SESSION_LOGS_DIR:-Machine/Session-Logs}"
  MEMORY_DIR="${MEMORY_DIR:-Machine/Memory}"
  RULES_DIR="${RULES_DIR:-Machine/Rules}"
  TEMPLATES_DIR="${TEMPLATES_DIR:-Machine/Templates}"

  FORMAT_RULES=$(build_format_rules "$yaml_file")
}

# Perform placeholder substitution on a template.
# Reads the template, replaces {{PLACEHOLDER}} with variable values.
# Usage: render_template "$TEMPLATE_FILE" "$BRAIN_RULES_CONTENT"
render_template() {
  local template_file="$1"
  local brain_rules="$2"
  local output

  output=$(<"$template_file")

  # Simple placeholders (single-line values)
  output="${output//\{\{BRAIN_NAME\}\}/$BRAIN_NAME}"
  output="${output//\{\{OWNER_NAME\}\}/$OWNER_NAME}"
  output="${output//\{\{OWNER_ROLE\}\}/$OWNER_ROLE}"
  output="${output//\{\{HUMAN_DIR\}\}/$HUMAN_DIR}"
  output="${output//\{\{MACHINE_DIR\}\}/$MACHINE_DIR}"
  output="${output//\{\{DAILY_DIR\}\}/$DAILY_DIR}"
  output="${output//\{\{PROJECTS_DIR\}\}/$PROJECTS_DIR}"
  output="${output//\{\{ARCHIVE_DIR\}\}/$ARCHIVE_DIR}"
  output="${output//\{\{SESSION_LOGS_DIR\}\}/$SESSION_LOGS_DIR}"
  output="${output//\{\{MEMORY_DIR\}\}/$MEMORY_DIR}"
  output="${output//\{\{RULES_DIR\}\}/$RULES_DIR}"
  output="${output//\{\{TEMPLATES_DIR\}\}/$TEMPLATES_DIR}"
  output="${output//\{\{GENERATED_DATE\}\}/$GENERATED_DATE}"

  # Multi-line placeholders: use awk to handle newlines in replacements
  # For FORMAT_RULES and BRAIN_RULES, we use a temp-file approach
  local tmpfile
  tmpfile=$(mktemp)

  echo "$output" > "$tmpfile"

  # Replace {{FORMAT_RULES}} -- write format rules to a temp file and use awk
  local fmt_tmp
  fmt_tmp=$(mktemp)
  printf '%s' "$FORMAT_RULES" > "$fmt_tmp"

  awk -v placeholder="{{FORMAT_RULES}}" -v replfile="$fmt_tmp" '
    $0 == placeholder || index($0, placeholder) > 0 {
      while ((getline line < replfile) > 0) print line
      close(replfile)
      next
    }
    { print }
  ' "$tmpfile" > "${tmpfile}.2" && mv "${tmpfile}.2" "$tmpfile"

  # Replace {{BRAIN_RULES}}
  local rules_tmp
  rules_tmp=$(mktemp)
  printf '%s' "$brain_rules" > "$rules_tmp"

  awk -v placeholder="{{BRAIN_RULES}}" -v replfile="$rules_tmp" '
    $0 == placeholder || index($0, placeholder) > 0 {
      while ((getline line < replfile) > 0) print line
      close(replfile)
      next
    }
    { print }
  ' "$tmpfile" > "${tmpfile}.2" && mv "${tmpfile}.2" "$tmpfile"

  cat "$tmpfile"
  rm -f "$tmpfile" "$fmt_tmp" "$rules_tmp"
}

# Print a colored status message.
# Usage: msg "info" "Something happened"
msg() {
  local level="$1"
  local text="$2"
  case "$level" in
    ok)    echo -e "\033[32m[OK]\033[0m $text" ;;
    info)  echo -e "\033[34m[INFO]\033[0m $text" ;;
    warn)  echo -e "\033[33m[WARN]\033[0m $text" ;;
    err)   echo -e "\033[31m[ERR]\033[0m $text" >&2 ;;
  esac
}
