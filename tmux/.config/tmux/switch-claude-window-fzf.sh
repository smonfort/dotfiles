#!/bin/bash
# Fuzzy-pick a running Claude Code session and jump to its tmux window.
# Registry populated/cleaned by ~/.claude/register-tmux-session.sh and
# ~/.claude/unregister-tmux-session.sh.

STATE_DIR="$HOME/.cache/claude-sessions"
[ -d "$STATE_DIR" ] || exit 0

for f in "$STATE_DIR"/*; do
  [ -f "$f" ] || continue
  # shellcheck disable=SC1090
  source "$f"

  if ! tmux has-session -t "$tmux_session" 2>/dev/null; then
    rm -f "$f" # stale entry, session gone
    continue
  fi

  printf '%s:%s\t%s (%s) — %s\n' \
    "$tmux_session" "$tmux_window" "$tmux_session" "$window_name" "${cwd/#$HOME/~}"
done \
  | sort -u -t$'\t' -k2 \
  | fzf-tmux -p --reverse --no-info --border-label ' 🤖 Switch to Claude window ' --with-nth=2 \
  | cut -f1 \
  | xargs -I{} tmux switch-client -t "{}" \; select-window -t "{}"
