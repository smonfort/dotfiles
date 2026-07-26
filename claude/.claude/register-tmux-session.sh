#!/bin/bash
# Claude Code "SessionStart" hook: records which tmux session/window this
# Claude session is running in, so the `prefix + q` binding in
# dotfiles/tmux/.tmux.conf can jump straight back to it.

INPUT=$(cat)
SESSION_ID=""
command -v jq >/dev/null 2>&1 && SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)

[ -z "$SESSION_ID" ] && exit 0
[ -z "${TMUX:-}" ] && exit 0

STATE_DIR="$HOME/.cache/claude-sessions"
mkdir -p "$STATE_DIR" 2>/dev/null

IFS=$'\t' read -r TMUX_SESSION TMUX_WINDOW WINDOW_NAME CWD <<EOF
$(tmux display-message -p -t "${TMUX_PANE:-}" $'#{session_name}\t#{window_index}\t#{window_name}\t#{pane_current_path}' 2>/dev/null)
EOF

[ -z "$TMUX_SESSION" ] && exit 0

{
  echo "tmux_session=$TMUX_SESSION"
  echo "tmux_window=$TMUX_WINDOW"
  echo "window_name=$WINDOW_NAME"
  echo "cwd=$CWD"
  echo "started=$(date -Iseconds)"
} > "$STATE_DIR/$SESSION_ID"

exit 0
