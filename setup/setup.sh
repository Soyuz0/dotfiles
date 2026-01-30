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

# Install core dependencies
$INSTALL_CMD make ripgrep unzip git tmux neovim zsh fzf stow zoxide fd eza atuin fastfetch

# Install OpenCode
brew install anomalyco/tap/opencode || npm install -g opencode-ai

# Install Oh-My-Zsh if not exists
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    # Remove the default .zshrc created by oh-my-zsh (we'll stow our own)
    rm -f "$HOME/.zshrc"
else
    echo "Oh-My-Zsh already installed."
fi

# Install Powerlevel10k theme for Oh-My-Zsh
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    echo "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
    echo "Powerlevel10k already installed."
fi

# Handle Python and Node installation
if [ "$PACKAGE_MANAGER" = "apt" ]; then
    sudo add-apt-repository ppa:neovim-ppa/unstable -y || true
    sudo apt update
    sudo apt install -y python3.10-venv npm gcc xclip cargo
    
    # Install grip-grab (gg) via cargo for pymple.nvim
    echo "Installing grip-grab (gg) for pymple.nvim..."
    cargo install grip-grab || true
    
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
    
    # Install gnu-sed (required by pymple.nvim)
    echo "Installing gnu-sed..."
    brew install gnu-sed
    
    # Install rust and grip-grab (gg) for pymple.nvim
    echo "Installing rust and grip-grab (gg) for pymple.nvim..."
    brew install rust
    cargo install grip-grab || true
fi

# Add cargo bin to PATH for current session if it exists
if [ -d "$HOME/.cargo/bin" ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# macOS-specific tools
if [ "$OS" = "Darwin" ]; then
    echo "Installing macOS-specific tools..."
    
    # Window management and status bar
    $INSTALL_CMD lua
    
    # Tap FelixKratz formulae for SketchyBar and Borders
    echo "Tapping FelixKratz/formulae for SketchyBar and Borders..."
    brew tap FelixKratz/formulae || true
    
    # Install SketchyBar (formula, not cask)
    echo "Installing SketchyBar..."
    $INSTALL_CMD sketchybar
    
    # Install Borders
    echo "Installing Borders..."
    $INSTALL_CMD borders
    
    # Install Aerospace
    echo "Installing Aerospace..."
    brew install --cask nikitabobko/tap/aerospace
    
    # Optional but recommended
    $INSTALL_CMD wget
    $INSTALL_CMD jq
    $INSTALL_CMD switchaudio-osx
    $INSTALL_CMD nowplaying-cli
    $INSTALL_CMD thefuck
    $INSTALL_CMD htop
    
    # Fonts for SketchyBar
    echo "Installing fonts..."
    brew install --cask font-hack-nerd-font
    brew install --cask font-fira-code-nerd-font
    
    # SketchyBar app font
    echo "Downloading SketchyBar app font..."
    mkdir -p "$HOME/Library/Fonts"
    curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.25/sketchybar-app-font.ttf -o "$HOME/Library/Fonts/sketchybar-app-font.ttf"
    
    # SbarLua (enables Lua support for SketchyBar)
    echo "Building SbarLua for SketchyBar Lua support..."
    (git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/) || true
    
    # Build SketchyBar helper binaries (after stow creates the symlinks)
    echo "Building SketchyBar helper binaries..."
fi

# Clone TPM (Tmux Plugin Manager) if not exists
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
    echo "TPM already installed."
fi

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

# Stow all packages
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DOTFILES_DIR"

echo "Stowing dotfiles..."
stow shell       # Symlinks: ~/.zshrc, ~/.p10k.zsh
stow tools       # Symlinks: ~/.config/nvim, ~/.config/tmux, ~/.config/ghostty, etc.
stow window-mgmt # Symlinks: ~/.aerospace.toml, ~/.config/sketchybar, ~/.config/borders

# macOS: Build SketchyBar helpers after stow
if [ "$OS" = "Darwin" ]; then
    echo "Building SketchyBar helper binaries..."
    (cd ~/.config/sketchybar/helpers && make) || true
fi

echo "Setup complete!"

# macOS: Start services
if [ "$OS" = "Darwin" ]; then
    echo "Starting services on macOS..."
    
    # Try the formulae tap first, fallback to generic name
    brew services start felixkratz/formulae/sketchybar || brew services start sketchybar
    brew services start felixkratz/formulae/borders || brew services start borders
    
    echo "SketchyBar and Borders services are now running"
    echo "Service status:"
    brew services list | grep -E "sketchybar|borders"
fi

# Start a new zsh shell
echo "Starting new zsh shell..."
exec zsh
