#!/usr/bin/env bash

source "$CONFIG_DIR/variables.sh"
source "$CONFIG_DIR/plugins/icon_map.sh"

SID="$1"

# Recompute the full, deterministic (sorted) order for both monitor groups
# and re-assert it. This is idempotent, so it stays stable even though every
# space's script calls it independently every couple seconds.
M1_SPACES=$(aerospace list-workspaces --monitor 1 | sort | sed 's/^/space./' | tr '\n' ' ')
M2_SPACES=$(aerospace list-workspaces --monitor 2 | sort | sed 's/^/space./' | tr '\n' ' ')
sketchybar --reorder monitor_icon $M1_SPACES laptop_icon $M2_SPACES 2>/dev/null

APPS=$(aerospace list-windows --workspace "$SID" --format "%{app-name}" 2>/dev/null | sort -u)

ICONS=""
while IFS= read -r app; do
    [ -z "$app" ] && continue
    __icon_map "$app"
    ICONS+="$icon_result "
done <<< "$APPS"

if [ -z "$ICONS" ]; then
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

if [ "$SID" = "$(aerospace list-workspaces --focused)" ]; then
    sketchybar --set "$NAME" \
        drawing=on \
        background.color=$MUTED_ORANGE \
        icon.color=$BAR_COLOR \
        label.color=$BAR_COLOR \
        label="$ICONS"
else
    sketchybar --set "$NAME" \
        drawing=on \
        background.color=$ITEM_BG_COLOR \
        icon.color=$WHITE \
        label.color=$WHITE \
        label="$ICONS"
fi
