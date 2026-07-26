#!/bin/bash
# Fuzzy-pick a running Claude Code session and jump to its tmux window.
# Registry populated/cleaned by ~/.claude/register-tmux-session.sh and
# ~/.claude/unregister-tmux-session.sh; ~/.claude/notify-attention.sh adds
# the notified/notified_kind fields used for the badge below.

STATE_DIR="$HOME/.cache/claude-sessions"
[ -d "$STATE_DIR" ] || exit 0

for f in "$STATE_DIR"/*; do
  [ -f "$f" ] || continue
  notified=0
  notified_kind=""
  # shellcheck disable=SC1090
  source "$f"

  if ! tmux has-session -t "$tmux_session" 2>/dev/null; then
    rm -f "$f" # stale entry, session gone
    continue
  fi

  BADGE=""
  if [ "$notified" = "1" ]; then
    case "$notified_kind" in
      permission) BADGE="🔐 " ;;
      idle)       BADGE="⏳ " ;;
      done)       BADGE="✅ " ;;
      *)          BADGE="🔔 " ;;
    esac
  fi

  printf '%s:%s\t%s%s (%s) — %s\n' \
    "$tmux_session" "$tmux_window" "$BADGE" "$tmux_session" "$window_name" "${cwd/#$HOME/~}"
done \
  | sort -u -t$'\t' -k2 \
  | fzf-tmux -p --reverse --no-info --border-label ' 🤖 Switch to Claude window ' --delimiter=$'\t' --with-nth=2 \
  | cut -f1 \
  | xargs -I{} tmux switch-client -t "{}" \; select-window -t "{}"
