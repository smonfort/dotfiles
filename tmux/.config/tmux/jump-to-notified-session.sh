#!/bin/bash
# Jump to the tmux pane that most recently sent a Claude Code
# "needs your attention" notification (permission prompt / idle wait / done).
# Recorded by ~/.claude/notify-attention.sh as two lines: session, pane id.

STATE_FILE="$HOME/.cache/claude-notify/last-target"
SESSION=$(sed -n '1p' "$STATE_FILE" 2>/dev/null)
PANE_ID=$(sed -n '2p' "$STATE_FILE" 2>/dev/null)

if [ -n "$PANE_ID" ] && tmux list-panes -a -F '#{pane_id}' 2>/dev/null | grep -qx "$PANE_ID"; then
  # switch-client resolves the pane's session and window automatically;
  # select-pane is just a safety net for multi-pane windows.
  tmux switch-client -t "$PANE_ID"
  tmux select-pane -t "$PANE_ID" 2>/dev/null
elif [ -n "$SESSION" ] && tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux switch-client -t "$SESSION"
else
  tmux display-message "No Claude Code attention session recorded yet"
fi
