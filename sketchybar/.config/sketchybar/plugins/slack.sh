#!/bin/bash
# Polls Slack's Dock tile accessibility badge (AXStatusLabel) to detect
# pending notifications, since Slack exposes no local API or hook for this.
# Shows the icon with the badge text as its label while a badge is present,
# hides it otherwise.

source "$CONFIG_DIR/variables.sh"

BADGE=$(osascript -e '
tell application "System Events"
    if not (exists process "Slack") then return ""
    tell process "Dock"
        try
            set badgeValue to value of attribute "AXStatusLabel" of (first UI element of list 1 whose name is "Slack")
            if badgeValue is missing value then
                return ""
            else
                return badgeValue
            end if
        on error
            return ""
        end try
    end tell
end tell' 2>/dev/null)

if [ -n "$BADGE" ]; then
  sketchybar --set slack drawing=on label="$BADGE" label.drawing=on icon.color=$ACCENT_COLOR
else
  sketchybar --set slack drawing=off
fi
