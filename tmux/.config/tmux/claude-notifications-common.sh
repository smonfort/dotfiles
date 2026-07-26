#!/bin/bash
# Shared helpers for the Claude Code notification tmux bindings:
# prefix+a jumps to the most recent one (jump-to-notified-session.sh),
# prefix+z lists every pending one via fzf (claude-notifications-fzf.sh).
# Both read the per-session registry in ~/.cache/claude-sessions/ (written
# by ~/.claude/register-tmux-session.sh and ~/.claude/notify-attention.sh).

CLAUDE_STATE_DIR="$HOME/.cache/claude-sessions"

# Prints one tab-separated row per unacknowledged notification, sorted
# newest first: notified_at \t file_id \t tmux_target \t display_text
claude_notification_rows() {
  [ -d "$CLAUDE_STATE_DIR" ] || return 0

  local f tmux_session tmux_pane window_name cwd notified notified_kind notified_at
  local target BADGE AGE AGO NOW
  NOW=$(date +%s)

  for f in "$CLAUDE_STATE_DIR"/*; do
    [ -f "$f" ] || continue
    tmux_session=""
    tmux_pane=""
    window_name=""
    cwd=""
    notified=0
    notified_kind=""
    notified_at=0
    # shellcheck disable=SC1090
    source "$f"

    if ! tmux has-session -t "$tmux_session" 2>/dev/null; then
      rm -f "$f" # stale entry, session gone
      continue
    fi

    [ "$notified" = "1" ] || continue

    if [ -n "$tmux_pane" ] && tmux list-panes -a -F '#{pane_id}' 2>/dev/null | grep -qx "$tmux_pane"; then
      target="$tmux_pane"
    else
      target="$tmux_session"
    fi

    case "$notified_kind" in
      (permission) BADGE="🔐" ;;
      (idle)       BADGE="⏳" ;;
      (done)       BADGE="✅" ;;
      (*)          BADGE="🔔" ;;
    esac

    AGE=$(( NOW - notified_at ))
    if [ "$AGE" -lt 60 ]; then
      AGO="${AGE}s ago"
    elif [ "$AGE" -lt 3600 ]; then
      AGO="$(( AGE / 60 ))m ago"
    else
      AGO="$(( AGE / 3600 ))h ago"
    fi

    printf '%s\t%s\t%s\t%s %s (%s) — %s — %s\n' \
      "$notified_at" "$(basename "$f")" "$target" "$BADGE" "$tmux_session" "$window_name" "${cwd/#$HOME/~}" "$AGO"
  done | sort -t$'\t' -k1,1nr
}

# Switches to $1 (a tmux pane id or session name) and clears the notified*
# fields from the registry file named $2, so it isn't picked again until a
# new notification arrives.
claude_notification_consume() {
  local target="$1" file_id="$2" sf
  tmux switch-client -t "$target"
  # switch-client resolves the pane's session and window automatically;
  # select-pane is just a safety net for multi-pane windows.
  tmux select-pane -t "$target" 2>/dev/null

  sf="$CLAUDE_STATE_DIR/$file_id"
  grep -v '^notified' "$sf" > "$sf.tmp" 2>/dev/null && mv "$sf.tmp" "$sf"
}
