#!/bin/bash
set -e

# =============================================================================
# post-session.sh - Claude Code Stop hook
# =============================================================================
# Fired when Claude Code is about to stop. Reminds the AI to write a session
# log and updates .brain/state.json with the current timestamp.
#
# Output: JSON object with "stopReason" suffix content.
# =============================================================================

VAULT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
BRAIN_DIR="$VAULT_DIR/.brain"
STATE_FILE="$BRAIN_DIR/state.json"

# ---------------------------------------------------------------------------
# Update state.json
# ---------------------------------------------------------------------------

# Ensure .brain directory exists
mkdir -p "$BRAIN_DIR"

NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)

if [ -f "$STATE_FILE" ]; then
  if command -v jq &>/dev/null; then
    # Increment sessions_count and update last_session
    tmp=$(mktemp)
    jq --arg now "$NOW" '
      .last_session = $now |
      .sessions_count = ((.sessions_count // 0) + 1)
    ' "$STATE_FILE" > "$tmp" && mv "$tmp" "$STATE_FILE"
  else
    # Fallback: simple sed-based update
    sed -i "s/\"last_session\"[[:space:]]*:[[:space:]]*[^,}]*/\"last_session\": \"$NOW\"/" "$STATE_FILE" 2>/dev/null || true
    # Increment sessions_count with basic arithmetic
    current_count=$(grep -o '"sessions_count"[[:space:]]*:[[:space:]]*[0-9]*' "$STATE_FILE" 2>/dev/null | grep -o '[0-9]*$' || echo "0")
    new_count=$((current_count + 1))
    sed -i "s/\"sessions_count\"[[:space:]]*:[[:space:]]*[0-9]*/\"sessions_count\": $new_count/" "$STATE_FILE" 2>/dev/null || true
  fi
else
  # Create initial state file with current session info
  cat > "$STATE_FILE" <<EOF
{
  "brain_version": "1.0.0",
  "installed_at": "$NOW",
  "last_session": "$NOW",
  "sessions_count": 1,
  "active_agent": "claude_code"
}
EOF
fi

# ---------------------------------------------------------------------------
# Output reminder for the AI
# ---------------------------------------------------------------------------

SESSION_LOGS_DIR="$VAULT_DIR/Machine/Session-Logs"
TIMESTAMP=$(date +%Y-%m-%d-%H%M)

cat <<ENDJSON
{"userPromptSuffix": "REMINDER: Before ending this session, please write a session log to Machine/Session-Logs/${TIMESTAMP}.md following the Session End Protocol. Include: summary, decisions made, files modified, and next steps. Use the template at Machine/Templates/session-log.md if available."}
ENDJSON
