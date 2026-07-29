#!/bin/bash
# Claude Code "Notification"/"Stop" hook: fires on permission prompts,
# idle-wait, and end-of-turn. Sends a macOS notification via alerter
# (https://github.com/vjeantet/alerter) and marks the session's entry in
# ~/.cache/claude-sessions/ (written by register-tmux-session.sh) as
# notified, so the `prefix + a` binding in dotfiles/tmux/.tmux.conf can jump
# back to it and `prefix + q` can badge it.
# Exit codes are ignored by Claude Code for this hook, but every step still
# degrades gracefully to avoid noisy "hook error" notices.
#
# $1 (optional) tags which hook fired, so the notification can carry that
# context: "permission" (Notification/permission_prompt), "idle"
# (Notification/idle_prompt), "done" (Stop). Empty/unknown falls back to the
# original generic behavior.

KIND="${1:-}"

NOTIFICATION_ICON_URL='https://imgs.search.brave.com/XyGLUOyaL6Bt5oPFQl368eQw65I_BBf8TQppRDECrCk/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9hc3Nl/dHMuc3RpY2twbmcu/Y29tL3RodW1icy82/NmFmOTk4MzllNTVm/MWVlMjlmMTE3YWMu/cG5n'

INPUT=$(cat)

MESSAGE=""
SESSION_ID=""
if command -v jq >/dev/null 2>&1; then
  if [ "$KIND" = "done" ]; then
    MESSAGE=$(printf '%s' "$INPUT" | jq -r '.last_assistant_message // empty' 2>/dev/null)
  else
    MESSAGE=$(printf '%s' "$INPUT" | jq -r '.message // empty' 2>/dev/null)
  fi
  SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
fi

if [ "$KIND" = "done" ] && [ -n "$MESSAGE" ]; then
  MESSAGE=$(printf '%s' "$MESSAGE" | tr '\n' ' ' | tr -s ' ')
  if [ ${#MESSAGE} -gt 200 ]; then
    MESSAGE="${MESSAGE:0:200}…"
  fi
fi

SESSION=""
IS_ACTIVE=0
if [ -n "${TMUX:-}" ] && command -v tmux >/dev/null 2>&1; then
  SESSION=$(tmux display-message -p '#S' 2>/dev/null)
  read -r SESSION_ATTACHED WINDOW_ACTIVE PANE_ACTIVE <<EOF
$(tmux display-message -p -t "${TMUX_PANE:-}" '#{session_attached} #{window_active} #{pane_active}' 2>/dev/null)
EOF
  if [ "$SESSION_ATTACHED" = "1" ] && [ "$WINDOW_ACTIVE" = "1" ] && [ "$PANE_ACTIVE" = "1" ]; then
    IS_ACTIVE=1
  fi
fi

if [ -n "$SESSION_ID" ]; then
  STATE_DIR="$HOME/.cache/claude-sessions"
  SESSION_FILE="$STATE_DIR/$SESSION_ID"
  NOTIFIED_AT=$(date +%s)
  if [ -f "$SESSION_FILE" ]; then
    {
      echo "notified=1"
      echo "notified_kind=$KIND"
      echo "notified_at=$NOTIFIED_AT"
    } >> "$SESSION_FILE" 2>/dev/null
  elif [ -n "$SESSION" ]; then
    # Registry entry missing (e.g. SessionStart hook never ran) — create a
    # minimal fallback so the notification isn't silently lost.
    mkdir -p "$STATE_DIR" 2>/dev/null
    {
      echo "tmux_session=$SESSION"
      echo "tmux_pane=${TMUX_PANE:-}"
      echo "notified=1"
      echo "notified_kind=$KIND"
      echo "notified_at=$NOTIFIED_AT"
    } > "$SESSION_FILE" 2>/dev/null
  fi
fi

ICON=""
DEFAULT_BODY="needs your attention"
case "$KIND" in
  permission) ICON="🔐 " ; DEFAULT_BODY="needs your attention" ;;
  idle)       ICON="⏳ " ; DEFAULT_BODY="waiting for your input" ;;
  done)       ICON="✅ " ; DEFAULT_BODY="finished" ;;
esac

TITLE="${ICON}Claude Code"
[ -n "$SESSION" ] && TITLE="${ICON}Claude Code — $SESSION"
BODY="${MESSAGE:-$DEFAULT_BODY}"

escape() { printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'; }
SAFE_TITLE=$(escape "$TITLE")
SAFE_BODY=$(escape "$BODY")

if [ "$IS_ACTIVE" != "1" ]; then
  if command -v alerter >/dev/null 2>&1 && [ -n "$SESSION_ID" ]; then
    # alerter blocks until the notification is dismissed/clicked (unlike
    # terminal-notifier's fire-and-forget -execute), so run it detached and
    # act on its stdout ("@CONTENTCLICKED" on click) once it returns.
    (
      ANSWER=$(alerter --title "$SAFE_TITLE" --message "$SAFE_BODY" --app-icon "$NOTIFICATION_ICON_URL" 2>/dev/null)
      [ "$ANSWER" = "@CONTENTCLICKED" ] && "$HOME/.claude/notify-click.sh" "$SESSION_ID"
    ) >/dev/null 2>&1 &
    disown 2>/dev/null || true
  else
    osascript -e "display notification \"$SAFE_BODY\" with title \"$SAFE_TITLE\"" >/dev/null 2>&1
  fi
fi
exit 0
