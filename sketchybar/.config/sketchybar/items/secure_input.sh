#!/bin/bash

# Shows a blinking lock icon while macOS Secure Input mode is active, which
# blocks Hammerspoon's global event tap (and therefore the hyperkey) from
# seeing keystrokes at all.
sketchybar --add item secure_input right \
           --set secure_input drawing=off \
                               icon="󰌾" \
                               icon.color=$ORANGE \
                               label="Secure Input" \
                               label.color=$ORANGE \
                               update_freq=10 \
                               script="$PLUGIN_DIR/secure_input.sh" \
           --subscribe secure_input system_woke
