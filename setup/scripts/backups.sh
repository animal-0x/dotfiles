#!/usr/bin/env bash

# Create backup directory with timestamp
timestamp=$(date +%Y%m%d_%H%M%S)
backup_dir="$HOME/.local/backups/dotfiles_$timestamp"
mkdir -p "$backup_dir"

# Backup existing files
for file in \
    "$HOME/.bashrc" \
    "$HOME/.config/nushell/config.nu" \
    "$HOME/.config/nushell/env.nu" \
    "$HOME/.config/nushell/mise.nu" \
    "$HOME/.config/foot/foot.ini" \
    "$HOME/.config/helix/config.toml" \
    "$HOME/.config/zellij/config.kdl" \
    "$HOME/.config/starship/starship.toml" \
    "$HOME/.ssh/config" \
    "$HOME/.ssh/config.d/00-default" \
    "$HOME/.ssh/config.d/10-example"; do
    if [ -f "$file" ] || [ -L "$file" ]; then
        # Create parent directory structure in backup
        mkdir -p "$backup_dir/$(dirname "$file")"
        cp -P "$file" "$backup_dir/$file"
    fi
done

# Backup any existing zellij layouts
if [ -d "$HOME/.config/zellij/layouts" ]; then
    mkdir -p "$backup_dir/$HOME/.config/zellij/layouts"
    cp -r "$HOME/.config/zellij/layouts/"* "$backup_dir/$HOME/.config/zellij/layouts/" 2>/dev/null || true
fi

# Backup any existing .local/bin files
if [ -d "$HOME/.local/bin" ]; then
    mkdir -p "$backup_dir/$HOME/.local/bin"
    cp -r "$HOME/.local/bin/"* "$backup_dir/$HOME/.local/bin/" 2>/dev/null || true
fi

echo "Backup created in $backup_dir 🗄️"
