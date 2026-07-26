#!/bin/bash
# Claude Code "Notification" hook: fires on permission prompts and idle-wait.
# Sends a macOS notification and records the triggering tmux session so the
# `prefix + a` binding in dotfiles/tmux/.tmux.conf can jump back to it.
# Exit codes are ignored by Claude Code for this hook, but every step still
# degrades gracefully to avoid noisy "hook error" notices.

INPUT=$(cat)

MESSAGE=""
if command -v jq >/dev/null 2>&1; then
  MESSAGE=$(printf '%s' "$INPUT" | jq -r '.message // empty' 2>/dev/null)
fi

SESSION=""
if [ -n "${TMUX:-}" ] && command -v tmux >/dev/null 2>&1; then
  SESSION=$(tmux display-message -p '#S' 2>/dev/null)
fi

if [ -n "$SESSION" ]; then
  STATE_DIR="$HOME/.cache/claude-notify"
  mkdir -p "$STATE_DIR" 2>/dev/null
  printf '%s' "$SESSION" > "$STATE_DIR/last-session" 2>/dev/null
fi

TITLE="Claude Code"
[ -n "$SESSION" ] && TITLE="Claude Code — $SESSION"
BODY="${MESSAGE:-needs your attention}"

escape() { printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'; }
SAFE_TITLE=$(escape "$TITLE")
SAFE_BODY=$(escape "$BODY")

osascript -e "display notification \"$SAFE_BODY\" with title \"$SAFE_TITLE\"" >/dev/null 2>&1
exit 0
