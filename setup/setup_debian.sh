#!/usr/bin/env bash

# Exit on error, unset variables, and pipe failures
set -euo pipefail

# Script variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORIGINAL_DIR=$(pwd)
ARCH=$(dpkg --print-architecture)
LOG_DIR="$HOME/.local/log"
LOG_FILE="$LOG_DIR/setup-$(date +%Y%m%d-%H%M%S).log"

# Create log directory
mkdir -p "$LOG_DIR"

# Logging functions
log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }
log_error() { log "ERROR: $*" >&2; }
log_success() { log "SUCCESS: $*"; }
log_info() { log "INFO: $*"; }

# Cleanup trap
cleanup() {
    local exit_code=$?
    log "Cleaning up..."
    [[ -n "${TEMP_DIR:-}" ]] && rm -rf "$TEMP_DIR"
    [[ -n "${ORIGINAL_DIR:-}" ]] && cd "$ORIGINAL_DIR"
    if [[ $exit_code -ne 0 ]]; then
        log_error "Script failed. Check $LOG_FILE for details."
    fi
    exit $exit_code
}
trap cleanup EXIT

# Helper functions
check_command() {
    if ! "$@"; then
        log_error "Command failed: $*"
        return 1
    fi
}

check_dependency() {
    local cmd=$1
    if ! command -v "$cmd" >/dev/null 2>&1; then
        return 1
    fi
    return 0
}

install_basic_dependencies() {
    log "Installing basic build dependencies..."
    sudo apt-get update
    sudo apt-get install -y \
        build-essential \
        pkg-config \
        curl \
        git \
        libssl-dev \
        libfontconfig-dev \
        libfreetype-dev \
        libxkbcommon-dev \
        python3-pip \
        cmake
}

setup_mise() {
    if ! check_dependency mise; then
        log "Installing mise..."
        curl https://mise.run | sh
        
        # Add mise to current shell
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    # Configure mise and activate it
    log "Configuring mise..."
    export MISE_SKIP_ACTIVATE=1
    
    # Install core tools one by one
    log "Setting up Node.js..."
    mise use --global node@20
    
    log "Setting up Rust..."
    mise use --global rust@stable
    
    log "Setting up Go..."
    mise use --global go@latest
    
    log "Installing tools..."
    mise install

    # Since helix isn't directly supported by mise, we'll install it through cargo
    log "Installing Helix via Cargo..."
    mise x rust -- cargo install --git https://github.com/helix-editor/helix helix-term
    
    # Set up Helix runtime
    log "Setting up Helix runtime..."
    if [[ ! -d "$HOME/.config/helix/runtime" ]]; then
        git clone --depth=1 https://github.com/helix-editor/helix
        mkdir -p "$HOME/.config/helix"
        cp -r helix/runtime "$HOME/.config/helix/"
        rm -rf helix
    fi
    
    # Activate mise in current shell
    eval "$(mise activate bash)"
}

install_tools_via_mise() {
    log "Installing development tools via mise..."
    
    # Install language servers and tools via npm
    mise x node -- npm install -g \
        bash-language-server \
        typescript-language-server \
        vscode-langservers-extracted \
        yaml-language-server

    # Install Rust tools
    mise x rust -- cargo install \
        zellij \
        bandwhich \
        starship
}

install_system_tools() {
    log "Installing essential system tools..."
    sudo apt-get install -y \
        ripgrep \
        fd-find \
        fzf \
        bat \
        htop \
        btop \
        socat \
        tcpdump \
        iptraf-ng \
        nethogs \
        mtr \
        nmap \
        jq \
        ethtool \
        net-tools \
        fonts-noto \
        fonts-noto-cjk \
        fonts-noto-color-emoji
}

install_go_tools() {
    log "Installing Go tools..."
    mise x go -- go install filippo.io/age/cmd/...@latest
    mise x go -- go install github.com/mozilla/sops/v3/cmd/sops@latest
}

verify_installation() {
    log "Verifying installations..."
    local tools=(
        "hx:Helix"
        "zellij:Zellij"
        "starship:Starship"
        "age:Age"
        "sops:SOPS"
        "bash-language-server:Bash Language Server"
        "bandwhich:Bandwhich"
    )
    
    for tool in "${tools[@]}"; do
        local cmd=${tool%:*}
        local name=${tool#*:}
        if check_dependency "$cmd"; then
            local version
            version=$("$cmd" --version 2>/dev/null || echo 'version unknown')
            log_success "$name: $version"
        else
            log_error "$name: NOT FOUND"
        fi
    done
}

# Remove the setup_helix_runtime function as it's now handled during installation

main() {
    log "Starting setup with mise-focused installation..."
    
    # Essential setup
    install_basic_dependencies
    setup_mise
    
    # Tool installation
    install_tools_via_mise
    install_system_tools
    install_go_tools
    
    # Post-installation activities would go here if needed
    
    # Common setup and verification
    cd "$ORIGINAL_DIR"
    check_command ./setup_common.sh
    verify_installation
    
    log "Setup completed successfully! 🎉"
    log "Remember to restart your shell or run 'source ~/.bashrc' to use mise"
}

main "$@"
