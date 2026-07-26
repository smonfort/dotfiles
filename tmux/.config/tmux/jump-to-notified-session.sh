#!/bin/bash
# Jump to the tmux session that most recently sent a Claude Code
# "needs your attention" notification (permission prompt / idle wait).
# The session name is recorded by ~/.claude/notify-attention.sh.

SESSION=$(cat ~/.cache/claude-notify/last-session 2>/dev/null)

if [ -n "$SESSION" ] && tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux switch-client -t "$SESSION"
else
  tmux display-message "No Claude Code attention session recorded yet"
fi
