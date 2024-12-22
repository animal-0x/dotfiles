# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Environment variables (following XDG)
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# Default programs
export EDITOR="hx"
export VISUAL="hx"
export TERMINAL="foot"
export BROWSER="firefox"

# Path additions
export PATH="$HOME/.local/bin:$PATH"

# mise setup
eval "$(mise activate bash)"

# Use starship prompt
eval "$(starship init bash)"

# Aliases
# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -lah'
alias la='ls -A'

# Development directories
alias dev='cd ~/dev'
alias work='cd ~/dev/work'
alias oss='cd ~/dev/oss'
alias lab='cd ~/dev/lab'
alias rice='cd ~/dev/rice'

# Development tools
alias hx='helix'
alias g='git'
alias gst='git status'
alias gd='git diff'
alias gc='git commit'
alias gp='git push'
alias gl='git log --graph --abbrev-commit --decorate --format=format:"%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)" --all'


# System updates
if command -v yay &> /dev/null; then
    # Update both EndeavourOS and Arch mirrors, then update system
    alias update='sudo eos-rankmirrors && yay --noconfirm'
elif command -v apt &> /dev/null; then
    alias update='sudo apt update && sudo apt upgrade'
fi

# Basic prompt if starship fails
PS1='[\u@\h \W]\$ '

# Enable common bash options
shopt -s checkwinsize  # Update window size after each command
shopt -s histappend   # Append to history instead of overwriting
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth # Ignore duplicates and commands starting with space
