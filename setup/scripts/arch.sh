#!/usr/bin/env bash

# Install core packages using pacman
sudo pacman -S --needed \
    foot \
    alacritty \
    helix \
    zellij \
    nushell \
    git \
    curl \
    base-devel \
    starship


# Install mise
curl https://mise.run | sh

# Run our configuration scripts in order
./create_dirs.sh
./backups.sh
./symlinks.sh
./permissions.sh

echo "Arch Linux setup complete! 🎊"
