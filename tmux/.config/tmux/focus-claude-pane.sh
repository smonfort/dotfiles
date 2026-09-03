#!/bin/bash
# Sourceable helper: bring WezTerm to the foreground and switch tmux to a
# given pane. Called from outside tmux (vicinae), so $TMUX is never set.
# Landing on the pane auto-acks any pending notification via the tmux hooks
# in .tmux.conf, so callers don't need to do anything else.

focus_claude_pane() {
  local pane_id="$1"
  [ -n "$pane_id" ] || return 0
  # Same bare-PATH issue as claude-notifications-common.sh.
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH"
  command -v tmux >/dev/null 2>&1 || return 0
  tmux list-panes -a -F '#{pane_id}' 2>/dev/null | grep -qx "$pane_id" || return 0

  osascript -e 'tell application "WezTerm" to activate' >/dev/null 2>&1

  # switch-client needs an explicit client target. Only one tmux client is
  # expected attached in this setup; if that assumption ever breaks, this
  # picks the first one.
  local client
  client=$(tmux list-clients -F '#{client_tty}' 2>/dev/null | head -1)
  [ -n "$client" ] && tmux switch-client -c "$client" -t "$pane_id" 2>/dev/null
  tmux select-pane -t "$pane_id" 2>/dev/null
}
