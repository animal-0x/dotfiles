#!/usr/bin/env bash
set -euo pipefail

# Store the original directory
ORIGINAL_DIR=$(pwd)

# Detect architecture
ARCH=$(dpkg --print-architecture)

# Add mise repository (works across Debian-based systems)
echo "Adding mise repository..."
sudo install -dm 755 /etc/apt/keyrings
wget -qO - https://mise.jdx.dev/gpg-key.pub | sudo gpg --dearmor -o /etc/apt/keyrings/mise-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=$ARCH] https://mise.jdx.dev/deb stable main" | \
    sudo tee /etc/apt/sources.list.d/mise.list

# Add GitHub CLI repository
wget -qO - https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/etc/apt/keyrings/github-cli.gpg
echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/github-cli.gpg] https://cli.github.com/packages stable main" | \
    sudo tee /etc/apt/sources.list.d/github-cli.list

# Update and install packages from packages/apt
echo "Installing packages from packages/apt..."
sudo apt update
sudo apt install -y $(grep -v '^#' "packages/apt")

# Install fastfetch from source (works on both architectures)
echo "Installing fastfetch..."
git clone https://github.com/fastfetch-cli/fastfetch.git
cd fastfetch
mkdir -p build
cd build
cmake ..
cmake --build . --target fastfetch --target flashfetch
sudo cmake --install .
cd "$ORIGINAL_DIR"  # Return to the original directory
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

# Install starship (latest version)
echo "Installing starship..."
STARSHIP_VERSION=$(curl -s https://api.github.com/repos/starship/starship/releases/latest | jq -r .tag_name)
curl -sS "https://starship.rs/install.sh" | sudo sh -s -- -y

# Install Nushell (latest version)
echo "Installing Nushell..."
NUSHELL_VERSION=$(curl -s https://api.github.com/repos/nushell/nushell/releases/latest | jq -r .tag_name)

# Map architecture to GitHub's naming convention
case "$ARCH" in
    arm64|aarch64)
        ARCH_DOWNLOAD="aarch64-unknown-linux-gnu"
        ;;
    amd64|x86_64)
        ARCH_DOWNLOAD="x86_64-unknown-linux-gnu"
        ;;
    armv7)
        ARCH_DOWNLOAD="armv7-unknown-linux-gnueabihf"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        ;;
esac

DOWNLOAD_URL="https://github.com/nushell/nushell/releases/download/$NUSHELL_VERSION/nu-$NUSHELL_VERSION-$ARCH_DOWNLOAD.tar.gz"

echo "Downloading Nushell from: $DOWNLOAD_URL"
mkdir -p /tmp/nushell
cd /tmp/nushell
wget "$DOWNLOAD_URL"
tar xvf "nu-$NUSHELL_VERSION-$ARCH_DOWNLOAD.tar.gz"

# Find the nu binary
NU_BINARY=$(find . -type f -name "nu" | head -n 1)

if [ -z "$NU_BINARY" ]; then
    echo "Warning: Could not find nu binary"
else
    echo "Found binary at: $NU_BINARY"
    sudo install -Dm755 "$NU_BINARY" /usr/local/bin/nu
fi

# Clean up
cd "$ORIGINAL_DIR"
rm -rf /tmp/nushell

# Install Age (multi-arch support)
echo "Installing age..."
mkdir -p /tmp/age && cd /tmp/age
curl -Lo age.tar.gz "https://dl.filippo.io/age/latest?for=linux/$ARCH"
tar xf age.tar.gz
sudo install -Dm755 age/age* -t /usr/local/bin/
cd "$ORIGINAL_DIR" && rm -rf /tmp/age

# Install yq using binary release (multi-arch support)
echo "Installing yq..."
YQ_VERSION=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | jq -r .tag_name)
sudo wget "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_$ARCH" -O /usr/local/bin/yq
sudo chmod +x /usr/local/bin/yq

# Install SOPS (multi-arch support)
echo "Installing SOPS..."
SOPS_VERSION=$(curl -s https://api.github.com/repos/getsops/sops/releases/latest | jq -r .tag_name)
echo "Latest SOPS version: v${SOPS_VERSION}"
sudo wget -O /usr/local/bin/sops "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.$ARCH"
sudo chmod +x /usr/local/bin/sops

# Install bat using binary release (multi-arch support)
echo "Installing bat..."
BAT_VERSION=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | jq -r .tag_name)
wget "https://github.com/sharkdp/bat/releases/download/${BAT_VERSION}/bat_${BAT_VERSION#v}_$ARCH.deb"
sudo dpkg -i "bat_${BAT_VERSION#v}_$ARCH.deb"
rm "bat_${BAT_VERSION#v}_$ARCH.deb"

# Install Helix (latest version)
echo "Installing Helix..."
HELIX_VERSION=$(curl -s https://api.github.com/repos/helix-editor/helix/releases/latest | jq -r .tag_name)

# Map architecture to GitHub's naming convention
case "$ARCH" in
    arm64|aarch64)
        ARCH_DOWNLOAD="aarch64-linux"
        ;;
    amd64|x86_64)
        ARCH_DOWNLOAD="x86_64-linux"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        ;;
esac

DOWNLOAD_URL="https://github.com/helix-editor/helix/releases/download/${HELIX_VERSION}/helix-${HELIX_VERSION}-${ARCH_DOWNLOAD}.tar.xz"

echo "Downloading Helix from: $DOWNLOAD_URL"
mkdir -p /tmp/helix
cd /tmp/helix
wget "$DOWNLOAD_URL"
tar -xvf "helix-${HELIX_VERSION}-${ARCH_DOWNLOAD}.tar.xz"

# Find the helix binary
HELIX_BINARY=$(find . -type f -name "hx" | head -n 1)

if [ -z "$HELIX_BINARY" ]; then
    echo "Warning: Could not find Helix binary"
else
    echo "Found Helix binary at: $HELIX_BINARY"
    sudo install -Dm755 "$HELIX_BINARY" /usr/local/bin/hx
    sudo cp -r "helix-${HELIX_VERSION}-${ARCH_DOWNLOAD}/runtime" /usr/local/lib/helix/
fi

# Clean up
cd "$ORIGINAL_DIR"
rm -rf /tmp/helix

# Run common setup script
echo "Running common setup..."
cd "$ORIGINAL_DIR"  # Ensure we're back in the setup directory
./setup_common.sh

echo "Setup complete! 🎊"
