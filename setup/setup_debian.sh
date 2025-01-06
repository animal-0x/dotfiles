#!/usr/bin/env bash

set -e

# Install packages from apt list
echo "Installing apt packages..."
sudo apt-get update
sudo apt-get install -y $(grep -v '^#' "packages/apt")

# Install mise if not present
if ! command -v mise &> /dev/null; then
    echo "Installing mise..."
    curl https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# Activate mise
eval "$(mise activate bash)"

# Install language runtimes first
echo "Installing language runtimes..."
mise use --global node@lts
mise use --global rust@stable
mise use --global go@latest

# Install core tools via mise
echo "Installing development tools..."
tools=(
    "node@latest"
    "cargo:nu@latest"
    "zellij@latest"
    "starship@latest"
    "ripgrep@latest"
    "fd@latest"
    "fzf@latest"
    "jq@latest"
    "gh@latest"
    "shellcheck@latest"
    "shfmt@latest"
    "zoxide@latest"
    "eza@latest"
    "bat@latest"
)

for tool in "${tools[@]}"; do
    mise use --global "$tool"
done

# Build foot terminal
if ! command -v foot &> /dev/null; then
    echo "Building foot..."
    git clone https://codeberg.org/dnkl/foot.git
    cd foot
    meson setup build
    ninja -C build
    sudo ninja -C build install
    cd ..
    rm -rf foot
fi

# Install Helix
# Store the original directory
original_dir=$(pwd)

# Create a temporary directory
tmp_dir=$(mktemp -d)
cd "$tmp_dir"

# Clone the repository
git clone https://github.com/helix-editor/helix
cd helix

# Build and install
cargo install --path helix-term --locked

# Prepare the runtime directory in ~/.config/helix
if [ -e ~/.config/helix/runtime ]; then
    rm -rf ~/.config/helix/runtime
fi
mkdir -p ~/.config/helix
cp -r runtime ~/.config/helix/

# Create symlink in cargo bin directory
cargo_bin_dir=$(dirname $(which hx))
ln -s ~/.config/helix/runtime "$cargo_bin_dir/runtime"

# Verify installation
hx --health

# Return to the original directory and clean up
cd "$original_dir"
rm -rf "$tmp_dir"

# Install bash language server
npm install -g bash-language-server

bash-language-server --help
hx --health

# Run common setup
./setup_common.sh

echo "Setup complete! 🎊"
