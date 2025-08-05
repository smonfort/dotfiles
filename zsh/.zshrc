# Use linux like config folder
export XDG_CONFIG_HOME="$HOME/.config"

# Set neovim as the default editor
export EDITOR='vim'

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

# Add wisely, as too many plugins slow down shell startup.
plugins=(git dotenv zsh-autosuggestions zsh-syntax-highlighting)

# Load zsh-vi-mode
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# Custom aliases
alias m="make"
alias v="nvim"
alias vim="nvim"
alias vi="nvim"
alias nv="nvim"
alias tm="tmuxinator"
alias tf="terraform"
alias vl="vault login -method=oidc"
alias ma="make apply"
alias mp="make plan"
alias ml="make lint"
alias lg="lazygit"
alias p="pnpm"
alias docker="podman"
alias g="glab"

# Ensure dependencies are up to date and remove unused ones 
alias bbic="brew update && brew bundle install --file ~/.config/brew/Brewfile --cleanup && brew upgrade"

# Load secrets if they exist
[ -f ~/.secrets ] && source ~/.secrets

# Load corporate zshrc if it exists
[ -f ~/.corporate_zshrc ] && source ~/.corporate_zshrc

# Enable FZH
eval "$(fzf --zsh)"

# Append asdf shims to PATH
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
# Append uv binaries to PATH
export PATH="$HOME/.local/bin:$PATH"

# Load asdf plugins if they are not already loaded with silent output
asdf plugin add terraform > /dev/null 2>&1
asdf plugin add pulumi > /dev/null 2>&1
asdf plugin add nodejs > /dev/null 2>&1
asdf plugin add helm > /dev/null 2>&1


# Should be at the end of the file for starship to work
eval "$(starship init zsh)"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
