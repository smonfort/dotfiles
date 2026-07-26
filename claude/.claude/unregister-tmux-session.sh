#!/bin/bash
# Claude Code "SessionEnd" hook: cleans up the registration made by
# register-tmux-session.sh when this Claude session ends.

INPUT=$(cat)
SESSION_ID=""
command -v jq >/dev/null 2>&1 && SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)

[ -n "$SESSION_ID" ] && rm -f "$HOME/.cache/claude-sessions/$SESSION_ID"
exit 0
