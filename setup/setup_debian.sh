#!/usr/bin/env bash

# Exit on error, unset variables, and pipe failures
set -euo pipefail
trap 'echo "Error on line $LINENO"' ERR

# Script constants
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TMP_DIR="/tmp/setup-tools"
readonly ARCH="$(dpkg --print-architecture)"
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

# Logging functions
log() { echo -e "${GREEN}==>${NC} $1"; }
error() { echo -e "${RED}Error:${NC} $1" >&2; }

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    error "This script should not be run as root"
    exit 1
fi

# Clean start with fresh temporary directory
cleanup() {
    log "Cleaning up temporary files..."
    sudo rm -rf "${TMP_DIR}"
}
trap cleanup EXIT
sudo rm -rf "${TMP_DIR}"
mkdir -p "${TMP_DIR}"

# Install a binary from GitHub releases
install_github_binary() {
    local repo="$1"
    local binary="$2"
    local path="$3"
    local dest="${4:-/usr/local/bin}"
    
    log "Installing ${binary} from ${repo}"
    
    # Get latest release version
    local version
    version=$(curl -sL "https://api.github.com/repos/${repo}/releases/latest" | 
              grep '"tag_name":' | 
              sed -E 's/.*"([^"]+)".*/\1/')
    local version_clean=${version#v}
    
    # Generate download URL
    local url="https://github.com/${repo}/releases/download/${version}/${path//\{VERSION\}/${version_clean}}"
    local tmp_path="${TMP_DIR}/${binary}"
    local archive_path="${TMP_DIR}/archive"
    
    log "Downloading from: ${url}"
    
    # Create a subdirectory for extraction
    mkdir -p "${archive_path}"
    
    # Download and install based on file type
    case "${url}" in
        *.tar.gz|*.tgz)
            # Download to a temporary file first
            curl -sSL "$url" -o "${tmp_path}.tar.gz"
            
            # Extract to the archive directory
            if ! tar xzf "${tmp_path}.tar.gz" -C "${archive_path}"; then
                error "Failed to extract archive for ${binary}"
                return 1
            fi
            
            # Find the binary in the extracted contents
            local found_binary
            found_binary=$(find "${archive_path}" -type f -name "${binary}")
            
            if [ -z "${found_binary}" ]; then
                error "Could not find ${binary} in extracted archive"
                return 1
            fi
            
            sudo install "${found_binary}" "${dest}/"
            ;;
        *.zip)
            # Download and unzip
            curl -sSL "$url" -o "${tmp_path}.zip"
            unzip -q "${tmp_path}.zip" -d "${archive_path}"
            
            local found_binary
            found_binary=$(find "${archive_path}" -type f -name "${binary}")
            
            if [ -z "${found_binary}" ]; then
                error "Could not find ${binary} in extracted archive"
                return 1
            fi
            
            sudo install "${found_binary}" "${dest}/"
            ;;
        *)
            # Direct binary download
            if ! curl -sSL "$url" -o "${tmp_path}"; then
                error "Failed to download ${binary}"
                return 1
            fi
            chmod +x "${tmp_path}"
            sudo install "${tmp_path}" "${dest}/"
            ;;
    esac
    
    # Verify installation
    if command -v "${binary}" >/dev/null 2>&1; then
        log "${binary} installed successfully"
    else
        error "${binary} installation failed"
        return 1
    fi
}

# Install system packages
install_system_packages() {
    log "Updating package lists..."
    sudo apt-get update
    
    log "Installing system packages..."
    # Read package list, ignoring comments and empty lines
    local packages
    packages=$(grep -v '^#\|^$' "${SCRIPT_DIR}/packages/apt")
    
    # Check which packages need to be installed
    local to_install=()
    for pkg in $packages; do
        if ! dpkg -l "$pkg" &>/dev/null; then
            to_install+=("$pkg")
        fi
    done
    
    if [ ${#to_install[@]} -eq 0 ]; then
        log "All system packages are already installed"
    else
        log "Installing ${#to_install[@]} packages..."
        sudo apt-get install -y "${to_install[@]}"
    fi
}

# Install mise and development tools
install_mise() {
    log "Installing mise..."
    if ! command -v mise &>/dev/null; then
        curl https://mise.run | sh
    fi
    
    export PATH="$HOME/.local/bin:$PATH"
    eval "$(mise activate bash)"
    
    # Install language runtimes
    log "Installing language runtimes..."
    local runtimes=(
        "node@lts"
        "rust@stable"
        "go@latest"
        "python@latest"
    )
    
    for runtime in "${runtimes[@]}"; do
        mise use --global "$runtime"
    done
    
    # Install development tools
    log "Installing development tools..."
    local tools=(
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
        "cargo:watchexec-cli@latest"
        "cargo:just@latest"
    )
    
    for tool in "${tools[@]}"; do
        mise use --global "$tool"
    done
}

# Install tools from GitHub releases
install_github_tools() {
    log "Installing tools from GitHub releases..."
    local tools=(
        #working "mozilla/sops sops sops-{VERSION}.linux.${ARCH}"
        #working "mikefarah/yq yq yq_linux_${ARCH}"
        #broken check ver "jesseduffield/lazygit lazygit lazygit_{VERSION}_Linux_${ARCH}.tar.gz"
        # gzip error "FiloSottile/age age age-{VERSION}-linux-${ARCH}.tar.gz"
        # gzip "johnkerl/miller mlr miller_{VERSION}_Linux-${ARCH}.tar.gz"
        # gzip "schollz/croc croc croc_{VERSION}_Linux-${ARCH}.tar.gz"
    )
    
    for tool in "${tools[@]}"; do
        read -r repo binary path <<< "$tool"
        install_github_binary "$repo" "$binary" "$path"
    done
}

# Install Helix editor
install_helix() {
    log "Installing Helix editor..."
    if ! command -v hx &>/dev/null; then
        cd "${TMP_DIR}"
        git clone https://github.com/helix-editor/helix
        cd helix
        cargo install --path helix-term --locked
        
        # Install runtime files
        mkdir -p ~/.config/helix
        rm -rf ~/.config/helix/runtime
        cp -r runtime ~/.config/helix/
        
        # Link runtime to cargo bin directory
        cargo_bin_dir=$(dirname "$(which hx)")
        ln -sf ~/.config/helix/runtime "$cargo_bin_dir/runtime"
    else
        log "Helix is already installed"
    fi
}

# Install foot terminal
install_foot() {
    log "Installing foot terminal..."
    if ! command -v foot &>/dev/null; then
        cd "${TMP_DIR}"
        git clone https://codeberg.org/dnkl/foot
        cd foot
        meson setup build
        ninja -C build
        sudo ninja -C build install
    else
        log "Foot is already installed"
    fi
}

# Install additional language servers and tools
install_language_servers() {
    log "Installing language servers..."
    
    # Bash language server
    if ! command -v bash-language-server &>/dev/null; then
        npm install -g bash-language-server
    fi
    
    # Add more language servers as needed
}

# Main installation sequence
main() {
    log "Starting installation for ${ARCH} architecture..."
    
    install_system_packages
    install_mise
    install_github_tools
    install_helix
    install_foot
    install_language_servers
    
    # Run common setup script
    log "Running common setup..."
    "${SCRIPT_DIR}/setup_common.sh"
    
    log "Installation complete! 🎉"
}

main "$@"
