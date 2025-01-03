#!/usr/bin/env bash

# Check if yay is installed
if ! command -v yay &> /dev/null; then
   echo "Installing yay..."
   sudo pacman -S --needed git base-devel
   git clone https://aur.archlinux.org/yay.git
   cd yay
   makepkg -si
   cd ..
   rm -rf yay
fi

# Add chaotic-aur
if ! grep -q "chaotic-aur" /etc/pacman.conf; then
   echo "Adding chaotic-aur..."
   sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
   sudo pacman-key --lsign-key 3056513887B78AEB
   sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
   echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
fi

# Update system first
echo "Updating system..."
yay -Syu --noconfirm

# Install packages from file
echo "Installing packages..."
yay -S --needed --noconfirm $(grep -v '^#' "packages/yay")

# Run common setup script
./setup_common.sh

echo "Arch Linux setup complete! 🎊"
