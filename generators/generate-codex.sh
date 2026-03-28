#!/bin/bash
# =============================================================================
# Generate AGENTS.md from brain.yaml and templates
# =============================================================================
# Usage: generate-codex.sh [vault_path] [brain_project_path]
#   vault_path         - Path to the vault (default: current directory)
#   brain_project_path - Path to the-ai-brain project (default: script's parent dir)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VAULT_PATH="${1:-.}"
BRAIN_PATH="${2:-$(dirname "$SCRIPT_DIR")}"

VAULT_PATH="$(cd "$VAULT_PATH" && pwd)"

source "$SCRIPT_DIR/lib.sh"

# Validate required files
BRAIN_YAML="$BRAIN_PATH/brain.yaml"
TEMPLATE="$SCRIPT_DIR/templates/codex.md.tmpl"
RULES_FILE="$BRAIN_PATH/core/brain-rules.md"

if [[ ! -f "$BRAIN_YAML" ]]; then
  msg err "brain.yaml not found at $BRAIN_YAML"
  exit 1
fi

if [[ ! -f "$TEMPLATE" ]]; then
  msg err "Template not found at $TEMPLATE"
  exit 1
fi

if [[ ! -f "$RULES_FILE" ]]; then
  msg warn "brain-rules.md not found at $RULES_FILE -- generating without brain rules"
  BRAIN_RULES_CONTENT=""
else
  BRAIN_RULES_CONTENT=$(<"$RULES_FILE")
fi

# Resolve variables from brain.yaml
resolve_vars "$BRAIN_YAML"

# Render template
OUTPUT=$(render_template "$TEMPLATE" "$BRAIN_RULES_CONTENT")

# Write output
OUTPUT_FILE="$VAULT_PATH/AGENTS.md"
echo "$OUTPUT" > "$OUTPUT_FILE"

msg ok "Generated $OUTPUT_FILE"
