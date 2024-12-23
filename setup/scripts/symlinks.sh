#!/usr/bin/env bash

# 1. Remove existing files/symlinks
for file in \
    "$HOME/.bashrc" \
    "$HOME/.config/nushell/config.nu" \
    "$HOME/.config/nushell/env.nu" \
    "$HOME/.config/nushell/mise.nu" \
    "$HOME/.config/foot/foot.ini" \
    "$HOME/.config/alacritty/alacritty.toml" \
    "$HOME/.config/helix/config.toml" \
    "$HOME/.config/zellij/config.kdl" \
    "$HOME/.config/starship/starship.toml" \
    "$HOME/.ssh/config" \
    "$HOME/.ssh/config.d/00-default" \
    "$HOME/.ssh/config.d/10-example"; do
    rm -f "$file"
done

# Remove any existing zellij layouts
rm -rf "$HOME/.config/zellij/layouts/"*

# 2. Create symlinks for regular config files
ln -sf "$HOME/dev/rice/dotfiles/.bashrc" "$HOME/.bashrc"
ln -sf "$HOME/dev/rice/dotfiles/.config/nushell/config.nu" "$HOME/.config/nushell/config.nu"
ln -sf "$HOME/dev/rice/dotfiles/.config/nushell/env.nu" "$HOME/.config/nushell/env.nu"
ln -sf "$HOME/dev/rice/dotfiles/.config/nushell/mise.nu" "$HOME/.config/nushell/mise.nu"
ln -sf "$HOME/dev/rice/dotfiles/.config/foot/foot.ini" "$HOME/.config/foot/foot.ini"
ln -sf "$HOME/dev/rice/dotfiles/.config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
ln -sf "$HOME/dev/rice/dotfiles/.config/helix/config.toml" "$HOME/.config/helix/config.toml"
ln -sf "$HOME/dev/rice/dotfiles/.config/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"
ln -sf "$HOME/dev/rice/dotfiles/.config/starship/starship.toml" "$HOME/.config/starship/starship.toml"

# Copy (not symlink) SSH configs
cp "$HOME/dev/rice/dotfiles/.ssh/config" "$HOME/.ssh/config"
cp "$HOME/dev/rice/dotfiles/.ssh/config.d/00-default" "$HOME/.ssh/config.d/00-default"
cp "$HOME/dev/rice/dotfiles/.ssh/config.d/10-example" "$HOME/.ssh/config.d/10-example"

# Symlink any zellij layouts
for layout in "$HOME/dev/rice/dotfiles/.config/zellij/layouts/"*; do
    if [ -f "$layout" ]; then
        ln -sf "$layout" "$HOME/.config/zellij/layouts/$(basename "$layout")"
    fi
done

# Copy all bin files 
cp -r "$HOME/dev/rice/dotfiles/.local/bin/"* "$HOME/.local/bin/" 2>/dev/null || true

echo "Files removed and symlinks created! 🔗"
