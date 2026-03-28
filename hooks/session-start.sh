#!/bin/bash
set -e

# =============================================================================
# session-start.sh - Claude Code SessionStart hook
# =============================================================================
# Fired automatically at the start of every Claude Code session.
# Reads vault state and injects context via userPromptPrefix so the AI
# starts each session with continuity from previous sessions.
#
# Output: JSON object with "userPromptPrefix" key.
# =============================================================================

VAULT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
BRAIN_DIR="$VAULT_DIR/.brain"
STATE_FILE="$BRAIN_DIR/state.json"

# ---------------------------------------------------------------------------
# Obsidian CLI detection
# Obsidian 1.12+ ships an official CLI. When available it provides search
# indexing, task lists, and backlink traversal at near-zero token cost.
# Falls back to direct file reads if the CLI is not registered.
# ---------------------------------------------------------------------------
OBSIDIAN_CLI=""
if command -v obsidian &>/dev/null; then
  # Verify it's the Obsidian app CLI (not some other 'obsidian' binary)
  if obsidian version &>/dev/null 2>&1; then
    OBSIDIAN_CLI="obsidian"
  fi
fi

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Safe JSON string escaping. Uses jq if available, otherwise a basic sed fallback.
json_escape() {
  local input="$1"
  if command -v jq &>/dev/null; then
    printf '%s' "$input" | jq -Rs '.'
  else
    # Minimal escaping: backslashes, double quotes, newlines, tabs
    printf '"%s"' "$(printf '%s' "$input" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e ':a;N;$!ba;s/\n/\\n/g' -e 's/\t/\\t/g')"
  fi
}

# Read a file if it exists, return empty string otherwise.
read_if_exists() {
  if [ -f "$1" ]; then
    cat "$1"
  fi
}

# ---------------------------------------------------------------------------
# Gather context
# ---------------------------------------------------------------------------

context_parts=()

# 1. Last session info from state.json
if [ -f "$STATE_FILE" ]; then
  if command -v jq &>/dev/null; then
    last_session=$(jq -r '.last_session // empty' "$STATE_FILE" 2>/dev/null || true)
    sessions_count=$(jq -r '.sessions_count // 0' "$STATE_FILE" 2>/dev/null || true)
  else
    last_session=$(grep -o '"last_session"[[:space:]]*:[[:space:]]*"[^"]*"' "$STATE_FILE" 2>/dev/null | head -1 | sed 's/.*"last_session"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//' || true)
    sessions_count=$(grep -o '"sessions_count"[[:space:]]*:[[:space:]]*[0-9]*' "$STATE_FILE" 2>/dev/null | head -1 | sed 's/.*:[[:space:]]*//' || true)
  fi
  if [ -n "$last_session" ] && [ "$last_session" != "null" ]; then
    context_parts+=("[State] Last session: $last_session | Total sessions: ${sessions_count:-0}")
  fi
fi

# 2. Most recent 2 session logs
SESSION_LOGS_DIR="$VAULT_DIR/Machine/Session-Logs"
if [ -d "$SESSION_LOGS_DIR" ]; then
  # Get the 2 most recent .md files sorted by name (which is date-based)
  recent_logs=$(ls -1 "$SESSION_LOGS_DIR"/*.md 2>/dev/null | sort -r | head -2)
  if [ -n "$recent_logs" ]; then
    log_summary=""
    while IFS= read -r logfile; do
      fname=$(basename "$logfile")
      # Extract just the summary section (first 15 lines after frontmatter)
      summary=$(sed -n '/^---$/,/^---$/!p' "$logfile" 2>/dev/null | head -15 | tr '\n' ' ' | sed 's/  */ /g' | cut -c1-300)
      if [ -n "$summary" ]; then
        log_summary="${log_summary}  - ${fname}: ${summary}\n"
      fi
    done <<< "$recent_logs"
    if [ -n "$log_summary" ]; then
      context_parts+=("[Recent Sessions]\n${log_summary}")
    fi
  fi
fi

# 3. Context cache
CONTEXT_CACHE="$VAULT_DIR/Machine/Memory/context-cache.md"
if [ -f "$CONTEXT_CACHE" ]; then
  # Strip frontmatter, take first 20 lines for conciseness
  cache_content=$(sed -n '/^---$/,/^---$/!p' "$CONTEXT_CACHE" 2>/dev/null | head -20 | tr '\n' ' ' | sed 's/  */ /g' | cut -c1-500)
  if [ -n "$cache_content" ]; then
    context_parts+=("[Context Cache] $cache_content")
  fi
fi

# 4. Active rules
ACTIVE_RULES="$VAULT_DIR/Machine/Rules/active-rules.md"
if [ -f "$ACTIVE_RULES" ]; then
  # Strip frontmatter, take first 15 lines - just the key rules
  rules_content=$(sed -n '/^---$/,/^---$/!p' "$ACTIVE_RULES" 2>/dev/null | head -15 | tr '\n' ' ' | sed 's/  */ /g' | cut -c1-400)
  if [ -n "$rules_content" ]; then
    context_parts+=("[Active Rules] $rules_content")
  fi
fi

# 5. Today's daily note + incomplete tasks
TODAY=$(date +%Y-%m-%d)
if [ -n "$OBSIDIAN_CLI" ]; then
  # Obsidian CLI path: search today's daily note via index (zero extra tokens for large vaults)
  daily_content=$($OBSIDIAN_CLI search "date:$TODAY" --format json 2>/dev/null | \
    python3 -c "import sys,json; d=json.load(sys.stdin); print(' | '.join(r.get('snippet','') for r in d[:3]))" 2>/dev/null || true)
  # Get incomplete tasks across entire vault
  tasks_content=$($OBSIDIAN_CLI tasks --incomplete --format json 2>/dev/null | \
    python3 -c "import sys,json; d=json.load(sys.stdin); items=d[:5]; print(' | '.join(t.get('text','') for t in items))" 2>/dev/null || true)
  if [ -n "$daily_content" ]; then
    context_parts+=("[Today ($TODAY) via Obsidian CLI] $daily_content")
  fi
  if [ -n "$tasks_content" ]; then
    context_parts+=("[Open Tasks via Obsidian CLI] $tasks_content")
  fi
else
  # Fallback: read daily note file directly
  DAILY_NOTE="$VAULT_DIR/Human/Daily/${TODAY}.md"
  if [ -f "$DAILY_NOTE" ]; then
    daily_content=$(sed -n '/^---$/,/^---$/!p' "$DAILY_NOTE" 2>/dev/null | head -15 | tr '\n' ' ' | sed 's/  */ /g' | cut -c1-400)
    if [ -n "$daily_content" ]; then
      context_parts+=("[Today's Note ($TODAY)] $daily_content")
    fi
  fi
fi

# ---------------------------------------------------------------------------
# Build output
# ---------------------------------------------------------------------------

if [ ${#context_parts[@]} -eq 0 ]; then
  # First run or empty vault - minimal context
  prefix="[AI Brain] First session detected. Vault at: $VAULT_DIR. Follow the Startup Protocol in brain-rules."
else
  prefix="[AI Brain Session Context]\n"
  for part in "${context_parts[@]}"; do
    prefix="${prefix}${part}\n"
  done
  prefix="${prefix}[End Context] -- Follow Startup Protocol. Read full files if you need more detail."
fi

# Output valid JSON
escaped=$(json_escape "$(printf '%b' "$prefix")")
printf '{"userPromptPrefix": %s}\n' "$escaped"
