
#!/usr/bin/env bash

echo "Creating base directories..."
# Create essential base directories
mkdir -p ~/.local/{bin,share,state,backups}
mkdir -p ~/.cache ~/.config
mkdir -p ~/dev/{lab,oss,work,rice}

echo "Setting up SSH directories..."
# Setup SSH structure
mkdir -p ~/.ssh/{config.d,controlmasters}
chmod 700 ~/.ssh
chmod 700 ~/.ssh/config.d
chmod 700 ~/.ssh/controlmasters

echo "Linking configurations..."
# Call refresh_links to handle all symlinking
./refresh_links.sh

echo "Spawning local configs"
touch ~/.config/foot/local.ini

echo "Common setup complete!"
