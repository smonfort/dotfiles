#!/bin/bash
# tmux hook target (see .tmux.conf): auto-acknowledges any pending Claude
# Code notification for the pane you just landed on. Bails out immediately
# when nothing's pending, since this runs on every focus change.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./claude-notifications-common.sh
source "$DIR/claude-notifications-common.sh"

shopt -s nullglob
pending=("$CLAUDE_NOTIFIED_DIR"/*)
[ "${#pending[@]}" -gt 0 ] || exit 0

# Ask the attached client what's on screen (a bare `display-message -p`
# can default to the triggering pane instead). One client assumed.
CLIENT=$(tmux list-clients -F '#{client_tty}' 2>/dev/null | head -1)
[ -n "$CLIENT" ] || exit 0
CURRENT_PANE=$(tmux display-message -p -t "$CLIENT" '#{pane_id}' 2>/dev/null)
[ -n "$CURRENT_PANE" ] || exit 0

command -v claude >/dev/null 2>&1 || exit 0
json=$(claude agents --json 2>/dev/null)
[ -n "$json" ] || exit 0

changed=0
for f in "${pending[@]}"; do
  session_id=$(basename "$f")
  pid=$(jq -r --arg sid "$session_id" '.[] | select(.sessionId == $sid) | .pid' <<< "$json" | head -n1)
  [ -n "$pid" ] || continue

  if [ "$(claude_pid_to_pane "$pid")" = "$CURRENT_PANE" ]; then
    rm -f "$f" 2>/dev/null
    changed=1
  fi
done

if [ "$changed" = "1" ]; then
  command -v sketchybar >/dev/null 2>&1 && sketchybar --trigger claude_notification_change
fi
