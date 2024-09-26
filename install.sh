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
touch volitility.sh
cat << EOF >> volitility.sh
echo -n "Enter the path to the memory image: "
    read -r memory_image

    cd volitility || return
    echo "Select Volitility Plugins"
    echo "	  1. imageinfo
	  2. pslist
	  3. psxview
	  4. connscan
	  5. connscan
	  6. socket
	  7. netscan
	  8. cmdline
	  9. console"	
    read -r volatility_commands
	case choice in
	1) vc = imageinfo ;;
	2) vc = pslist ;;
	3) vc = psxview ;;
	4) vc = psscan ;;
	5) vc = connscan ;;
	6) vc = socket ;;
	7) vc = netscan ;;
	8) vc = cmdline ;;
	9) vc = console ;;
    python2 vol.py -f "$memory_image" $volatility_commands
    cd ../.. || return
EOF
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
sudo apt install htop
sudo apt-get install bc
if [ "$PREFIX" = "/data/data/com.termux/files/usr" ]; then
    INSTALL_DIR="$PREFIX/usr/share/doc/Hacktrace"
    BIN_DIR="$PREFIX/bin/"
    BASH_PATH="$PREFIX/bin/bash"
    TERMUX=true

    pkg install -y git python2
elif [ "$(uname)" = "Darwin" ]; then
    INSTALL_DIR="/usr/local/Hacktrace"
    BIN_DIR="/usr/local/bin/"
    BASH_PATH="/bin/bash"
    TERMUX=false
else
    INSTALL_DIR="$HOME/.Hacktrace"
    BIN_DIR="/usr/local/bin/"
    BASH_PATH="/bin/bash"
    TERMUX=false

fi

echo "[✔] Checking directories...";
if [ -d "$INSTALL_DIR" ]; then
    echo "[◉] A directory Hacktrace was found! Do you want to replace it? [Y/n]:" ;
    read -r mama
    if [ "$mama" = "y" ]; then
        if [ "$TERMUX" = true ]; then
            rm -rf "$INSTALL_DIR"
            rm "$BIN_DIR/Hacktrace*"
        else
            sudo rm -rf "$INSTALL_DIR"
            sudo rm "$BIN_DIR/Hacktrace*"
        fi
    else
        echo "[✘] If you want to install you must remove previous installations [✘] ";
        echo "[✘] Installation failed! [✘] ";
        exit
    fi
fi
echo "[✔] Cleaning up old directories...";
if [ -d "$ETC_DIR/Manisso" ]; then
    echo "$DIR_FOUND_TEXT"
    if [ "$TERMUX" = true ]; then
        rm -rf "$ETC_DIR/Manisso"
    else
        sudo rm -rf "$ETC_DIR/Manisso"
    fi
fi

echo "[✔] Installing ...";
echo "";
git clone --depth=1 https://github.com/jigsaw1505/HackTrace "$INSTALL_DIR";
echo "#!$BASH_PATH
bash $INSTALL_DIR/main.sh" "${1+"$@"}" > "$INSTALL_DIR/Hacktrace";
chmod +x "$INSTALL_DIR/Hacktrace";
if [ "$TERMUX" = true ]; then
    cp "$INSTALL_DIR/Hacktrace" "$BIN_DIR"
    cp "$INSTALL_DIR/Hacktrace.cfg" "$BIN_DIR"
else
    sudo cp "$INSTALL_DIR/Hacktrace" "$BIN_DIR"
    sudo cp "$INSTALL_DIR/Hacktrace.cfg" "$BIN_DIR"
fi
rm "$INSTALL_DIR/Hacktrace";


if [ -d "$INSTALL_DIR" ] ;
then
    echo "";
    echo "[✔] Tool installed successfully! [✔]";
    echo "";
    echo "[✔]====================================================================[✔]";
    echo "[✔]      All is done!! You can execute tool by typing Hacktrace !       [✔]";
    echo "[✔]====================================================================[✔]";
    echo "";
else
    echo "[✘] Installation failed! [✘] ";
    exit
fi
