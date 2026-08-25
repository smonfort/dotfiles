#!/bin/bash

INITIAL_APP="$(aerospace list-windows --focused --format "%{app-name}" 2>/dev/null)"

sketchybar --add item front_app left \
           --set front_app       width=180 \
                                 scroll_texts=on \
                                 background.color=$BAR_COLOR \
                                 icon.color=$ACCENT_COLOR \
                                 icon.font="sketchybar-app-font:Regular:14.0" \
                                 icon.y_offset=-2 \
                                 label.color=$ACCENT_COLOR \
                                 label="$INITIAL_APP" \
                                 icon="$($PLUGIN_DIR/icon_map.sh "$INITIAL_APP")" \
                                 script="$PLUGIN_DIR/front_app.sh" \
           --subscribe front_app front_app_switched
