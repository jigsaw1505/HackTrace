#!/bin/bash

# Configuration
LOG_FILE="/home/kali/startup_script_search.log"
BACKUP_DIR="/var/backup_startup_scripts"
MAX_LOGS=5

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Function to colorize output
color_output() {
    local color_code="$1"
    local message="$2"
    echo -e "\e[${color_code}m${message}\e[0m"
}

# Function to clear logs and terminal
clear_logs_and_terminal() {
    color_output "33" "Clearing previous logs and terminal..."
    
    # Backup and clear the log file
    if [ -f "$LOG_FILE" ]; then
        mv "$LOG_FILE" "$BACKUP_DIR/startup_script_search_$(date +%Y-%m-%d_%H-%M-%S).log"
        ls -t "$BACKUP_DIR/startup_script_search_*.log" | tail -n +$((MAX_LOGS + 1)) | xargs -I {} rm -- {}
        color_output "32" "Old logs saved to $BACKUP_DIR."
    fi
    clear
}

# Function to search for startup scripts
search_startup_scripts() {
    color_output "36" "Searching for startup scripts..."
    
    # Search for startup scripts in common locations
    locations=(
        "/etc/init.d/"
        "/etc/rc.d/"
        "/etc/rc.local"
        "/etc/systemd/system/"
        "/usr/lib/systemd/system/"
        "/etc/rc.local.d/"
        "/etc/systemd/user"
        "~/.config/systemd/user/"
        "~/.config/autostart/"
        "/etc/profile.d/"
        "$HOME/.bash_profile"
        "$HOME/.bashrc"
        "$HOME/.profile"
        "/etc/X11/xinit/xinitrc.d/"
        "/etc/pam.d/"
        "/etc/xdg/"
        "/etc/NetworkManager/dispatcher.d/"
        "/etc/udev/rules.d/"
    )
    
    for location in "${locations[@]}"; do
        # Expand tilde for home directory
        eval "location=${location}"
        
        if [ -d "$location" ]; then
            color_output "34" "Checking directory: $location"
            scripts=$(find "$location" -maxdepth 1 -type f -name "*.sh" 2>/dev/null)
            if [ -n "$scripts" ]; then
                echo "$scripts"
            else
                color_output "31" "No startup scripts found in $location"
            fi
        elif [ -f "$location" ]; then
            color_output "34" "Checking file: $location"
            head -n 10 "$location"  # Show only the first 10 lines for brevity
            echo "... (truncated for brevity)"
        else
            color_output "31" "Location not found or inaccessible: $location"
        fi
    done
    
    echo -e "\nPress any key to return to the menu..."
    read -n 1
}

# Main menu function
show_menu() {
    clear_logs_and_terminal
    color_output "34" "Startup Script Search Utility"
    color_output "34" "--------------------------------"
    color_output "34" "1) Search for Startup Scripts"
    color_output "34" "2) Exit"
    color_output "34" "--------------------------------"
    echo "Please select an option:"
}

# Main program loop
while true; do
    show_menu
    read -r choice

    case "$choice" in
        1) search_startup_scripts ;;
        2) color_output "33" "Exiting..." && exit 0 ;;
        *) color_output "31" "Invalid option, please try again." ;;
    esac
done
