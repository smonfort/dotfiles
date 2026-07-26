#!/bin/bash
# Claude Code "Notification"/"Stop" hook: fires on permission prompts,
# idle-wait, and end-of-turn. Sends a macOS notification and records the
# triggering tmux session so the `prefix + a` binding in
# dotfiles/tmux/.tmux.conf can jump back to it.
# Exit codes are ignored by Claude Code for this hook, but every step still
# degrades gracefully to avoid noisy "hook error" notices.
#
# $1 (optional) tags which hook fired, so the notification can carry that
# context: "permission" (Notification/permission_prompt), "idle"
# (Notification/idle_prompt), "done" (Stop). Empty/unknown falls back to the
# original generic behavior.

KIND="${1:-}"

INPUT=$(cat)

MESSAGE=""
if command -v jq >/dev/null 2>&1; then
  if [ "$KIND" = "done" ]; then
    MESSAGE=$(printf '%s' "$INPUT" | jq -r '.last_assistant_message // empty' 2>/dev/null)
  else
    MESSAGE=$(printf '%s' "$INPUT" | jq -r '.message // empty' 2>/dev/null)
  fi
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

if [ -n "$SESSION" ]; then
  STATE_DIR="$HOME/.cache/claude-notify"
  mkdir -p "$STATE_DIR" 2>/dev/null
  printf '%s\n%s\n' "$SESSION" "${TMUX_PANE:-}" > "$STATE_DIR/last-target" 2>/dev/null
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
  osascript -e "display notification \"$SAFE_BODY\" with title \"$SAFE_TITLE\"" >/dev/null 2>&1
fi
exit 0
