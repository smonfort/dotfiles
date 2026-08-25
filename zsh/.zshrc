# Use linux like config folder
export XDG_CONFIG_HOME="$HOME/.config"

# French date/time formatting (used by tmux status bar strftime)
export LC_TIME="fr_FR.UTF-8"

# Set neovim as the default editor
export EDITOR='vim'

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

# Add wisely, as too many plugins slow down shell startup.
plugins=(git dotenv zsh-autosuggestions zsh-syntax-highlighting mise ssh-agent)

# Load zsh-vi-mode
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# Custom aliases
alias m="mise"
alias v="nvim"
alias vim="nvim"
alias vi="nvim"
alias nv="nvim"
alias tm="tmuxinator"
alias tf="terraform"
alias vl="vault login -method=oidc"
alias lg="lazygit"
alias p="pnpm"
# alias docker="podman"
alias g="glab"
alias cc="claude"
alias rsa="brew services restart sketchybar && killall AeroSpace && sleep 2 && open -a AeroSpace"

# Ensure dependencies are up to date and remove unused ones
bbic() {
  brew update
  local tmpfile
  tmpfile=$(mktemp)
  cat ~/.config/brew/Brewfile* > "$tmpfile"
  brew bundle install --file "$tmpfile" --force-cleanup --jobs auto
  rm -f "$tmpfile"
  brew upgrade -y
  brew upgrade --cask -y
}

# Run chrome for MCP
alias chrome-debug='open -a "Google Chrome" --args --remote-debugging-port=9222 --user-data-dir="$HOME/chrome-debug-profile"'

# Load secrets if they exist
[ -f ~/.secrets ] && source ~/.secrets

# Load corporate zshrc if it exists
[ -f ~/.corporate_zshrc ] && source ~/.corporate_zshrc

# Enable FZH
eval "$(fzf --zsh)"

# Append uv binaries to PATH
export PATH="$HOME/.local/bin:$PATH"
# Required for psql
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Should be at the end of the file for starship to work
eval "$(starship init zsh)"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export PATH="/opt/homebrew/opt/ffmpeg-full/bin:$PATH"
eval "$(mise activate zsh)"
