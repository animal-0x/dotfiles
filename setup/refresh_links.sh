#!/usr/bin/env bash

# Strict mode
set -euo pipefail

# Core variables with absolute paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$(cd "$(dirname "$SCRIPT_DIR")/home" && pwd)"
BACKUP_DIR="$HOME/.local/backups/dotfiles_$(date +%Y%m%d_%H%M%S)"

# Verification
if [[ ! -d "$HOME_DIR" ]]; then
    echo "Error: home directory not found at $HOME_DIR" >&2
    exit 1
fi

if [[ ! -w "$HOME" ]]; then
    echo "Error: no write permission in $HOME" >&2
    exit 1
fi

# Setup
echo "Creating backup directory..."
mkdir -p "$BACKUP_DIR"

# Enable recursive globbing
shopt -s dotglob nullglob globstar

echo "Processing all files..."
for file in "$HOME_DIR"/**/*; do
    # Skip directories and .keep files
    [[ -d "$file" || "${file##*/}" == ".keep" ]] && continue
    
    # Calculate paths
    rel_path="${file#$HOME_DIR/}"
    target_path="$HOME/$rel_path"
    target_dir="$(dirname "$target_path")"
    
    # Create target directory
    mkdir -p "$target_dir"
    
    # Backup existing file/link
    if [[ -e "$target_path" || -L "$target_path" ]]; then
        backup_dir="$(dirname "$BACKUP_DIR/$rel_path")"
        mkdir -p "$backup_dir"
        mv "$target_path" "$BACKUP_DIR/$rel_path"
    fi
    
    # Create symlink
    ln -sf "$file" "$target_path"
    
done

echo "Refresh complete! Backups stored in $BACKUP_DIR"
