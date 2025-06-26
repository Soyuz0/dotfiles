#!/bin/bash
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install -y make gcc ripgrep unzip git xclip npm tmux python3.10-venv neovim
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# git clone https://github.com/Soyuz0/config_files.git "${XDG_CONFIG_HOME:-$HOME/.config}"
# git init "${XDG_CONFIG_HOME:-$HOME/.config}"
# cd "${XDG_CONFIG_HOME:-$HOME/.config}"
# git remote add origin https://github.com/Soyuz0/config_files.git
# git fetch
# git checkout -t origin/main
# brew install make gcc ripgrep unzip git xclip node tmux python@3.10 neovim
#
# ZSH
sudo apt install -y zsh fzf stow
