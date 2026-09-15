#!/bin/bash
# Runs inside a tmux popup (see sesh-popup.sh), hence plain fzf not fzf-tmux.

# tokyonight "night" palette, same as nvim (nvim/.config/nvim/plugin/00-colorscheme.lua)
TOKYONIGHT_FZF='fg:#c0caf5,bg:#000000,hl:#7aa2f7,fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff,info:#565f89,prompt:#7aa2f7,pointer:#f7768e,marker:#9ece6a,spinner:#7aa2f7,header:#565f89,border:#3b4261,label:#c0caf5'

sesh connect "$(
  sesh list --icons --hide-duplicates | fzf --no-sort --ansi --layout=reverse --color="$TOKYONIGHT_FZF" --pointer=' ' --border-label ' sesh ' --prompt '»  ' \
    --info=hidden \
    --footer '⏎ switch   ⌃D kill' \
    --bind 'tab:down,btab:up' \
    --bind 'ctrl-a:change-prompt(»  )+reload(sesh list --icons --hide-duplicates)' \
    --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
    --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
    --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
    --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
    --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(»  )+reload(sesh list --icons --hide-duplicates)'
)"
