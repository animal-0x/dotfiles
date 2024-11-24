#!/usr/bin/env nu

def print_step [message: string] {
    print $"(ansi cyan)→(ansi reset) ($message)"
}

def main [] {
    print_step "Setting up dotfiles..."
    
    # We're already in .config, so just use relative paths
    
    # Clean up old symlinks first
    rm -f ~/.config/nushell/config.nu
    rm -f ~/.config/nushell/env.nu
    rm -f ~/.config/nushell/mise.nu
    rm -f ~/.config/starship/starship.toml
    rm -f ~/.config/foot/foot.ini
    rm -f ~/.config/zellij/config.kdl
    rm -rf ~/.config/zellij/layouts
    
    # Create directories if needed
    mkdir ~/.config/nushell ~/.config/starship ~/.config/foot ~/.config/zellij/layouts

    # Nushell configs
    print_step "Linking Nushell configs..."
    ln -sf ($env.PWD | path join "nushell" "config.nu") ~/.config/nushell/config.nu
    ln -sf ($env.PWD | path join "nushell" "env.nu") ~/.config/nushell/env.nu
    ln -sf ($env.PWD | path join "nushell" "mise.nu") ~/.config/nushell/mise.nu

    # Starship config
    print_step "Linking Starship config..."
    ln -sf ($env.PWD | path join "starship" "starship.toml") ~/.config/starship/starship.toml

    # Foot config
    print_step "Linking Foot config..."
    ln -sf ($env.PWD | path join "foot" "foot.ini") ~/.config/foot/foot.ini

    # Zellij config
    print_step "Linking Zellij config..."
    ln -sf ($env.PWD | path join "zellij" "config.kdl") ~/.config/zellij/config.kdl
    

    print_step "Done! 🚀"
}
