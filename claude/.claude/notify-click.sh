#!/bin/bash
# Claude Code notification click handler: invoked by notify-attention.sh's
# backgrounded alerter call when the user clicks a notification it fired.
# Brings WezTerm to the foreground and switches tmux to the exact
# session/pane that sent the notification, then consumes it so
# jump-to-notified-session.sh (prefix+a) doesn't re-jump to it.
#
# $1: Claude Code session_id, baked into the -execute command at
# notification-creation time in notify-attention.sh.

SESSION_ID="${1:-}"
[ -z "$SESSION_ID" ] && exit 0

STATE_DIR="$HOME/.cache/claude-sessions"
SESSION_FILE="$STATE_DIR/$SESSION_ID"
[ -f "$SESSION_FILE" ] || exit 0

tmux_session=""
tmux_pane=""
# shellcheck disable=SC1090
source "$SESSION_FILE"

command -v tmux >/dev/null 2>&1 || exit 0
[ -n "$tmux_session" ] || exit 0
tmux has-session -t "$tmux_session" 2>/dev/null || exit 0

osascript -e 'tell application "WezTerm" to activate' >/dev/null 2>&1

# The script runs outside tmux (no $TMUX), so switch-client needs an
# explicit client target. Only one tmux client is expected to be attached
# in this setup; if that assumption ever breaks, this picks the first one.
CLIENT=$(tmux list-clients -F '#{client_tty}' 2>/dev/null | head -1)

if [ -n "$tmux_pane" ] && tmux list-panes -a -F '#{pane_id}' 2>/dev/null | grep -qx "$tmux_pane"; then
  if [ -n "$CLIENT" ]; then
    tmux switch-client -c "$CLIENT" -t "$tmux_pane" 2>/dev/null
  fi
  tmux select-pane -t "$tmux_pane" 2>/dev/null
elif [ -n "$CLIENT" ]; then
  tmux switch-client -c "$CLIENT" -t "$tmux_session" 2>/dev/null
fi

# Consume: drop the notified* fields so prefix+a doesn't pick this up again.
grep -v '^notified' "$SESSION_FILE" > "$SESSION_FILE.tmp" 2>/dev/null && mv "$SESSION_FILE.tmp" "$SESSION_FILE"

exit 0
