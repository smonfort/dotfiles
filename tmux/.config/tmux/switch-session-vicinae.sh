#!/bin/bash
# Fuzzy-pick a tmux session (open) or tmuxinator project (closed) and switch to it, starting it if needed.

open_sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null | sort)

all_projects=$(find -L ~/.tmuxinator/ -type f -maxdepth 1 -name '*.yml' \
  | xargs -n 1 basename \
  | sed 's/\.yml$//' \
  | sort)

closed_projects=$(comm -23 <(printf '%s\n' "$all_projects") <(printf '%s\n' "$open_sessions"))

selection=$(
  {
    [ -n "$open_sessions" ] && printf '%s\n' "$open_sessions" | sed 's/^/● /'
    [ -n "$closed_projects" ] && printf '%s\n' "$closed_projects" | sed 's/^/○ /'
  } | vicinae dmenu -f data \
      -n 'Switch tmux session' \
      -p 'Search sessions…' \
      --no-quick-look
)

[ -z "$selection" ] && exit 0

icon=${selection%% *}
name=${selection#* }

if [ "$icon" = "●" ]; then
  tmux switch-client -t "$name"
else
  tmuxinator start "$name" && tmux switch-client -t "$name"
fi
