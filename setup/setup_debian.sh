#!/usr/bin/env bash

# Exit on error, unset variables, and pipe failures
set -euo pipefail

# Trap for cleanup and error handling
cleanup() {
    local exit_code=$?
    echo "Cleaning up..."
    if [[ -n "${TEMP_DIR:-}" ]]; then
        rm -rf "$TEMP_DIR"
    fi
    if [[ -n "${ORIGINAL_DIR:-}" ]]; then
        cd "$ORIGINAL_DIR"
    fi
    if [[ $exit_code -ne 0 ]]; then
        echo "Error: Script encountered problems. Check the output above for details."
    fi
    exit $exit_code
}
trap cleanup EXIT

# Store original directory
ORIGINAL_DIR=$(pwd)
TEMP_DIR=$(mktemp -d)
echo "Working directory: $TEMP_DIR"

# Helper function to check command success
check_command() {
    if ! "$@"; then
        echo "Error: Command failed: $*"
        return 1
    fi
}

# Detect architecture and set variables
ARCH=$(dpkg --print-architecture)
case "$ARCH" in
    arm64|aarch64)
        ARCH_SUFFIX="aarch64-linux-gnu"
        YQ_ARCH="arm64"
        HELIX_ARCH="aarch64-linux"
        NU_ARCH="aarch64-unknown-linux-gnu"
        ;;
    amd64|x86_64)
        ARCH_SUFFIX="x86_64-linux-gnu"
        YQ_ARCH="amd64"
        HELIX_ARCH="x86_64-linux"
        NU_ARCH="x86_64-unknown-linux-gnu"
        ;;
    armv7)
        ARCH_SUFFIX="armv7-linux-gnueabihf"
        YQ_ARCH="arm"
        HELIX_ARCH="armv7-linux"
        NU_ARCH="armv7-unknown-linux-gnueabihf"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Helper function for getting latest GitHub release URL
get_latest_release_url() {
    local repo="$1"
    local pattern="$2"
    local url
    url=$(curl -sL "https://api.github.com/repos/$repo/releases/latest" | \
        jq -r --arg PATTERN "$pattern" '.assets[] | select(.browser_download_url | contains($PATTERN)) | .browser_download_url' | \
        head -n1)
    if [[ -z "$url" ]]; then
        echo "Error: Could not find release matching pattern '$pattern' for repo '$repo'" >&2
        return 1
    fi
    echo "$url"
}

# Helper function for installing binaries
install_binary() {
    local name="$1"
    local url="$2"
    local dest="${3:-/usr/local/bin/$(basename "$name")}"
    local temp_file
    
    echo "Installing $name from $url..."
    temp_file=$(mktemp)
    if ! wget -q "$url" -O "$temp_file"; then
        echo "Failed to download $name"
        rm -f "$temp_file"
        return 1
    fi
    chmod +x "$temp_file"
    if ! sudo mv "$temp_file" "$dest"; then
        echo "Failed to install $name to $dest"
        rm -f "$temp_file"
        return 1
    fi
}

# Add package repositories
echo "Setting up package repositories..."
{
    # Mise
    sudo install -dm 755 /etc/apt/keyrings
    wget -qO - https://mise.jdx.dev/gpg-key.pub | \
        sudo gpg --dearmor -o /etc/apt/keyrings/mise-archive-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=$ARCH] https://mise.jdx.dev/deb stable main" | \
        sudo tee /etc/apt/sources.list.d/mise.list

    # GitHub CLI
    wget -qO - https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
        sudo dd of=/etc/apt/keyrings/github-cli.gpg
    echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/github-cli.gpg] https://cli.github.com/packages stable main" | \
        sudo tee /etc/apt/sources.list.d/github-cli.list
} >/dev/null 2>&1

# Update system and install base packages
echo "Installing base packages..."
check_command sudo apt-get update
xargs sudo apt-get install -y < <(grep -v '^#' "packages/apt")

