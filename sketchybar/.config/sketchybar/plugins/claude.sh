#!/bin/bash
# Runs on claude_notification_change and on every update_freq tick, as the
# invisible claude_manager item (see items/claude.sh). Reconciles one visible
# claude_session_<id> icon per running interactive Claude Code session
# against the bar's actual item list — queried fresh each run via
# `--query bar` rather than tracked in a state file, so a sketchybar restart
# can't desync it — then pulses each session's icon independently (by
# toggling its color between the brand color and the background color, not
# icon.drawing=off which shrinks the glyph) while that session has an
# unacknowledged notification — see ~/.claude/notify-attention.sh and
# .tmux.conf's ack-claude-notification.sh.

source "$CONFIG_DIR/variables.sh"

NOTIFIED_DIR="$HOME/.cache/claude-notified"

# Sessions actively generating (status=="busy") swap the static Claude
# wordmark for a brain glyph (nf-md-brain) — reads as "thinking", unlike
# the app-font icon which looks the same whether Claude is working or
# waiting on the user.
BUSY_ICON="󰧑"
BUSY_ICON_FONT="$FONT:Semibold:14.0"
IDLE_ICON=":claude:"
IDLE_ICON_FONT="sketchybar-app-font:Regular:14.0"

item_name_for() { echo "claude_session_${1//-/_}"; }

SESSION_DATA=""
if command -v claude >/dev/null 2>&1; then
  SESSION_DATA=$(claude agents --json 2>/dev/null | jq -r '[.[] | select(.kind=="interactive")] | sort_by(.startedAt) | .[] | "\(.sessionId)\t\(.status)"' 2>/dev/null)
fi

DESIRED_NAMES=()
DESIRED_SIDS=()
DESIRED_STATUSES=()
while IFS=$'\t' read -r sid status; do
  [ -z "$sid" ] && continue
  DESIRED_SIDS+=("$sid")
  DESIRED_STATUSES+=("$status")
  DESIRED_NAMES+=("$(item_name_for "$sid")")
done <<< "$SESSION_DATA"

EXISTING_NAMES=$(sketchybar --query bar 2>/dev/null | jq -r '.items[] | select(startswith("claude_session_"))' 2>/dev/null)

# Drop items whose session is no longer running.
while IFS= read -r name; do
  [ -z "$name" ] && continue
  keep=0
  for want in "${DESIRED_NAMES[@]}"; do
    [ "$name" = "$want" ] && { keep=1; break; }
  done
  [ "$keep" -eq 0 ] && sketchybar --remove "$name" 2>/dev/null
done <<< "$EXISTING_NAMES"

# Add items for newly seen sessions.
for name in "${DESIRED_NAMES[@]}"; do
  if ! grep -qx "$name" <<< "$EXISTING_NAMES"; then
    sketchybar --add item "$name" right \
               --set "$name" \
               icon.color="$CLAUDE_COLOR" \
               icon.padding_left=8 \
               icon.padding_right=8 \
               label.drawing=off \
               label.padding_left=0 \
               label.padding_right=0 \
               background.drawing=on \
               background.color="$ITEM_BG_COLOR" \
               2>/dev/null
  fi
done

# Keep them ordered by session start time, grouped next to the driver item.
[ "${#DESIRED_NAMES[@]}" -gt 0 ] && sketchybar --reorder claude_manager "${DESIRED_NAMES[@]}" 2>/dev/null

# Pulse phase from wall-clock parity (deterministic, sidesteps sketchybar's
# stateful toggle=) rather than a stored blink state.
if (( $(date +%s) % 2 == 0 )); then
  PULSE_COLOR="$CLAUDE_COLOR"
else
  PULSE_COLOR="$ITEM_BG_COLOR"
fi

ANY_NOTIFIED=0
for i in "${!DESIRED_SIDS[@]}"; do
  sid="${DESIRED_SIDS[$i]}"
  name="${DESIRED_NAMES[$i]}"

  if [ "${DESIRED_STATUSES[$i]}" = "busy" ]; then
    sketchybar --set "$name" icon="$BUSY_ICON" icon.font="$BUSY_ICON_FONT" icon.y_offset=-1
  else
    sketchybar --set "$name" icon="$IDLE_ICON" icon.font="$IDLE_ICON_FONT" icon.y_offset=-1.5
  fi

  if [ -f "$NOTIFIED_DIR/$sid" ]; then
    ANY_NOTIFIED=1
    sketchybar --set "$name" icon.color="$PULSE_COLOR"
  else
    sketchybar --set "$name" icon.color="$CLAUDE_COLOR"
  fi
done

sketchybar --set claude_manager update_freq=$([ "$ANY_NOTIFIED" -eq 1 ] && echo 1 || echo 15)
