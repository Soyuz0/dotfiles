# Run fastfetch on terminal start (before instant prompt)
fastfetch

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations or custom commands) must go above this block; everything else may go below.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(git zoxide fzf vi-mode)

source $ZSH/oh-my-zsh.sh

# User configuration
export EDITOR='nvim'
export MANPAGER='nvim +Man!'

# Fix for Ghostty terminal - ensure tmux works properly
if [[ "$TERM" == "xterm-ghostty" ]]; then
  # If xterm-ghostty terminfo isn't available, fall back to xterm-256color
  if ! infocmp xterm-ghostty &>/dev/null; then
    export TERM=xterm-256color
  fi
fi

# Add cargo bin to PATH (for grip-grab/gg and other rust tools)
[[ -d "$HOME/.cargo/bin" ]] && export PATH="$HOME/.cargo/bin:$PATH"

# Add gnu-sed to PATH on macOS (for pymple.nvim)
[[ -d "/opt/homebrew/opt/gnu-sed/libexec/gnubin" ]] && export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"

# Unalias gg from oh-my-zsh git plugin (conflicts with grip-grab binary)
unalias gg 2>/dev/null || true

# Aliases
alias vi='nvim'
alias vim='nvim'
alias ls='eza -la'
alias cd='z'
alias c='clear'

# Initialize atuin (shell history)
eval "$(atuin init zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