# Install Rust toolchain
echo "Installing Rust toolchain..."
if ! command -v cargo &> /dev/null; then
    check_command curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# Install cargo-based tools
echo "Installing cargo tools..."
check_command cargo install --locked zellij bandwhich

# Install Starship prompt
echo "Installing Starship..."
check_command curl -sS https://starship.rs/install.sh | sudo sh -s -- -y

# Install Nushell
echo "Installing Nushell..."
cd "$TEMP_DIR"
NU_URL=$(get_latest_release_url "nushell/nushell" "$NU_ARCH.tar.gz")
check_command wget "$NU_URL"
check_command tar xf nu-*-"${NU_ARCH}".tar.gz
echo "Installing Nushell binaries..."
find . -type f -name "nu" -exec sudo install -Dm755 {} /usr/local/bin/nu \;
find . -type f -name "nu_plugin_*" -exec sudo install -Dm755 {} /usr/local/bin/ \;

# Install Helix editor
echo "Installing Helix..."
cd "$TEMP_DIR"
HELIX_URL=$(get_latest_release_url "helix-editor/helix" "$HELIX_ARCH.tar.xz")
check_command wget "$HELIX_URL"
check_command tar xf helix-*-"${HELIX_ARCH}".tar.xz
helix_dir=$(find . -type d -name "helix-*-${HELIX_ARCH}" | head -n1)
if [[ -z "$helix_dir" ]]; then
    echo "Error: Could not find Helix directory after extraction"
    exit 1
fi
sudo mkdir -p /usr/local/lib/helix
sudo cp -r "${helix_dir}/runtime" /usr/local/lib/helix/
check_command sudo install -Dm755 "${helix_dir}/hx" /usr/local/bin/hx

# Install Age
echo "Installing Age..."
cd "$TEMP_DIR"
check_command curl -Lo age.tar.gz "https://dl.filippo.io/age/latest?for=linux/${ARCH}"
check_command tar xf age.tar.gz
check_command sudo install -Dm755 age/age /usr/local/bin/
check_command sudo install -Dm755 age/age-keygen /usr/local/bin/

# Install yq
echo "Installing yq..."
cd "$TEMP_DIR"
YQ_URL=$(get_latest_release_url "mikefarah/yq" "linux_${YQ_ARCH}")
check_command install_binary "yq" "$YQ_URL"

# Install SOPS
echo "Installing SOPS..."
cd "$TEMP_DIR"
SOPS_VERSION=$(curl -sL https://api.github.com/repos/getsops/sops/releases/latest | jq -r '.tag_name')
SOPS_URL="https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.${ARCH}"
check_command install_binary "sops" "$SOPS_URL"

# Install bat
echo "Installing bat..."
cd "$TEMP_DIR"
BAT_URL=$(get_latest_release_url "sharkdp/bat" "${ARCH}.deb")
check_command wget "$BAT_URL"
check_command sudo dpkg -i bat_*_${ARCH}.deb

# Run common setup
echo "Running common setup..."
cd "$ORIGINAL_DIR"
check_command ./setup_common.sh

# Verify installations
echo "✅ Setup complete! Verifying installations..."
(
    set +e
    echo "🔨 Installed tools:"
    echo "  • Nushell: $(nu --version 2>/dev/null || echo 'NOT FOUND')"
    echo "  • Helix: $(hx --version 2>/dev/null || echo 'NOT FOUND')"
    echo "  • Starship: $(starship --version 2>/dev/null || echo 'NOT FOUND')"
    echo "  • Zellij: $(zellij --version 2>/dev/null || echo 'NOT FOUND')"
    echo "  • Age: $(age --version 2>/dev/null || echo 'NOT FOUND')"
    echo "  • SOPS: $(sops --version 2>/dev/null || echo 'NOT FOUND')"
    echo "  • yq: $(yq --version 2>/dev/null || echo 'NOT FOUND')"
)
