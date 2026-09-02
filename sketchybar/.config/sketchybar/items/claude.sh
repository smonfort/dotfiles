#!/bin/bash

sketchybar --add event claude_notification_change

# Invisible driver: owns no visual space itself, just runs plugins/claude.sh
# periodically (and on notification changes) to add/remove one visible icon
# per running Claude Code session — see plugins/claude.sh for how each
# session's icon is reconciled and pulsed.
sketchybar --add item claude_manager right \
           --set claude_manager drawing=off \
                                 update_freq=15 \
                                 script="$PLUGIN_DIR/claude.sh" \
           --subscribe claude_manager claude_notification_change
