#!/bin/bash
# Shared helpers for locating running Claude Code sessions and their tmux
# pane, and for tracking which ones the user hasn't acknowledged yet.
#
# Session discovery is 100% dynamic: the only source of truth for "which
# Claude sessions are running, where, under what name/status" is the
# `claude agents --json` CLI command (never Claude Code's internal files
# directly). It doesn't expose a tmux target, so the pane is re-derived on
# every call by walking each session's process ancestry until it crosses a
# tmux pane's leader pid — nothing is cached or persisted.
#
# The one piece of state that *is* persisted is the "notified but not yet
# seen" flag, in ~/.cache/claude-notified/<session_id> (kind=..., at=...),
# written by notify-attention.sh — neither Claude Code nor tmux know this.

# Vicinae's launchd PATH lacks Homebrew's bin dirs.
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH"

CLAUDE_NOTIFIED_DIR="$HOME/.cache/claude-notified"

# Walks up the process ancestry of $1 (a pid) up to a few levels, returns
# the tmux pane_id whose pane_pid matches an ancestor, or nothing if none
# of tmux's live panes lead to this pid. Uses tmux's own -f filter (one
# #{...} field per call) rather than a tab-delimited -F format parsed
# locally: a literal tab embedded in a -F format string gets silently
# replaced by tmux itself when it has no controlling TTY (e.g. invoked via
# AeroSpace's exec-and-forget) — confirmed by comparing raw output bytes
# between an interactive shell and an exec-and-forget invocation.
claude_pid_to_pane() {
  local pid="$1" hops=0 match
  [ -n "$pid" ] || return 0

  while [ -n "$pid" ] && [ "$pid" != "1" ] && [ "$hops" -lt 6 ]; do
    match=$(tmux list-panes -a -f "#{==:#{pane_pid},$pid}" -F '#{pane_id}' 2>/dev/null | head -n1)
    if [ -n "$match" ]; then
      printf '%s\n' "$match"
      return 0
    fi
    pid=$(ps -p "$pid" -o ppid= 2>/dev/null | tr -d ' ')
    hops=$((hops + 1))
  done
}

# Prints one tab-separated row per running interactive Claude Code session
# that resolves to a live tmux pane, notified sessions first:
# sort_key \t pane_id \t session_id \t display_text \t status
claude_session_rows() {
  command -v claude >/dev/null 2>&1 || return 0

  local json
  json=$(claude agents --json 2>/dev/null) || return 0
  [ -n "$json" ] || return 0

  local pid cwd session_id name pane_id notified_file sort_key badge tmux_session claude_status
  while IFS=$'\t' read -r pid session_id name cwd claude_status; do
    [ -n "$pid" ] || continue

    pane_id=$(claude_pid_to_pane "$pid")
    [ -n "$pane_id" ] || continue

    tmux_session=$(tmux display-message -p -t "$pane_id" '#{session_name}' 2>/dev/null)

    badge=""
    sort_key=1
    notified_file="$CLAUDE_NOTIFIED_DIR/$session_id"
    if [ -f "$notified_file" ]; then
      sort_key=0
      local kind=""
      # shellcheck disable=SC1090
      source "$notified_file"
      case "$kind" in
        (permission) badge="🔐 " ;;
        (idle)       badge="⏳ " ;;
        (done)       badge="✅ " ;;
        (*)          badge="🔔 " ;;
      esac
    fi

    printf '%s\t%s\t%s\t[%s] %s%s (%s)\t%s\n' \
      "$sort_key" "$pane_id" "$session_id" "$tmux_session" "$badge" "$name" "${cwd/#$HOME/~}" "$claude_status"
  done < <(jq -r '.[] | select(.kind=="interactive") | [.pid, .sessionId, .name, .cwd, .status] | @tsv' <<< "$json") \
    | sort -t$'\t' -k1,1n -k4
}
