#!/bin/bash
# Jump to the tmux pane whose Claude Code session most recently sent a
# "needs your attention" notification (permission prompt / idle wait / done).
# Shares row-building/consume logic with claude-notifications-fzf.sh
# (prefix+z, which lists every pending notification instead of only
# jumping to the most recent one).
# Jumping consumes the notification: it won't be jumped to again until a new
# one arrives.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./claude-notifications-common.sh
source "$DIR/claude-notifications-common.sh"

top=$(claude_notification_rows | head -n 1)

if [ -z "$top" ]; then
  tmux display-message "No pending Claude Code notifications"
  exit 0
fi

claude_notification_consume "$(cut -f3 <<< "$top")" "$(cut -f2 <<< "$top")"
