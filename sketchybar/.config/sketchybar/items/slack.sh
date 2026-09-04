#!/bin/bash

sketchybar --add item slack right \
           --set slack \
                 icon=":slack:" \
                 icon.font="sketchybar-app-font:Regular:16.0" \
                 icon.color=$WHITE \
                 label.padding_left=0 \
                 drawing=off \
                 update_freq=15 \
                 script="$PLUGIN_DIR/slack.sh"
