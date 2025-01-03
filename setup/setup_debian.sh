#!/usr/bin/env bash

# Add PPAs and external sources
echo "Adding external package sources..."

# Helix Editor PPA
sudo add-apt-repository -y ppa:maveonair/helix-editor

# Fastfetch PPA 
sudo add-apt-repository -y ppa:fastfetch/stable

# Mise
sudo install -dm 755 /etc/apt/keyrings
wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null
echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list

# Update system first
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# Install packages from apt.list
echo "Installing packages from apt..."
sudo apt install -y $(grep -v '^#' "packages/apt")

# Install Rust toolchain for cargo installs
echo "Installing Rust toolchain..."
if ! command -v cargo &> /dev/null; then
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
   source "$HOME/.cargo/env"
fi

# Install tools that need cargo
echo "Installing cargo-based tools..."
cargo install --locked zellij
cargo install bandwhich

# Install starship
echo "Installing starship..."
curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install Age
echo "Installing age..."
mkdir -p /tmp/age && cd /tmp/age
curl -Lo age.tar.gz https://dl.filippo.io/age/latest?for=linux/amd64
tar xf age.tar.gz
sudo mv age/age /usr/local/bin/
sudo mv age/age-keygen /usr/local/bin/
cd - && rm -rf /tmp/age

# Install latest nushell from release
echo "Installing nushell..."
NUSHELL_VERSION=$(curl -s https://api.github.com/repos/nushell/nushell/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
curl -Lo nushell.deb "https://github.com/nushell/nushell/releases/download/${NUSHELL_VERSION}/nu_${NUSHELL_VERSION#v}_amd64.deb"
sudo dpkg -i nushell.deb
rm nushell.deb

# Install latest SOPS from release
echo "Installing SOPS..."
SOPS_VERSION=$(curl -s https://api.github.com/repos/mozilla/sops/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
curl -Lo sops.deb "https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops_${SOPS_VERSION#v}_amd64.deb"
sudo dpkg -i sops.deb
rm sops.deb

# Run common setup script
echo "Running common setup..."
./setup_common.sh

echo "Debian setup complete! 🎊"
