#!/bin/bash
# Only show the active border when the focused workspace has more than one window.
# `borders` redraws every window's border globally on each call, so we skip
# the call entirely when the desired state hasn't changed since last time.
active_color=0xffd99000
inactive_color=0x00494d64
state_file="/tmp/aerospace-border-state"

if [ "$(aerospace list-windows --workspace focused --count)" -gt 1 ]; then
  desired="multi"
else
  desired="single"
fi

[ "$(cat "$state_file" 2>/dev/null)" = "$desired" ] && exit 0
echo "$desired" > "$state_file"

if [ "$desired" = "multi" ]; then
  borders active_color="$active_color" inactive_color="$inactive_color"
else
  borders active_color="$inactive_color" inactive_color="$inactive_color"
fi
