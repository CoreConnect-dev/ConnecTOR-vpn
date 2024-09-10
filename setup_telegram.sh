#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Install telegram-send
apt-get update
apt-get install -y telegram-send

# Configure telegram-send
echo "Starting telegram-send configuration..."
telegram-send --configure

# Test telegram-send configuration
echo "Testing telegram-send configuration..."
telegram-send "Telegram setup complete! You can now receive notifications from your VPS."

# Output final instructions
echo "Telegram setup is complete."
echo "You can now use telegram-send to send messages from your VPS."
echo "Next, you can run your main setup script."
