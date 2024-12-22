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

# Load aliases if they exist
[ -f ~/.bash_aliases ] && source ~/.bash_aliases

# Basic prompt if starship fails
PS1='[\u@\h \W]\$ '

# Enable common bash options
shopt -s checkwinsize  # Update window size after each command
shopt -s histappend   # Append to history instead of overwriting
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth # Ignore duplicates and commands starting with space
