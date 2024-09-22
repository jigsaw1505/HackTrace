#!/bin/bash

# Configuration
CONFIG_DIR="/etc"
BACKUP_DIR="/var/backup_config"
MAX_BACKUPS=5

# Ensure the backup directory exists
mkdir -p "$BACKUP_DIR"

# Function to colorize output
color_output() {
    local color_code="$1"
    local message="$2"
    echo -e "\e[${color_code}m${message}\e[0m"
}

# Function to list configuration files
list_configs() {
    color_output "36" "Listing configuration files in $CONFIG_DIR:"
    find "$CONFIG_DIR" -type f | sort
    echo -e "\nPress any key to return to the menu..."
    read -n 1
}

# Function to backup configuration files
backup_configs() {
    local timestamp=$(date +%Y-%m-%d_%H-%M-%S)
    local backup_file="$BACKUP_DIR/config_backup_$timestamp.tar.gz"

    color_output "32" "Backing up configuration files..."
    if sudo tar czf "$backup_file" "$CONFIG_DIR"; then
        color_output "32" "Configuration files backed up to $backup_file"
    else
        color_output "31" "Failed to back up configuration files."
    fi

    # Clean up old backups
    ls -t "$BACKUP_DIR"/*.tar.gz | tail -n +$((MAX_BACKUPS + 1)) | xargs -I {} rm -- {}
    color_output "33" "Old backups cleaned up. Keep only the last $MAX_BACKUPS backups."
    echo -e "\nPress any key to return to the menu..."
    read -n 1
}

# Function to restore configuration files
restore_configs() {
    color_output "36" "Available backups:"
    ls "$BACKUP_DIR"

    read -p "Enter the backup file name to restore: " backup_file
    local backup_path="$BACKUP_DIR/$backup_file"

    if [ ! -f "$backup_path" ]; then
        color_output "31" "Backup file does not exist: $backup_path"
        return
    fi

    color_output "32" "Restoring configuration files from $backup_path..."
    if sudo tar xzf "$backup_path -C /"; then
        color_output "32" "Configuration files restored from $backup_path"
    else
        color_output "31" "Failed to restore configuration files."
    fi
    echo -e "\nPress any key to return to the menu..."
    read -n 1
}

# Main menu function
show_menu() {
    clear
    color_output "34" "System Configuration Files Management"
    color_output "34" "---------------------------------------"
    color_output "34" "1) List Configuration Files"
    color_output "34" "2) Backup Configuration Files"
    color_output "34" "3) Restore Configuration Files"
    color_output "34" "4) Exit"
    color_output "34" "---------------------------------------"
    echo "Please select an option:"
}

# Main program loop
while true; do
    show_menu
    read -r choice

    case "$choice" in
        1) list_configs ;;
        2) backup_configs ;;
        3) restore_configs ;;
        4) color_output "33" "Exiting..." && exit 0 ;;
        *) color_output "31" "Invalid option, please try again." ;;
    esac
done
