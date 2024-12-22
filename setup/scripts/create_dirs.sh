#!/usr/bin/env bash

# Create XDG base directories
mkdir -p ~/.local/{bin,share,state,backups}
mkdir -p ~/.cache
mkdir -p ~/.config

# Create development directories
mkdir -p ~/dev/{lab,oss,work,rice}

# Create configuration directories
mkdir -p ~/.config/{nushell,foot,helix,zellij/layouts,starship}

# Create SSH directories with proper permissions
mkdir -p ~/.ssh/{config.d,controlmasters}

echo "Directories created! 🚀"
