#!/bin/bash
# Jump to the tmux pane whose Claude Code session most recently sent a
# "needs your attention" notification (permission prompt / idle wait / done).
# Notification state lives in the same per-session registry used by
# switch-claude-window-fzf.sh (~/.cache/claude-sessions/, populated by
# ~/.claude/register-tmux-session.sh and ~/.claude/notify-attention.sh).
# Jumping consumes the notification: it won't be jumped to again until a new
# one arrives.

STATE_DIR="$HOME/.cache/claude-sessions"
if [ ! -d "$STATE_DIR" ]; then
  tmux display-message "No pending Claude Code notifications"
  exit 0
fi

BEST_FILE=""
BEST_AT=-1
BEST_PANE=""
BEST_SESSION=""

for f in "$STATE_DIR"/*; do
  [ -f "$f" ] || continue
  tmux_session=""
  tmux_pane=""
  notified=0
  notified_at=0
  # shellcheck disable=SC1090
  source "$f"

  if ! tmux has-session -t "$tmux_session" 2>/dev/null; then
    rm -f "$f" # stale entry, session gone
    continue
  fi

  if [ "$notified" = "1" ] && [ "$notified_at" -gt "$BEST_AT" ] 2>/dev/null; then
    BEST_AT="$notified_at"
    BEST_FILE="$f"
    BEST_PANE="$tmux_pane"
    BEST_SESSION="$tmux_session"
  fi
done

if [ -z "$BEST_FILE" ]; then
  tmux display-message "No pending Claude Code notifications"
  exit 0
fi

if [ -n "$BEST_PANE" ] && tmux list-panes -a -F '#{pane_id}' 2>/dev/null | grep -qx "$BEST_PANE"; then
  # switch-client resolves the pane's session and window automatically;
  # select-pane is just a safety net for multi-pane windows.
  tmux switch-client -t "$BEST_PANE"
  tmux select-pane -t "$BEST_PANE" 2>/dev/null
elif [ -n "$BEST_SESSION" ] && tmux has-session -t "$BEST_SESSION" 2>/dev/null; then
  tmux switch-client -t "$BEST_SESSION"
fi

# Consume: drop the notified* fields so this session isn't picked again
# until a new notification arrives.
grep -v '^notified' "$BEST_FILE" > "$BEST_FILE.tmp" 2>/dev/null && mv "$BEST_FILE.tmp" "$BEST_FILE"
