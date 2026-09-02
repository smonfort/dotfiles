#!/bin/bash

sketchybar --add event claude_notification_change

# Always visible: label is the count of running Claude Code sessions, icon
# stays Claude's brand color at all times. plugins/claude.sh only pulses
# the background (same pill as every other right-side item otherwise) while
# at least one session has an unacknowledged notification — see
# ~/.claude/notify-attention.sh and .tmux.conf's ack-claude-notification.sh.
sketchybar --add item claude_notify right \
           --set claude_notify drawing=on \
                                update_freq=15 \
                                icon=":claude:" \
                                icon.font="sketchybar-app-font:Regular:14.0" \
                                icon.color="$CLAUDE_COLOR" \
                                icon.y_offset=-1.5 \
                                label.drawing=on \
                                background.drawing=on \
                                background.color="$ITEM_BG_COLOR" \
                                script="$PLUGIN_DIR/claude.sh" \
           --subscribe claude_notify claude_notification_change
