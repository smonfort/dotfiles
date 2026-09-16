#!/bin/bash

source "$CONFIG_DIR/variables.sh"

# IsSecureEventInputEnabled is a deprecated Carbon call, but it's still the
# only public API for this (still used by iTerm2, Kitty, Chromium...). JXA's
# ObjC bridge exposes plain C functions from an imported framework under $.
ENABLED="$(osascript -l JavaScript -e 'ObjC.import("Carbon"); $.IsSecureEventInputEnabled()' 2>/dev/null)"

if [ "$ENABLED" != "true" ]; then
  sketchybar --set "$NAME" drawing=off update_freq=10
  exit 0
fi

# Blink while active: deterministic wall-clock parity, same trick as
# claude.sh, sidesteps sketchybar's stateful toggle=.
if (( $(date +%s) % 2 == 0 )); then
  COLOR=$ORANGE
else
  COLOR=$WHITE
fi

sketchybar --set "$NAME" drawing=on icon.color="$COLOR" label.color="$COLOR" update_freq=1
