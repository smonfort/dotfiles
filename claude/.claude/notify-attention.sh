#!/bin/bash
# Claude Code "Notification"/"Stop" hook: fires on permission prompts,
# idle-wait, and end-of-turn. Marks the session as "notified" in
# ~/.cache/claude-notified/<session_id> (skipped if the pane is already the
# one on screen — see IS_ACTIVE below) and pokes the Sketchybar item that
# shows/blinks while any session is in that state. No native macOS
# notification: the badge in the vicinae picker (Hyper+`)`, prefix+q) and
# the Sketchybar item are the only surfaces — acknowledgement is automatic
# (see ack-claude-notification.sh), not a click to dismiss.
# Exit codes are ignored by Claude Code for this hook, but every step still
# degrades gracefully to avoid noisy "hook error" notices.
#
# $1 (optional) tags which hook fired: "permission"
# (Notification/permission_prompt), "idle" (Notification/idle_prompt),
# "done" (Stop).

KIND="${1:-}"

INPUT=$(cat)

SESSION_ID=""
if command -v jq >/dev/null 2>&1; then
  SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
fi

# Skip if this pane is the one currently on screen — there's nothing to
# "come back to" (the ack-on-focus hooks only fire on a focus *change*, so
# without this check a notification raised while already looking at it
# would never get cleared until you happened to navigate away and back).
IS_ACTIVE=0
if [ -n "${TMUX:-}" ] && command -v tmux >/dev/null 2>&1; then
  read -r SESSION_ATTACHED WINDOW_ACTIVE PANE_ACTIVE <<EOF
$(tmux display-message -p -t "${TMUX_PANE:-}" '#{session_attached} #{window_active} #{pane_active}' 2>/dev/null)
EOF
  if [ "$SESSION_ATTACHED" = "1" ] && [ "$WINDOW_ACTIVE" = "1" ] && [ "$PANE_ACTIVE" = "1" ]; then
    IS_ACTIVE=1
  fi
fi

if [ -n "$SESSION_ID" ] && [ "$IS_ACTIVE" != "1" ]; then
  STATE_DIR="$HOME/.cache/claude-notified"
  mkdir -p "$STATE_DIR" 2>/dev/null
  {
    echo "kind=$KIND"
    echo "at=$(date +%s)"
  } > "$STATE_DIR/$SESSION_ID" 2>/dev/null
fi

command -v sketchybar >/dev/null 2>&1 && sketchybar --trigger claude_notification_change >/dev/null 2>&1
exit 0
