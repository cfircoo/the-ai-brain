#!/bin/bash
# =============================================================================
# Generate all enabled agent configs from brain.yaml
# =============================================================================
# Usage: generate-all.sh [vault_path] [brain_project_path]
#   vault_path         - Path to the vault (default: current directory)
#   brain_project_path - Path to the-ai-brain project (default: script's parent dir)
#
# Reads brain.yaml to determine which agents are enabled and runs only those
# generators. Reports what was generated.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VAULT_PATH="${1:-.}"
BRAIN_PATH="${2:-$(dirname "$SCRIPT_DIR")}"

# Resolve to absolute paths
VAULT_PATH="$(cd "$VAULT_PATH" && pwd)"

source "$SCRIPT_DIR/lib.sh"

BRAIN_YAML="$BRAIN_PATH/brain.yaml"

if [[ ! -f "$BRAIN_YAML" ]]; then
  msg err "brain.yaml not found at $BRAIN_YAML"
  exit 1
fi

msg info "Generating agent configs from brain.yaml..."
msg info "Vault: $VAULT_PATH"
msg info "Brain: $BRAIN_PATH"
echo ""

generated=0
skipped=0

# ─── Claude Code ─────────────────────────────────────────────────────────────
if agent_enabled "claude_code" "$BRAIN_YAML"; then
  "$SCRIPT_DIR/generate-claude.sh" "$VAULT_PATH" "$BRAIN_PATH"
  generated=$((generated + 1))
else
  msg info "Skipping Claude Code (disabled in brain.yaml)"
  skipped=$((skipped + 1))
fi

# ─── Cursor ──────────────────────────────────────────────────────────────────
if agent_enabled "cursor" "$BRAIN_YAML"; then
  "$SCRIPT_DIR/generate-cursor.sh" "$VAULT_PATH" "$BRAIN_PATH"
  generated=$((generated + 1))
else
  msg info "Skipping Cursor (disabled in brain.yaml)"
  skipped=$((skipped + 1))
fi

# ─── Gemini CLI ──────────────────────────────────────────────────────────────
if agent_enabled "gemini_cli" "$BRAIN_YAML"; then
  "$SCRIPT_DIR/generate-gemini.sh" "$VAULT_PATH" "$BRAIN_PATH"
  generated=$((generated + 1))
else
  msg info "Skipping Gemini CLI (disabled in brain.yaml)"
  skipped=$((skipped + 1))
fi

# ─── Codex ───────────────────────────────────────────────────────────────────
if agent_enabled "codex" "$BRAIN_YAML"; then
  "$SCRIPT_DIR/generate-codex.sh" "$VAULT_PATH" "$BRAIN_PATH"
  generated=$((generated + 1))
else
  msg info "Skipping Codex (disabled in brain.yaml)"
  skipped=$((skipped + 1))
fi

echo ""
msg ok "Done. Generated: $generated, Skipped: $skipped"
