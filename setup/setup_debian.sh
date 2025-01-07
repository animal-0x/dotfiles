#!/usr/bin/env bash
set -euo pipefail

TMP_DIR="/tmp/setup-tools"
ARCH="$(dpkg --print-architecture)"
WORKING_DIR="$(pwd)"

# Clean start
sudo rm -rf "${TMP_DIR}"
mkdir -p "${TMP_DIR}"

# Install a binary from GitHub releases
install_github_binary() {
    local repo="$1"
    local binary="$2"
    local path="$3"
    local is_archive="${4:-true}"
    
    version=$(curl -sL "https://api.github.com/repos/${repo}/releases/latest" | 
              grep '"tag_name":' | 
              sed -E 's/.*"([^"]+)".*/\1/')
    version_clean=${version#v}
    
    url="https://github.com/${repo}/releases/download/${version}/${path//\{VERSION\}/${version_clean}}"
    
    echo "Installing ${binary}"
    mkdir -p "${TMP_DIR}/bin"
    cd "${TMP_DIR}/bin"
    
    if [ "$is_archive" = true ]; then
        curl -L "$url" | tar xz
    else
        curl -L "$url" -o "${binary}"
        chmod +x "${binary}"
    fi
    
    sudo install "${TMP_DIR}/bin/${binary}" /usr/local/bin/
    cd "${WORKING_DIR}"
    sudo rm -f "${binary}"
}

# Install apt packages
cd "${WORKING_DIR}"
sudo apt-get update
sudo apt-get install -y $(grep -v '^#\|^$' "packages/apt")

# Install mise
cd "${WORKING_DIR}"
curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
eval "$(mise activate bash)"

# Install language runtimes and tools
cd "${WORKING_DIR}"
mise use --global "node@lts" "rust@stable" "go@latest" "python@latest" \
    "cargo:nu@latest" "zellij@latest" "starship@latest" \
    "ripgrep@latest" "fd@latest" "fzf@latest" "jq@latest" "gh@latest" \
    "shellcheck@latest" "shfmt@latest" "zoxide@latest" "eza@latest" \
    "bat@latest" "cargo:watchexec-cli@latest" "cargo:just@latest" \
    "meson@latest" "cmake@latest" 

# Map Debian architectures
case "${ARCH}" in
    "amd64") 
        arch_croc="64bit"
        arch_lazygit="x86_64"
        ;;
    "arm64") 
        arch_croc="ARM64"
        arch_lazygit="arm64"
        ;;
    "armhf") 
        arch_croc="ARM"
        arch_lazygit="armv6"
        ;;
    "i386") 
        arch_croc="32bit"
        arch_lazygit="386"
        ;;
    *) 
        arch_croc="${ARCH}"
        arch_lazygit="${ARCH}"
        ;;
esac

# Install GitHub tools
cd "${WORKING_DIR}"
install_github_binary "mozilla/sops" "sops" "sops-v{VERSION}.linux.${ARCH}" false
install_github_binary "mikefarah/yq" "yq" "yq_linux_${ARCH}" false
install_github_binary "jesseduffield/lazygit" "lazygit" "lazygit_{VERSION}_Linux_${arch_lazygit}.tar.gz" true
install_github_binary "FiloSottile/age" "age" "age-{VERSION}-linux-${ARCH}" false
install_github_binary "johnkerl/miller" "mlr" "miller_{VERSION}_Linux-${ARCH}" false
install_github_binary "schollz/croc" "croc" "croc_v{VERSION}_Linux-${arch_croc}.tar.gz" true

# Install Helix
cd "${TMP_DIR}"
git clone https://github.com/helix-editor/helix
cd helix
cargo install --path helix-term --locked

# Setup Helix runtime
HELIX_RUNTIME_PATH="$(dirname $(which hx))/runtime"
mkdir -p "${HOME}/.config/helix"
rm -rf "${HOME}/.config/helix/runtime"
cp -r "${TMP_DIR}/helix/runtime" "${HOME}/.config/helix/"
ln -sf "${HOME}/.config/helix/runtime" "${HELIX_RUNTIME_PATH}"

# Install foot
cd "${TMP_DIR}"
git clone https://codeberg.org/dnkl/foot
cd foot
meson setup build
ninja -C build
sudo ninja -C build install

# Install bash language server
cd "${WORKING_DIR}"
npm install -g bash-language-server
sudo rm -rf node_modules

# Final cleanup
cd "${WORKING_DIR}"
sudo rm -rf "${TMP_DIR}"

# Run common setup
./setup_common.sh
