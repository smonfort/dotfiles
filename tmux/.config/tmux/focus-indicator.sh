#!/bin/bash
# Renders the focus pastille in the status bar. When unfocused, cycles
# through a red -> orange -> red gradient (one step per status-interval
# tick) to create a pulsing "wave" effect that catches the eye.

focused=$(tmux show -gv @focused)

if [ "$focused" = "no" ]; then
  colors=(88 124 160 196 202 208 214 208 202 196 160 124)
  index=$(( $(date +%s) % ${#colors[@]} ))
  echo "#[fg=colour${colors[$index]}]● unfocused#[default]"
else
  echo "#[fg=green]● focused#[default]"
fi
