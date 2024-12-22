#!/usr/bin/env bash

# SSH directory permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
chmod 700 ~/.ssh/config.d
chmod 700 ~/.ssh/controlmasters

# All files in config.d should be 600
find ~/.ssh/config.d -type f -exec chmod 600 {} \;

# Executable permissions for all scripts in .local/bin
find ~/.local/bin -type f -exec chmod +x {} \;

echo "Permissions set! 🔒"
