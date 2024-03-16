#!/bin/bash

echo "For complete installation enter your password:"

# Update system packages
sudo apt-get update -y

# Install git if needed
if ! command -v git &>/dev/null; then
  echo "Git is not installed, installing now..."
  sudo apt-get install git -y
fi

# Create a directory for Forensics tools (more organized)
mkdir MemoryForensicsTools
cd MemoryForensicsTools

# Clone Volatility repository
git clone https://github.com/volatilityfoundation/volatility.git

# Navigate to Volatility directory
cd volatility

# Grant executable permission to vol.py
chmod +x vol.py

# Create a symbolic link to vol.py in /usr/local/bin (preferred for custom scripts)
sudo ln -s $(pwd)/vol.py /usr/local/bin/vol.py

# Ask about Python 2 installation
echo "For running vol.py you have to use Python 2."
echo "Do you want to install Python 2? Enter (y/n):"
read answer

# Check the user's answer and install Python 2 if needed
if [[ "$answer" = "y" ]]; then
  echo "Installing Python 2..."
  sudo apt-get install python2
  echo "Python 2 installation complete."
else
  echo "You chose not to install Python 2."
fi
sudo apt-get install rkhunter
