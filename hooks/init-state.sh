#!/bin/bash
set -e

# =============================================================================
# init-state.sh - Initialize .brain/state.json
# =============================================================================
# Utility script that creates the initial state file for a new Brain vault.
# Safe to run multiple times - will NOT overwrite an existing state.json.
#
# Usage: ./hooks/init-state.sh [vault_path]
# =============================================================================

VAULT_DIR="${1:-${CLAUDE_PROJECT_DIR:-$(pwd)}}"
BRAIN_DIR="$VAULT_DIR/.brain"
STATE_FILE="$BRAIN_DIR/state.json"

# Ensure .brain directory exists
mkdir -p "$BRAIN_DIR"

# Do not overwrite existing state
if [ -f "$STATE_FILE" ]; then
  echo "state.json already exists at $STATE_FILE -- skipping initialization." >&2
  exit 0
fi

NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)

if command -v jq &>/dev/null; then
  # Use jq for guaranteed valid JSON
  jq -n \
    --arg version "1.0.0" \
    --arg installed "$NOW" \
    '{
      brain_version: $version,
      installed_at: $installed,
      last_session: null,
      sessions_count: 0,
      active_agent: null
    }' > "$STATE_FILE"
else
  # Fallback: write JSON directly
  cat > "$STATE_FILE" <<EOF
{
  "brain_version": "1.0.0",
  "installed_at": "$NOW",
  "last_session": null,
  "sessions_count": 0,
  "active_agent": null
}
EOF
fi

echo "Initialized state.json at $STATE_FILE" >&2
