#!/bin/bash

sketchybar --add event claude_notification_change

# One item summarizing every workmux-tracked Claude Code agent by status
# (working/waiting/done) — see plugins/claude.sh. Clicking it opens the
# workmux dashboard to act on whichever agent needs attention.
sketchybar --add item claude_summary right \
           --set claude_summary drawing=off \
                                 update_freq=15 \
                                 icon.drawing=off \
                                 label.font="$FONT:Semibold:14.0" \
                                 label.padding_left=10 \
                                 label.padding_right=10 \
                                 background.drawing=on \
                                 background.color="$ITEM_BG_COLOR" \
                                 background.height=24 \
                                 background.corner_radius=5 \
                                 script="$PLUGIN_DIR/claude.sh" \
                                 click_script="$HOME/.config/tmux/focus-workmux-dashboard.sh" \
           --subscribe claude_summary claude_notification_change
