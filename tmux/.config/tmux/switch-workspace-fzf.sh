#!/bin/bash
# Fuzzy-pick an AeroSpace workspace that has at least one window and switch to it.

focused=$(aerospace list-workspaces --focused)

aerospace list-windows --all --format $'%{workspace}\t%{app-name}' \
  | sort -u \
  | awk -F'\t' '
      $1 != prev { if (prev != "") print prev "\t" apps; apps=$2; prev=$1; next }
      { apps = apps "," $2 }
      END { if (prev != "") print prev "\t" apps }
    ' \
  | while IFS=$'\t' read -r ws apps; do
      icon="○"
      [ "$ws" = "$focused" ] && icon="●"
      printf '%s\t%s %s — %s\n' "$ws" "$icon" "$ws" "$apps"
    done \
  | fzf-tmux -p --reverse --no-info --border-label ' 🖥️  Switch AeroSpace workspace ' \
      --delimiter=$'\t' --with-nth=2 \
  | cut -f1 \
  | xargs -I{} aerospace workspace {}
