#!/bin/bash
# Picks a Nerd Font icon for a tmux window based on the foreground command
# running in its active pane (tmux passes #{pane_current_command} as $1).
# Codepoints reuse this machine's starship prompt defaults (nodejs, python,
# go, ruby, docker, lua), which are already known to render correctly here.

case "$1" in
  vim|nvim)              echo -n $'' ;;
  git)                   echo -n $'' ;;
  node)                  echo -n $'' ;;
  python|python3)        echo -n $'' ;;
  go)                    echo -n $'' ;;
  ruby|irb)              echo -n $'' ;;
  docker|docker-compose) echo -n $'' ;;
  lua)                   echo -n $'' ;;
  claude)                echo -n $'' ;;
  *)                     echo -n $'' ;;
esac
