#!/bin/bash
# Runs on claude_notification_change and on every update_freq tick, as the
# claude_summary item (see items/claude.sh). Aggregates every workmux-tracked
# Claude Code agent — including sessions workmux didn't itself launch, since
# `workmux register-agent`/`set-window-status` run unconditionally as Claude
# Code hooks (~/.claude/settings.json), not just inside `workmux add`
# worktrees — into one count per status, using the same icons as workmux's
# own tmux window titles and dashboard (status_icons in
# workmux/.config/workmux/config.yaml, defaults here match workmux's).

source "$CONFIG_DIR/variables.sh"

ICON_WORKING="🤖"
ICON_WAITING="💬"
ICON_DONE="✅"

STATUS_JSON=$(workmux status --json --all 2>/dev/null)

if [ -z "$STATUS_JSON" ]; then
  sketchybar --set claude_summary drawing=off
  exit 0
fi

read -r WORKING WAITING DONE <<< "$(jq -r '
  [.agents[].status] as $s |
  ([$s[] | select(. == "working")] | length),
  ([$s[] | select(. == "waiting")] | length),
  ([$s[] | select(. == "done")]    | length)
  | tostring
' <<< "$STATUS_JSON" | tr "\n" " ")"

TOTAL=$(( WORKING + WAITING + DONE ))

if [ "$TOTAL" -eq 0 ]; then
  sketchybar --set claude_summary drawing=off
  exit 0
fi

LABEL=""
[ "$WORKING" -gt 0 ] && LABEL="$LABEL$ICON_WORKING $WORKING  "
[ "$WAITING" -gt 0 ] && LABEL="$LABEL$ICON_WAITING $WAITING  "
[ "$DONE" -gt 0 ] && LABEL="$LABEL$ICON_DONE $DONE"
LABEL="${LABEL%  }"

# Pulse the whole label when something needs attention (waiting or done);
# deterministic wall-clock parity, same trick as before, sidesteps
# sketchybar's stateful toggle=.
if [ "$WAITING" -gt 0 ] || [ "$DONE" -gt 0 ]; then
  if (( $(date +%s) % 2 == 0 )); then
    LABEL_COLOR="$CLAUDE_COLOR"
  else
    LABEL_COLOR="$WHITE"
  fi
  UPDATE_FREQ=1
else
  LABEL_COLOR="$WHITE"
  UPDATE_FREQ=15
fi

sketchybar --set claude_summary drawing=on \
                                 label="$LABEL" \
                                 label.color="$LABEL_COLOR" \
                                 update_freq="$UPDATE_FREQ"
