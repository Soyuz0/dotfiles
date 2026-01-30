# Dotfiles Setup Guide

A comprehensive macOS configuration with:
- **Window Management**: Aerospace for tiling window management
- **Status Bar**: SketchyBar with Lua configuration
- **Window Borders**: JankyBorders for enhanced window borders
- **Terminal**: Shell configuration with Zsh, Starship, and Neovim
- **Tool Management**: Organized directory structure using GNU Stow

## Directory Structure

```
dotfiles/
├── shell/                       # Shell configuration (stows to ~/)
│   ├── .zshrc                  # Zsh configuration
│   └── .p10k.zsh              # Powerlevel10k theme
│
├── tools/                       # Development tools (stows to ~/.config/)
│   └── .config/
│       ├── nvim/              # Neovim configuration
│       ├── tmux/              # Tmux configuration
│       ├── ghostty/           # Ghostty terminal configuration
│       ├── cspell/            # Code spell checker configuration
│       ├── ruff/              # Python linter configuration
│       ├── opencode/          # OpenCode CLI configuration
│       ├── cspell.json        # CSpell settings
│       └── pycodestyle        # Python style settings
│
├── window-mgmt/                 # Window management (stows to ~/ and ~/.config/)
│   ├── .aerospace.toml        # Aerospace window manager config (stows to ~/)
│   └── .config/
│       ├── sketchybar/        # Status bar configuration (Lua)
│       │   ├── sketchybarrc   # Main entry point
│       │   ├── init.lua       # Module initialization
│       │   ├── bar.lua        # Bar configuration
│       │   ├── colors.lua     # Color palette
│       │   ├── icons.lua      # Icon definitions
│       │   ├── settings.lua   # Theme settings
│       │   ├── default.lua    # Default item styling
│       │   ├── items/         # Bar item definitions
│       │   └── helpers/       # Helper utilities
│       └── borders/           # JankyBorders configuration
│           └── bordersrc      # Borders settings
│
├── setup/                       # Setup and installation scripts
│   └── setup.sh               # Main setup script
│
├── .stow-ignore               # Files to exclude from stow
└── SETUP.md                   # This documentation
```

## Quick Start

### Prerequisites
- macOS
- Xcode Command Line Tools (will be installed automatically)
- Homebrew (optional, but recommended)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

2. Run the setup script:
```bash
./setup/setup.sh
```

The script will:
- Install all required dependencies via Homebrew
- Install macOS-specific tools (Aerospace, SketchyBar, Borders)
- Build SbarLua for SketchyBar Lua support
- Set Zsh as the default shell
- Symlink all configurations to the appropriate locations using Stow
- Start SketchyBar and Borders services

## Tool Configuration

### SketchyBar
Located in `window-mgmt/sketchybar/`

Key files:
- `sketchybarrc` - Entry point (Lua)
- `init.lua` - Initialization and module loading
- `bar.lua` - Bar appearance and settings
- `settings.lua` - Theme and styling configuration
- `colors.lua` - Color palette
- `icons.lua` - Icon definitions
- `default.lua` - Default item styling
- `items/` - Individual bar item definitions
- `helpers/` - Utility functions

After modifying the configuration, reload SketchyBar:
```bash
sketchybar --reload
```

### Borders
Located in `window-mgmt/borders/`

Configuration in `bordersrc`:
- `style=round` - Border style
- `width=6.0` - Border width
- `active_color` - Color for focused windows
- `inactive_color` - Color for unfocused windows

Reload borders:
```bash
borders restart
```

### Aerospace
Located in `.aerospace.toml`

This is your window tiling configuration. Refer to the Aerospace documentation for customization.

## Customization

### Adding New Tools
1. Create a new directory in the dotfiles root
2. Add your configuration files
3. Update `.stow-ignore` if needed
4. Run `stow <dirname>` to symlink

### Updating Stow Links

The dotfiles are organized into stow packages that symlink to the correct locations:

```bash
stow shell       # → ~/.zshrc, ~/.p10k.zsh
stow tools       # → ~/.config/nvim, ~/.config/tmux, etc.
stow window-mgmt # → ~/.aerospace.toml, ~/.config/sketchybar, ~/.config/borders
```

If you modify the directory structure:
```bash
# Restow specific packages
cd ~/dotfiles
stow shell --restow
stow tools --restow
stow window-mgmt --restow

# Or unstow and restow
stow -D shell && stow shell
```

## Maintenance

### Update Dependencies
```bash
brew update
brew upgrade
```

### Check SketchyBar Status
```bash
brew services list | grep sketchybar
```

### Enable/Disable Services
```bash
# Start
brew services start sketchybar
brew services start borders

# Stop
brew services stop sketchybar
brew services stop borders

# Restart
brew services restart sketchybar
brew services restart borders
```

## Troubleshooting

### SketchyBar Not Starting
1. Check if Lua is installed: `lua --version`
2. Verify SbarLua was built: `pkg-config --cflags --libs sketchybar`
3. Check permissions: `ls -la ~/.config/sketchybar/`

### Borders Not Working
1. Verify installation: `which borders`
2. Check if running: `brew services list | grep borders`
3. Restart service: `brew services restart borders`

### Stow Conflicts
If you have existing dotfiles in your home directory:
```bash
# Backup existing files
mkdir ~/dotfiles_backup
mv ~/.zshrc ~/dotfiles_backup/  # etc.

# Then run stow
stow shell
```

## Resources

- [Aerospace](https://github.com/nikitabobko/AeroSpace)
- [SketchyBar](https://github.com/FelixKratz/SketchyBar)
- [JankyBorders](https://github.com/FelixKratz/JankyBorders)
- [GNU Stow](https://www.gnu.org/software/stow/)
- [Neovim](https://neovim.io/)
- [Zsh](https://www.zsh.org/)

## License

[Add your license information here]
