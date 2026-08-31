#!/usr/bin/env bash

source "$CONFIG_DIR/variables.sh"
source "$CONFIG_DIR/plugins/icon_map.sh"
source "$CONFIG_DIR/plugins/icon_overrides.sh"

SID="$1"

# Recompute the full, deterministic (sorted) order for both monitor groups
# and re-assert it. This is idempotent, so it stays stable even though every
# space's script calls it independently every couple seconds.
M1_SPACES=$(aerospace list-workspaces --monitor 1 | sort | sed 's/^/space./' | tr '\n' ' ')
M2_SPACES=$(aerospace list-workspaces --monitor 2 | sort | sed 's/^/space./' | tr '\n' ' ')
sketchybar --reorder monitor_icon $M1_SPACES laptop_icon $M2_SPACES 2>/dev/null

APPS=$(aerospace list-windows --workspace "$SID" --format "%{app-name}" 2>/dev/null | sort -u)

ICONS=""
LABEL_FONT="sketchybar-app-font:Regular:14.0"
LABEL_Y_OFFSET=-2
while IFS= read -r app; do
    [ -z "$app" ] && continue
    resolve_icon "$app"
    # Tokens from sketchybar-app-font are always ":name:"; a raw glyph
    # (no colons) means the app has no icon in that font, so fall back
    # to $FONT, which has full Nerd Font glyph coverage. Its glyphs sit
    # on a different baseline, so drop the -2 y_offset tuned for
    # sketchybar-app-font (0 matches how $FONT renders elsewhere in the bar).
    case "$icon_result" in
        :*:) : ;;
        *) LABEL_FONT="$FONT:Semibold:14.0"; LABEL_Y_OFFSET=0 ;;
    esac
    ICONS+="$icon_result "
done <<< "$APPS"

if [ -z "$ICONS" ]; then
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

if [ "$SID" = "$(aerospace list-workspaces --focused)" ]; then
    sketchybar --set "$NAME" \
        drawing=on \
        background.color=$ACCENT_COLOR \
        icon.color=$BAR_COLOR \
        label.color=$BAR_COLOR \
        label.font="$LABEL_FONT" \
        label.y_offset="$LABEL_Y_OFFSET" \
        label="$ICONS"
else
    sketchybar --set "$NAME" \
        drawing=on \
        background.color=$ITEM_BG_COLOR \
        icon.color=$WHITE \
        label.color=$WHITE \
        label.font="$LABEL_FONT" \
        label.y_offset="$LABEL_Y_OFFSET" \
        label="$ICONS"
fi
