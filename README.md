# Dotfiles

The repository contains my public [dotfiles](https://wiki.archlinux.org/title/Dotfiles) used for my MacBook configuration.

I use this project to configure my development environment and tools in a predictable and reproducible way. By cloning this project, I can easily set up my development environment on a new machine.

So feel free to use it as a template for your own configuration by forking this repository.

## Pre-requisites

Brew is required to install the necessary packages. To install brew on a fresh system, run the following command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Dotfiles are linked to your home directory using the symbolic link manager [GNU Stow](https://www.gnu.org/software/stow/). To install stow, run the following command:

```bash
brew install stow
```

## Installation

A simple Makefile is provided to install the dotfiles and create the symbolic links. To install the dotfiles, run the following command:

```bash
make
```

You can check that private links are correctly created in your home directory by running the following command:

```bash
ls -la ~
```

## Usage

Simply edit the dotfiles in the cloned repository, commit and push your changes to your personal Github project, then run the `make` command to update the symbolic links.

Enjoy your new configuration!

## My applications configuration

### Brew

Instead of manually installing brew packages, I use a [brew bundle](https://github.com/Homebrew/homebrew-bundle) to declare the packages I want to install. Only the packages listed in the `Brewfile` are installed, which prevents forgetting to uninstall a package when it is no longer needed. Disk space and update time savings!

The `bbic` alias (for _brew bundle install cleanup_) defined in `~/.zshrc` ensures that the installed packages on my laptop are synced with the Brewfile definition located at `~/.config/brew/Brewfile`.

Running the `bbic` command on a regular basis ensures that your configuration is always up to date.

### Neovim

My very personal [neovim](https://neovim.io/) configuration is included in this repository. Major plugins are :

- [Lazy](https://github.com/folke/lazy.nvim) to manage neovim plugins
- [Telescope](https://github.com/nvim-telescope/telescope.nvim) to navigate through files and git repositories using fuzzy search
- [Mason](https://github.com/williamboman/mason.nvim) to manage LSP servers
- [Treesitter](https://github.com/nvim-treesitter/nvim-treesitter) to parse and highlight syntax
- [GitHub Copilot](https://github.com/github/copilot.vim) plugin to provide AI-powered code suggestions
- [conform](https://github.com/stevearc/conform.nvim) and [nvim-lint](https://github.com/mfussenegger/nvim-lint) to format and lint code
- [trouble](https://github.com/folke/trouble.nvim) and [todo-comments](https://github.com/folke/todo-comments.nvim) to manage code issues and todos
- [which-key](https://github.com/liuchengxu/vim-which-key) to display keybindings in a fancy popup
- [floaterm](https://github.com/voldikss/vim-floaterm) to provide a floating terminal window within neovim for quick commands
- [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua) as a file explorer

I prefered a personal setup over a pre-configured distribution such as [LazyVim](https://www.lazyvim.org/). It forced me to have a better understanding of the plugins I use and to configure them to fit my needs.

### Tmux

My very personal [tmux](https://github.com/tmux/tmux/wiki) configuration is included in this repository.
As I enjoy and feel more and more productive with terminal apps, I use tmux to facilitate my context switching between projects. As my position requires me to switch between projects very quickly, tmux is a must-have tool in my workflow.

I usually create a tmux session per project, and I can easily switch with a fuzzy-find custom tmux popup with a few keystrokes. The popup is powered by [fzf](https://github.com/junegunn/fzf).

[tmuxinator](https://github.com/tmuxinator/tmuxinator) manages my tmux "sessions-as-code". It defines the windows and panes settings and the commands to run in each pane at session creation.

I prefer defining my tmux sessions in a configuration file to manually saving them using a tmux plugin (such as tmux-resurrect). tmuxinator is the most popular tool to manage tmux sessions as code.

### Terminal - WezTerm

A minimal [WezTerm](https://wezfurlong.org/wezterm/) configuration is included in this repository so that I can enjoy a performant and nice looking terminal with native ligatures font support. I also tried iTerm2 and Kitty, but I prefer WezTerm for its simplicity, performance and configurability using a lua file (as neovim).

### Shell - Zsh

Common aliases and configurations are included in this repository.
The `~/.zshrc` file sources secrets from the `~/.secrets` file, which is not included in this repository for obvious security reasons.

### Prompt - Starship

A minimal prompt configuration powered by [starship](https://starship.rs/). Starship offers pretty decent default configurations and is easy to customize if required.
