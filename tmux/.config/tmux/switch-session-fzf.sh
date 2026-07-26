#!/bin/bash
# Fuzzy-pick a tmuxinator project and switch to it, starting it if needed.

find -L ~/.tmuxinator/ -type f -maxdepth 1 \
  | xargs -n 1 basename \
  | cut -d . -f 1 \
  | fzf-tmux -p --reverse --no-info --border-label ' 😍 Switch tmux session ' \
  | xargs -I % sh -c 'tmuxinator s %; tmux switch-client -t %;'
