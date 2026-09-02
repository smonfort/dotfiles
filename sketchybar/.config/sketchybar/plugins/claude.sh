#!/bin/bash
# Runs on claude_notification_change and on every update_freq tick — always,
# to keep the running-session count fresh. While something is pending, the
# tick pulses the icon by toggling its color between the brand color and
# the background color (not icon.drawing=off, which shrinks the glyph and
# shifts the label) — same fade-in/out look, no layout shift.

source "$CONFIG_DIR/variables.sh"

NOTIFIED_DIR="$HOME/.cache/claude-notified"

shopt -s nullglob
notified_files=("$NOTIFIED_DIR"/*)
NOTIFIED_COUNT=${#notified_files[@]}

SESSION_COUNT=0
if command -v claude >/dev/null 2>&1; then
  COUNTED=$(claude agents --json 2>/dev/null | jq '[.[] | select(.kind=="interactive")] | length' 2>/dev/null)
  [ -n "$COUNTED" ] && SESSION_COUNT="$COUNTED"
fi

if [ "$NOTIFIED_COUNT" -eq 0 ]; then
  sketchybar --set "$NAME" \
    update_freq=15 \
    label="$SESSION_COUNT" \
    icon.drawing=on \
    icon.color="$CLAUDE_COLOR"
  exit 0
fi

# Pulse phase from wall-clock parity (deterministic, sidesteps sketchybar's
# stateful toggle=) rather than a stored blink state.
if (( $(date +%s) % 2 == 0 )); then
  ICON_COLOR="$CLAUDE_COLOR"
else
  ICON_COLOR="$ITEM_BG_COLOR"
fi

sketchybar --set "$NAME" \
  update_freq=1 \
  label="$SESSION_COUNT" \
  icon.color="$ICON_COLOR"
