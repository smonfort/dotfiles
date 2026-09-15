#!/bin/bash
# Opens the sesh picker in a tmux popup. Used by "prefix + s" and, from
# outside tmux, by the hyperkey (switch_tmux_session.lua) — same client
# lookup trick as focus-workmux-dashboard.sh.

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH"
command -v tmux >/dev/null 2>&1 || exit 0

popup_target=()
if [ -z "$TMUX" ]; then
  osascript -e 'tell application "WezTerm" to activate' >/dev/null 2>&1
  client=$(tmux list-clients -F '#{client_tty}' 2>/dev/null | head -1)
  [ -n "$client" ] || exit 0
  popup_target=(-c "$client")
fi

tmux display-popup "${popup_target[@]}" -E -w 25% -h 50% -T ' Switch tmux session ' \
  -s 'fg=#c0caf5,bg=#000000' -S 'fg=#bb9af7' \
  "$HOME/.config/tmux/sesh-picker.sh"
