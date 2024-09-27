#!/bin/bash

# Colors
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[34m"
CYAN="\033[36m"
RESET="\033[0m"

# Directories for logs
LOG_DIR="/var/log/forensics_script"
BACKUP_LOG_DIR="/var/log/forensics_script_backup"

# Ensure log directories exist
mkdir -p "$LOG_DIR"
mkdir -p "$BACKUP_LOG_DIR"

# Backup and clear old logs
backup_and_clear_logs() {
    if [ "$(ls -A $LOG_DIR)" ]; then
        mv "$LOG_DIR"/* "$BACKUP_LOG_DIR"/ 2>/dev/null
        echo -e "${CYAN}Old logs backed up to ${GREEN}$BACKUP_LOG_DIR${RESET}"
    fi
}

# Clear terminal for a clean look
clear_terminal() {
    clear
}

# Display the main menu
display_menu() {
    clear_terminal

    printf "\e[0m\n"
    printf "\e[0m\e[92m  _        _      ____        ______   _     __\e[0m\e[93m  _________   ________      ____        ______   ________ \e[0m\n"
    printf "\e[0m\e[92m | |      | |    / __ \      / _____| | |   / /\e[0m\e[93m |___ _____| |  ____  |    / __ \      / _____| | _______|\e[0m\n"
    printf "\e[0m\e[92m | |      | |   / /  \ \    / /       | |  / / \e[0m\e[93m     | |     | |    | |   / /  \ \    / /       | |       \e[0m\n"
    printf "\e[0m\e[92m | |______| |  / /____\ \  | |        | | / /  \e[0m\e[93m     | |     | |____| |  / /____\ \  | |        | |______ \e[0m\n"
    printf "\e[0m\e[92m |  ______  | |  ______  | | |        | |/ /   \e[0m\e[93m     | |     | ___  __| | |______| | | |        | _______|\e[0m\n"
    printf "\e[0m\e[92m | |      | | | |      | | | |        | | / \  \e[0m\e[93m     | |     | |  \ \   | |      | | | |        | |       \e[0m\n"
    printf "\e[0m\e[92m | |      | | | |      | |  \ \_____  | |/ \ \ \e[0m\e[93m     | |     | |   \ \  | |      | |  \ \_____  | |______ \e[0m\n"
    printf "\e[0m\e[92m |_|      |_| |_|      |_|   \______| |_|   \_\ \e[0m\e[93m    |_|     |_|    \_\ |_|      |_|   \______| |________|\e[0m\n"
    printf "\e[0m\n"
    printf "\e[0m\n"

    echo -e "${GREEN}Welcome to Forensics and Malware Analysis Script!${RESET}"
    echo -e "${YELLOW}Select an option:${RESET}"
    echo "1) Persistence Techniques for Linux"
    echo "2) Memory forensics"
    echo "3) Rootkit Detection"
    echo "4) Steganography"
    echo "5) Malware Scanning"
    echo "6) Exit"
}

# Persistence techniques function
persistence_techniques() {
    while true; do
        clear_terminal
        echo -e "${GREEN}Linux Persistence Techniques${RESET}"
        echo "1) Environment Variables"
        echo "2) Locating Linux Startup scripts"
        echo "3) Finding existing cron jobs"
        echo "4) Mounts and Partitions"
        echo "5) Systemd services"
        echo "6) Persisting user data"
        echo "7) Process Monitoring"
        echo "8) Persistent RAM disk"
        echo "9) Network File System"
        echo "10) Malicious Databases"
        echo "11) Malicious sysconfig files"
        echo "12) Logging and Log Rotation"
        echo "13) Back to Main Menu"
        echo -n "Select an option: "
        read -r choice
        cd Persistence_Scripts || return

        case $choice in
            1) bash environmentvariables.sh ;;
            2) bash startupscripts.sh ;;
            3) bash cronjobs.sh ;;
            4) bash mount.sh ;;
            5) bash system_services.sh ;;
            6) bash persist.sh ;;
            7) bash processmonitering.sh ;;
            8) bash ramdisk.sh ;;
            9) bash networkfilesystem.sh ;;
            10) bash mal-database.sh ;;
            11) bash mal-sysconfig.sh ;;
            12) bash Log-rotations.sh ;;
            13) cd ..; return ;;
            *) echo -e "${RED}Invalid choice, please try again.${RESET}" ;;
        esac

        echo -e "${YELLOW}Press any key to return to the menu...${RESET}"
        read -n 1 -s
        cd .. || return
    done
}

# Function to perform memory forensics using Volatility
memory_forensics() {
    clear_terminal
    cd MemoryForensicsTools
    bash volitility.sh
}

# Function to detect rootkits
rootkit_detection() {
    clear_terminal
    if ! command -v rkhunter &> /dev/null; then
        echo -e "${RED}Error: Rootkit detection tool (rkhunter) is not installed.${RESET}"
        return 1
    fi
    sudo rkhunter --check
    echo -e "${YELLOW}Rootkit detection completed. Press any key to continue...${RESET}"
    read -n 1 -s
}
# Function for steganography
steghide() {
    clear_terminal
    cd Steganography
    bash stegocracker.sh
}

# Function for malware scanning
malwarescanning() {
    clear
    cd MalwareScanning  
    echo "Choose an Option:"
    echo "1) Specific File or Directory"
    echo "2) Entire File System"
    echo "3) Back"

    read -p "Enter your choice: " choice

    case $choice in
        1)
            echo "Enter Path to Directory:"
            read -r path
            if [ -d "$path" ]; then
                yara -r malscan.yara "$path"
                echo "Press any key to continue..."
                read -n 1 -s
            else
                echo "Invalid directory path."
            fi
            ;;
        2)
            echo "Scanning the Entire File System..."
            sudo yara -r malscan.yara /
            echo "Press any key to continue..."
            read -n 1 -s
            ;;
        3)
            cd ..
            return
            ;;
        *)
            echo "Invalid choice. Please choose a valid option."
            ;;
    esac
}

# Main execution loop
while true; do
    backup_and_clear_logs
    display_menu
    read -r choice

    case $choice in
        1) persistence_techniques ;;
        2) memory_forensics ;;
        3) rootkit_detection ;;
        4) steghide ;;
        5) malwarescanning ;;
        6) echo "Exiting..."; exit 0 ;;
        *) echo -e "${RED}Invalid choice.${RESET}" ;;
    esac
done
