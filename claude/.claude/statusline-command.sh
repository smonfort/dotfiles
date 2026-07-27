#!/usr/bin/env bash
# Claude Code status line — dir + git branch + context + 5h session + 7d weekly

input=$(cat)

# Build a progress bar: make_bar <pct_int> <width>
make_bar() {
  local pct=$1 width=${2:-10}
  local filled=$(( pct * width / 100 ))
  local empty=$(( width - filled ))
  local bar=""
  local color
  if [ "$pct" -ge 80 ]; then
    color='\033[31m'
  elif [ "$pct" -ge 50 ]; then
    color='\033[33m'
  else
    color='\033[32m'
  fi
  local i
  for (( i=0; i<filled; i++ )); do bar="${bar}█"; done
  for (( i=0; i<empty;  i++ )); do bar="${bar}░"; done
  printf "${color}%s\033[0m %s%%" "$bar" "$pct"
}

# --- Shell prompt segment (dir + git branch) ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty')
[ -z "$cwd" ] && cwd=$(pwd)
home="$HOME"
short_cwd="${cwd/#$home/~}"

git_branch=$(git -C "$cwd" -c gc.auto=0 symbolic-ref --short HEAD 2>/dev/null)

model=$(echo "$input" | jq -r '.model.display_name // empty')

prompt_line=$(printf '\033[34m%s\033[0m' "$short_cwd")
if [ -n "$git_branch" ]; then
  prompt_line="$prompt_line $(printf '\033[35m(%s)\033[0m' "$git_branch")"
fi
if [ -n "$model" ]; then
  prompt_line="$prompt_line  $(printf '\033[33m%s\033[0m' "$model")"
fi

# --- Context window ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')

if [ -n "$used_pct" ] && [ -n "$ctx_size" ]; then
  used_pct_int=$(printf '%.0f' "$used_pct")
  ctx_k=$(( ctx_size / 1000 ))
  used_k=$(( total_input / 1000 ))
  ctx_line="Ctx $(make_bar "$used_pct_int") (${used_k}k/${ctx_k}k)"
else
  ctx_line="Ctx --"
fi

# --- 5-hour session rate limit ---
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')

if [ -n "$five_pct" ]; then
  five_pct_int=$(printf '%.0f' "$five_pct")
  bar=$(make_bar "$five_pct_int")
  if [ -n "$five_resets" ]; then
    resets_fmt=$(date -r "$five_resets" "+%H:%M" 2>/dev/null || date -d "@$five_resets" "+%H:%M" 2>/dev/null)
    session_line="5h $bar (reset $resets_fmt)"
  else
    session_line="5h $bar"
  fi
else
  session_line=""
fi

# --- 7-day weekly rate limit ---
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_resets=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

if [ -n "$week_pct" ]; then
  week_pct_int=$(printf '%.0f' "$week_pct")
  bar=$(make_bar "$week_pct_int")
  if [ -n "$week_resets" ]; then
    week_resets_fmt=$(date -r "$week_resets" "+%a %H:%M" 2>/dev/null || date -d "@$week_resets" "+%a %H:%M" 2>/dev/null)
    week_line="7d $bar (reset $week_resets_fmt)"
  else
    week_line="7d $bar"
  fi
else
  week_line=""
fi

# --- Output ---
printf '%s' "$prompt_line"
printf '  |  %s' "$ctx_line"
[ -n "$session_line" ] && printf '  |  %s' "$session_line"
[ -n "$week_line" ]    && printf '  |  %s' "$week_line"
