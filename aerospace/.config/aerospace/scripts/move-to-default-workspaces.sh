#!/bin/bash
# Sweep every open window into the default workspace assigned to its app in
# aerospace.toml's on-window-detected rules, instead of only new windows
# getting sorted at creation time.
set -euo pipefail

CONFIG="$HOME/.config/aerospace/aerospace.toml"

# toml-x merge normalizes each [[on-window-detected]] block to:
#   run = [ "move-node-to-workspace X" ]
#   [on-window-detected.if]
#   app-id = "some.id"
# i.e. run comes BEFORE the app-id it applies to, with double-quoted strings.
mapping=$(awk '
  /^\[\[on-window-detected\]\]/ { ws = ""; appid = "" }
  /^run = / {
    if (match($0, /move-node-to-workspace [A-Za-z0-9]+/)) {
      ws = substr($0, RSTART + length("move-node-to-workspace "), RLENGTH - length("move-node-to-workspace "))
    }
  }
  /^app-id = / {
    match($0, /"[^"]+"/)
    appid = substr($0, RSTART + 1, RLENGTH - 2)
    if (appid != "" && ws != "") print appid, ws
  }
' "$CONFIG")

while IFS='|' read -r app_id window_id workspace; do
  target=$(awk -v id="$app_id" '$1 == id { print $2; exit }' <<< "$mapping")
  [ -z "$target" ] && continue
  [ "$target" = "$workspace" ] && continue
  aerospace move-node-to-workspace "$target" --window-id "$window_id"
done < <(aerospace list-windows --all --format '%{app-bundle-id}|%{window-id}|%{workspace}')
