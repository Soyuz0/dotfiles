#!/usr/bin/env bash
set -euo pipefail

# Detect OS
OS="$(uname -s)"
case "$OS" in
Linux*)
    PACKAGE_MANAGER="apt"
    INSTALL_CMD="sudo apt install -y"
    UPDATE_CMD="sudo apt update"
    ;;
Darwin*)
    PACKAGE_MANAGER="brew"
    INSTALL_CMD="brew install"
    UPDATE_CMD="brew update"
    ;;
*)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
esac

# Update package list
$UPDATE_CMD

# Install dependencies
$INSTALL_CMD make ripgrep unzip git xclip tmux neovim zsh fzf stow

# Handle Python and Node installation
if [ "$PACKAGE_MANAGER" = "apt" ]; then
    sudo add-apt-repository ppa:neovim-ppa/unstable -y || true
    sudo apt update
    sudo apt install -y python3.10-venv npm gcc
elif [ "$PACKAGE_MANAGER" = "brew" ]; then
    # Check for Xcode Command Line Tools
    if ! xcode-select -p &>/dev/null; then
        echo "Installing Xcode Command Line Tools..."
        xcode-select --install

        echo "Waiting for Xcode Command Line Tools to be installed..."
        until xcode-select -p &>/dev/null; do sleep 5; done
    fi

    echo "Xcode Command Line Tools detected at $(xcode-select -p)"

    brew install python@3.10 node gcc
fi

# Clone TPM if not exists
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
    echo "TPM already cloned."
fi

# Clone dotfiles if not exists
DOTFILES_DIR="${XDG_CONFIG_HOME:-$HOME/dotfiles}"
if [ ! -d "$DOTFILES_DIR/.git" ]; then
    git clone https://github.com/Soyuz0/dotfiles.git "$DOTFILES_DIR"
else
    echo "dotfiles repo already exists."
fi

# Stow configuration
cd "$DOTFILES_DIR"
stow .

# Set zsh as default shell if not already
if [ "$SHELL" != "$(which zsh)" ]; then
    ZSH_PATH="$(which zsh)"
    if ! grep -q "$ZSH_PATH" /etc/shells; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi
    chsh -s "$ZSH_PATH"
    echo "Zsh set as default shell. You may need to log out and log in again."
else
    echo "Zsh is already the default shell."
fi

# Start a new zsh shell and source the dotfiles zshrc
ZDOT="$DOTFILES_DIR/.zshrc"
if [ -f "$ZDOT" ]; then
    exec zsh -c "source $ZDOT; exec zsh"
else
    echo "Dotfiles .zshrc not found at $ZDOT"
fi
