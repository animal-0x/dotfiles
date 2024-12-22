#!/usr/bin/env bash

# Update package list
sudo apt update

# Install basic dependencies
sudo apt install -y \
    curl \
    git \
    gpg \
    sudo \
    wget \
    pkg-config \
    libssl-dev \
    build-essential \
    libfontconfig-dev \
    libfreetype-dev \
    libpixman-1-dev \
    libwayland-dev \
    libxkbcommon-dev \
    libutf8proc-dev \
    cargo \
    rustc \
    nushell

# Function to determine if we're running Wayland
is_wayland() {
    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
        return 0
    else
        return 1
    fi
}

# Install terminal emulator based on display server
if is_wayland; then
    # Install foot dependencies and build from source
    sudo apt install -y \
        pkg-config \
        libssl-dev \
        build-essential \
        libfontconfig-dev \
        libfreetype-dev \
        libpixman-1-dev \
        libwayland-dev \
        libxkbcommon-dev \
        libutf8proc-dev
    
    git clone https://codeberg.org/dnkl/foot.git
    cd foot
    meson build
    ninja -C build
    sudo ninja -C build install
    cd ..
    rm -rf foot
fi
# Install alacritty from apt
sudo apt install -y alacritty


# Install mise
sudo install -dm 755 /etc/apt/keyrings
wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null
echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
sudo apt update
sudo apt install -y mise

# Install starship
curl -sS https://starship.rs/install.sh | sh

# Install helix from pre-built binary
HELIX_VERSION="23.10" # Change this to latest version
wget https://github.com/helix-editor/helix/releases/download/${HELIX_VERSION}/helix-${HELIX_VERSION}-x86_64.tar.xz
tar -xvf helix-${HELIX_VERSION}-x86_64.tar.xz
sudo mv helix-${HELIX_VERSION}-x86_64/hx /usr/local/bin/
sudo mv helix-${HELIX_VERSION}-x86_64/runtime ~/.config/helix/
rm -rf helix-${HELIX_VERSION}-x86_64*

# Install foot
git clone https://codeberg.org/dnkl/foot.git
cd foot
meson build
ninja -C build
sudo ninja -C build install
cd ..
rm -rf foot

# Install zellij
cargo install --locked zellij

# Run our configuration scripts
./create_dirs.sh
./backup.sh
./copy_and_link.sh
./set_permissions.sh

echo "Ubuntu/Debian setup complete! 🎊"
