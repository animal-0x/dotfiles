#!/bin/bash
# Core network tools
yay -S \
  nmap \
  iptraf-ng \
  tcpdump \
  nethogs \
  iftop \
  mtr \
  net-tools \
  bind

# Monitoring tools
yay -S \
  htop \
  btop \
  glances \
  goaccess \
  prometheus

# Security tools
yay -S \
  ufw \
  fail2ban \
  ethtool \
  macchanger

# Editors
yay -S \
  vim \
  neovim \
  micro

# Extra useful stuff
yay -S \
  tmux \
  sshfs \
  arp-scan \
  termshark \
  bandwhich

# Some packages might need to be installed from AUR
yay -S --needed \
  arpwatch-git \
  bandwhich-bin \
  termshark-bin
