#!/bin/bash

echo "For complete installation enter your password:"

# Update system packages
sudo apt-get update -y

# Install git if needed
if ! command -v git &>/dev/null; then
  echo "Git is not installed, installing now..."
  sudo apt-get install git -y
  sudo apt-get install yara
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
    echo "	1. imageinfo
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
cd ../..
# Ask about Python 2 installation
echo "For running vol.py you have to use Python 2."
echo "Do you want to install Python 2? Enter (y/n):"
read answer

mkdir MalwareScanning
cd MalwareScanning
touch malscan.yara
echo "
rule Malscan {
  meta:
    description = \"This detection is aimed for Scanning PC\"
    Author = \"Hacktrace\"
  strings:
    \$s1 = \"AV killer\"
    \$s2 = \"spybot\"
    \$s3 = \"startkeylogger\"
    \$s4 = \"Portscanner start ip\"
    \$s5 = \"InternetOpenA\"
    \$s6 = \"GetSystemInfo\"
    \$s7 = \"WININET.dll\"
    \$s8 = \"PWD144381378271510980\"
    \$s9 = \"Triple Threat\"
    \$s10 = \"keylogger\"
    \$s11 = \"CryptStringToBinary\"
    \$s12 = \"AntiVM\"
    \$s13 = \"VMware\"
    \$s14 = \"Base64\"
    \$s15 = \"Software\\Microsoft\\Windows\\CurrentVersion\\Run\"
    \$s16 = \"SetEnvironmentVariableW\"
    \$s17 = \"LoadLibraryExW\"
    \$s18 = \"Startup\"
    \$s19 = \"DecodePointer\"
    \$s20 = \"GlobalMemoryStatusEx\"
  condition:
    \$s1 or \$s2 or \$s3 or \$s4 or \$s5 or \$s6 or \$s7 or \$s8 or \$s9 or \$s10 or \$s11 or \$s12 or \$s13 or \$s14 or \$s15 or \$s16 or \$s17 or \$s18 or \$s19 or \$s20
}" > malscan.yara

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
        rm -rf "$ETC_DIR/jigsaw1505"
    else
        sudo rm -rf "$ETC_DIR/jigsaw1505"
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

