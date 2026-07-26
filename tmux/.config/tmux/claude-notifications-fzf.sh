#!/bin/bash
# Fuzzy-pick among Claude Code sessions with an unacknowledged notification
# (permission prompt / idle wait / done) and jump straight to that session's
# tmux window. Picking an entry consumes its notification, same as
# jump-to-notified-session.sh (prefix+a, which jumps straight to the most
# recent one instead of listing them), so it won't show up again until a
# new one arrives.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./claude-notifications-common.sh
source "$DIR/claude-notifications-common.sh"

rows=$(claude_notification_rows)

if [ -z "$rows" ]; then
  tmux display-message "No pending Claude Code notifications"
  exit 0
fi

selection=$(printf '%s\n' "$rows" \
  | fzf-tmux -p --reverse --no-info --border-label ' 🔔 Claude notifications ' --delimiter=$'\t' --with-nth=4)

[ -z "$selection" ] && exit 0

claude_notification_consume "$(cut -f3 <<< "$selection")" "$(cut -f2 <<< "$selection")"
