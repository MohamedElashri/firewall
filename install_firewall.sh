#!/bin/bash

# Check if the script is being run with sudo or as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with sudo or as root." 
    exit 1
fi

# Set the installation directory
INSTALL_DIR="/usr/local/bin"

# Set the script name
SCRIPT_NAME="firewall"

# Download the firewall script
wget -O "$SCRIPT_NAME" "https://raw.githubusercontent.com/MohamedElashri/firewall/main/firewall.sh"

# Make the script executable
chmod +x "$SCRIPT_NAME"

# Move the script to the installation directory
mv "$SCRIPT_NAME" "$INSTALL_DIR"

# Check if the installation was successful
if [ $? -eq 0 ]; then
    echo "The firewall cli has been successfully installed."
    echo "You can now use the 'firewall' command from the shell."
else
    echo "An error occurred during the installation."
    exit 1
fi
