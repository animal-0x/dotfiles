
#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$(dirname "$SCRIPT_DIR")/home"
BACKUP_DIR="$HOME/.local/backups/dotfiles_$(date +%Y%m%d_%H%M%S)"

if [[ ! -d "$HOME_DIR" ]]; then
    echo "Error: home directory not found at $HOME_DIR"
    exit 1
fi

echo "Creating backup directory..."
mkdir -p "$BACKUP_DIR"

# Process config files
echo "Processing config files..."
find "$HOME_DIR/.config" -type f -not -name ".keep" | while read -r file; do
    rel_path="${file#$HOME_DIR/}"
    target_path="$HOME/$rel_path"
    target_dir="$(dirname "$target_path")"
    
    mkdir -p "$target_dir"
    [[ -e "$target_path" ]] && mv "$target_path" "$BACKUP_DIR/$rel_path"
    ln -sf "$file" "$target_path"
done

# Process bin scripts
echo "Processing bin scripts..."
find "$HOME_DIR/.local/bin" -type f -not -name ".keep" | while read -r file; do
    rel_path="${file#$HOME_DIR/}"
    target_path="$HOME/$rel_path"
    target_dir="$(dirname "$target_path")"
    
    mkdir -p "$target_dir"
    [[ -e "$target_path" ]] && mv "$target_path" "$BACKUP_DIR/$rel_path"
    ln -sf "$file" "$target_path"
    chmod +x "$target_path"
done

echo "Refresh complete! Backups stored in $BACKUP_DIR"
