#!/usr/bin/env bash
set -euo pipefail

# Add mise repository (works across Debian-based systems)
echo "Adding mise repository..."
sudo install -dm 755 /etc/apt/keyrings
wget -qO - https://mise.jdx.dev/gpg-key.pub | sudo gpg --dearmor -o /etc/apt/keyrings/mise-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | \
    sudo tee /etc/apt/sources.list.d/mise.list

# Add GitHub CLI repository
wget -qO - https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/etc/apt/keyrings/github-cli.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/github-cli.gpg] https://cli.github.com/packages stable main" | \
    sudo tee /etc/apt/sources.list.d/github-cli.list

# Update and install packages from packages/apt
echo "Installing packages from packages/apt..."
sudo apt update
sudo apt install -y $(grep -v '^#' "packages/apt")

# Install fastfetch from source
echo "Installing fastfetch..."
git clone https://github.com/fastfetch-cli/fastfetch.git
cd fastfetch
mkdir -p build
cd build
cmake ..
cmake --build . --target fastfetch --target flashfetch
sudo cmake --install .
cd ../..
rm -rf fastfetch

# Install Rust toolchain
echo "Installing Rust toolchain..."
if ! command -v cargo &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# Install cargo-based tools
echo "Installing cargo-based tools..."
cargo install --locked zellij
cargo install bandwhich

# Install starship
echo "Installing starship..."
curl -sS https://starship.rs/install.sh | sudo sh -s -- -y

# Install Nushell
echo "Installing Nushell..."
NUSHELL_VERSION="0.91.0"
wget "https://github.com/nushell/nushell/releases/download/$NUSHELL_VERSION/nu-$NUSHELL_VERSION-x86_64-linux-gnu-full.tar.gz"
tar xf "nu-$NUSHELL_VERSION-x86_64-linux-gnu-full.tar.gz"
sudo install -Dm755 "nu-$NUSHELL_VERSION-x86_64-linux-gnu-full/nu"* -t /usr/local/bin/
rm -rf "nu-$NUSHELL_VERSION-x86_64-linux-gnu-full"*

# Install Age
echo "Installing age..."
mkdir -p /tmp/age && cd /tmp/age
curl -Lo age.tar.gz "https://dl.filippo.io/age/latest?for=linux/amd64"
tar xf age.tar.gz
sudo install -Dm755 age/age* -t /usr/local/bin/
cd - && rm -rf /tmp/age

# Install yq using binary release
echo "Installing yq..."
YQ_VERSION=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
sudo wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -O /usr/local/bin/yq
sudo chmod +x /usr/local/bin/yq

# Install SOPS
echo "Installing SOPS..."
SOPS_VERSION=$(curl -s https://api.github.com/repos/getsops/sops/releases/latest | grep -oP '"tag_name": "v\K[^"]*')
echo "Latest SOPS version: v${SOPS_VERSION}"
sudo wget -O /usr/local/bin/sops "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64"
sudo chmod +x /usr/local/bin/sops

# Install bat using binary release
echo "Installing bat..."
BAT_VERSION=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
wget "https://github.com/sharkdp/bat/releases/download/${BAT_VERSION}/bat_${BAT_VERSION#v}_amd64.deb"
sudo dpkg -i "bat_${BAT_VERSION#v}_amd64.deb"
rm "bat_${BAT_VERSION#v}_amd64.deb"

# Install Helix
echo "Installing Helix..."
HELIX_VERSION=$(curl -s https://api.github.com/repos/helix-editor/helix/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
echo "Latest Helix version: ${HELIX_VERSION}"
wget "https://github.com/helix-editor/helix/releases/download/${HELIX_VERSION}/helix-${HELIX_VERSION}-x86_64-linux.tar.xz"
tar -xvf "helix-${HELIX_VERSION}-x86_64-linux.tar.xz"
sudo cp -r "helix-${HELIX_VERSION}-x86_64-linux/runtime" /usr/local/lib/helix/
sudo install -Dm755 "helix-${HELIX_VERSION}-x86_64-linux/hx" -t /usr/local/bin/
rm -rf "helix-${HELIX_VERSION}-x86_64-linux"*

# Run common setup script
echo "Running common setup..."
./setup_common.sh

echo "Setup complete! 🎊"
