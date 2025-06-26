#!/bin/bash
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install -y make gcc ripgrep unzip git xclip npm tmux python3.10-venv neovim zsh fzf stow
# brew install make gcc ripgrep unzip git xclip node tmux python@3.10 neovim zsh fzf stow
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
git clone https://github.com/Soyuz0/dotfiles.git "${XDG_CONFIG_HOME:-$HOME/dotfiles}"
cd "${XDG_CONFIG_HOME:-$HOME/dotfiles}"
stow .
