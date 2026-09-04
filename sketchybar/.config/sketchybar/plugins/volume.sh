#!/bin/sh

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"
  PIDFILE="/tmp/sketchybar_volume_hide.pid"

  case "$VOLUME" in
    [6-9][0-9]|100) ICON="󰕾"
    ;;
    [3-5][0-9]) ICON="󰖀"
    ;;
    [1-9]|[1-2][0-9]) ICON="󰕿"
    ;;
    *) ICON="󰖁"
  esac

  [ -f "$PIDFILE" ] && kill "$(cat "$PIDFILE")" 2>/dev/null

  sketchybar --set "$NAME" drawing=on icon="$ICON" label="$VOLUME%"

  ( sleep 4 && sketchybar --set "$NAME" drawing=off ) &
  echo $! > "$PIDFILE"
fi
