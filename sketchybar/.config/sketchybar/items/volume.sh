#!/bin/bash

sketchybar --add item volume right \
           --set volume icon.color=$GREEN \
                        drawing=off \
                        script="$PLUGIN_DIR/volume.sh" \
           --subscribe volume volume_change
