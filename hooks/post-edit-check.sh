#!/bin/bash
set -e

# =============================================================================
# post-edit-check.sh - Claude Code PostToolUse hook (Write|Edit)
# =============================================================================
# Fired after every Write or Edit tool use. Checks if the modified file is in
# Machine/Rules/ or Machine/Memory/ and provides relevant guidance.
#
# This hook reads the tool input from stdin (JSON with tool_input.file_path).
# Must be fast - runs on every file write/edit.
# =============================================================================

# Read the hook input from stdin
input=$(cat)

# Extract the file path from the tool input
if command -v jq &>/dev/null; then
  file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.file // empty' 2>/dev/null || true)
else
  # Fallback: basic extraction
  file_path=$(printf '%s' "$input" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' 2>/dev/null | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//' || true)
  if [ -z "$file_path" ]; then
    file_path=$(printf '%s' "$input" | grep -o '"file"[[:space:]]*:[[:space:]]*"[^"]*"' 2>/dev/null | head -1 | sed 's/.*"file"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//' || true)
  fi
fi

# If we couldn't extract a file path, exit silently
if [ -z "$file_path" ]; then
  exit 0
fi

# Check if the file is in Machine/Rules/ (specifically active-rules.md)
if echo "$file_path" | grep -q "Machine/Rules/active-rules.md"; then
  cat <<'ENDJSON'
{"userPromptSuffix": "NOTE: You just modified active-rules.md. Consider running /vault-align to ensure all agent configs are in sync with the updated rules."}
ENDJSON
  exit 0
fi

# Check if any file in Machine/Rules/ was modified
if echo "$file_path" | grep -q "Machine/Rules/"; then
  cat <<'ENDJSON'
{"userPromptSuffix": "NOTE: You modified a file in Machine/Rules/. If this affects active rules, update active-rules.md and consider running /vault-align."}
ENDJSON
  exit 0
fi

# Check if a memory file was modified - no action needed, just acknowledge
if echo "$file_path" | grep -q "Machine/Memory/"; then
  # Memory updates are normal and expected. No output needed.
  exit 0
fi

# No relevant file matched - exit silently (no output = no injection)
exit 0
