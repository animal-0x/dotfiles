# Dotfiles Bootstrap

A minimal development environment setup focusing on modern, ergonomic tools:
- Terminal emulators: 
    - foot (Wayland)
    - alacritty (X11)
- Core tools:
    - helix (modal editor)
    - zellij (terminal multiplexer)
    - nushell (modern shell)
    - starship (cross-shell prompt)

## Quick Start

### 1. Clone the repository and make scripts executable
```bash
git clone https://github.com/animal-0x/dotfiles.git ~/dev/rice/dotfiles
cd ~/dev/rice/dotfiles/setup
chmod +x *.sh
```

### 2. Initial Setup
Choose the appropriate setup script for your system:

```bash
# Arch Linux / EndeavourOS
./setup_arch.sh     # Installs packages and sets up configs

# Debian / Ubuntu
./setup_debian.sh   # Installs packages and sets up configs
```

### 3. Updating Configs
If you've already run the initial setup and just want to update configurations:

```bash
./refresh_links.sh  # Backs up existing configs and recreates symlinks
```

## Structure
```
dotfiles/
├── home/                # User configurations
│   ├── .config/        # XDG config directory
│   │   ├── foot        # Wayland terminal
│   │   ├── alacritty   # X11 terminal
│   │   ├── helix       # Editor configs
│   │   ├── nushell     # Shell configs
│   │   ├── starship    # Prompt configs
│   │   └── zellij      # Terminal multiplexer
│   ├── .local/bin/     # User scripts
│   └── .ssh/           # SSH configurations
└── setup/
    ├── packages/       # Package lists by platform
    │   ├── apt        # Debian/Ubuntu packages
    │   └── yay        # Arch Linux packages
    ├── setup_arch.sh   # Arch setup script
    ├── setup_debian.sh # Debian setup script
    ├── setup_common.sh # Base directory setup
    └── refresh_links.sh # Config management
```

## Features
- One-command system setup
- Safe automated backups
- Modular configuration
- XDG compliance
- Secure by default

## Adding New Configurations
1. Add files to the appropriate directory under `home/`
2. Run `./refresh_links.sh` to update symlinks

Your old configs will be automatically backed up to `~/.local/backups/dotfiles_<timestamp>/`

## Platform Support
- ✓ Arch Linux / EndeavourOS (complete)
- ⚡ Debian / Ubuntu (in development)
- 🚧 More platforms planned

## Contributing
Pull requests welcome! Please ensure your contributions:
- Follow XDG base directory specs
- Include documentation
- Maintain cross-platform compatibility where possible

## License
MIT
