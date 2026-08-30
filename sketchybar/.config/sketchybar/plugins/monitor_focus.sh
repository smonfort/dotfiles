#!/usr/bin/env bash

source "$CONFIG_DIR/variables.sh"

MONITOR_ID="$1"
FOCUSED_MONITOR="$(aerospace list-monitors --focused --format "%{monitor-id}")"

if [ "$MONITOR_ID" = "$FOCUSED_MONITOR" ]; then
    sketchybar --set "$NAME" background.drawing=off icon.color=$ORANGE
else
    sketchybar --set "$NAME" background.drawing=off icon.color=$COMMENT
fi
