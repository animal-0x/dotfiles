
#!/usr/bin/env bash

BACKUP_DIR="$HOME/.local/backups/dotfiles_$(date +%Y%m%d_%H%M%S)"

# Create essential base directories
mkdir -p ~/.local/{bin,share,state,backups}
mkdir -p ~/.cache ~/.config
mkdir -p ~/dev/{lab,oss,work,rice}
mkdir -p ~/.ssh/{config.d,controlmasters}
mkdir -p "$BACKUP_DIR"

# Process all configs
find "../home" -type f -not -name ".keep" | while read -r file; do
   rel_path="${file#../home/}"
   target_path="$HOME/$rel_path"
   target_dir="$(dirname "$target_path")"
   
   # Backup and prepare
   mkdir -p "$target_dir"
   [[ -e "$target_path" ]] && mv "$target_path" "$BACKUP_DIR/$rel_path"
   
   # Link/copy and set permissions
   if [[ "$rel_path" =~ ^\.ssh/ ]]; then
       cp "$file" "$target_path"
       chmod 600 "$target_path"
   else
       ln -sf "$file" "$target_path"
   fi
done

# Set directory permissions
chmod 700 ~/.ssh
chmod 700 ~/.ssh/config.d
chmod 700 ~/.ssh/controlmasters
