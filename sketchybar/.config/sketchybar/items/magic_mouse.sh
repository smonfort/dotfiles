#!/bin/bash

sketchybar --add item magic_mouse right \
           --set magic_mouse icon="󰦋" \
                             icon.color=$CYAN \
                             update_freq=15 \
                             script="$PLUGIN_DIR/magic_mouse.sh" \
           --subscribe magic_mouse system_woke
