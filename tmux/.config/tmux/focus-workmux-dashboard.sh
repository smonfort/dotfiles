#!/bin/bash
# Called from outside tmux (Hammerspoon), so $TMUX is never set.

focus_workmux_dashboard() {
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH"
  command -v tmux >/dev/null 2>&1 || return 0

  osascript -e 'tell application "WezTerm" to activate' >/dev/null 2>&1

  local client
  client=$(tmux list-clients -F '#{client_tty}' 2>/dev/null | head -1)
  [ -n "$client" ] || return 0
  tmux display-popup -c "$client" -E -w 100% -h 100% -T " workmux dashboard " "workmux dashboard" 2>/dev/null
}
