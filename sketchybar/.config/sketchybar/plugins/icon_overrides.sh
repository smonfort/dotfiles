#!/usr/bin/env bash

# Custom overrides for apps not covered (or misidentified) by the
# vendored sketchybar-app-font icon_map.sh. Kept in a separate file
# so it survives icon_map.sh regeneration/updates.
#
# icon_result is normally a ":name:" token resolved by sketchybar-app-font.
# For apps with no icon in that font (e.g. web-app shortcuts with no real
# macOS bundle), return a raw Nerd Font glyph instead — aerospace.sh detects
# the missing colons and switches the space label to $FONT to render it.
resolve_icon() {
    case "$1" in
   "Gmail")
        icon_result=":mail:"
        ;;
   "Google Calendar")
        icon_result=":calendar:"
        ;;
   "Shortcut")
        icon_result=$'' # nf-fa-tasks (shortcut.com web-app shortcut)
        ;;
   *)
        __icon_map "$1"
        ;;
    esac
}
