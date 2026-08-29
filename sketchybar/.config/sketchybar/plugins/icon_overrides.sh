#!/usr/bin/env bash

# Custom overrides for apps not covered (or misidentified) by the
# vendored sketchybar-app-font icon_map.sh. Kept in a separate file
# so it survives icon_map.sh regeneration/updates.
resolve_icon() {
    case "$1" in
   "Gmail")
        icon_result=":mail:"
        ;;
   "Google Calendar")
        icon_result=":calendar:"
        ;;
   *)
        __icon_map "$1"
        ;;
    esac
}
