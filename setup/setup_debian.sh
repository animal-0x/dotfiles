#!/usr/bin/env bash

# Add PPAs and external sources
echo "Adding external package sources..."

# Add all repositories
sudo add-apt-repository -y ppa:maveonair/helix-editor
sudo add-apt-repository -y ppa:fastfetch/stable
sudo add-apt-repository -y ppa:aslatter/ppa

# Mise
sudo install -dm 755 /etc/apt/keyrings
wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null
echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list

# GitHub CLI
wget -O- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

# Update system and install apt packages
echo "Updating system and installing packages..."
sudo apt update && sudo apt upgrade -y
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

# Install fastfetch from source
git clone https://github.com/fastfetch-cli/fastfetch.git
cd fastfetch
mkdir -p build
cd build
cmake ..
cmake --build . --target fastfetch --target flashfetch
sudo cmake --install .
cd ../..
rm -rf fastfetch

# yq - install latest binary
YQ_VERSION=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -O /usr/bin/yq
chmod +x /usr/bin/yq

# SOPS - install latest release
SOPS_VERSION=$(curl -s https://api.github.com/repos/mozilla/sops/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
wget -O /usr/local/bin/sops https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64
chmod +x /usr/local/bin/sops

# Nushell - install latest release
wget https://github.com/nushell/nushell/releases/download/0.91.0/nu-0.91.0-x86_64-linux-gnu-full.tar.gz
tar xzvf nu-0.91.0-x86_64-linux-gnu-full.tar.gz
sudo cp nu-0.91.0-x86_64-unknown-linux-gnu/nu* /usr/local/bin/
rm -rf nu-0.91.0-x86_64-unknown-linux-gnu*

# Run common setup script
echo "Running common setup..."
./setup_common.sh

echo "Debian setup complete! 🎊"
