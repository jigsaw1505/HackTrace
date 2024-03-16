#!/bin/bash

CONFIG_DIR="/etc"
BACKUP_DIR="/var/backup_config"

# Ensure the backup directory exists
mkdir -p "$BACKUP_DIR"

# Function to list configuration files
list_configs() {
    echo "Listing configuration files in $CONFIG_DIR:"
    find "$CONFIG_DIR" -type f
}

# Function to backup configuration files
backup_configs() {
    local timestamp=$(date +%Y-%m-%d_%H-%M-%S)
    local backup_file="$BACKUP_DIR/config_backup_$timestamp.tar.gz"

    echo "Backing up configuration files..."
    sudo tar czf "$backup_file" "$CONFIG_DIR"
    echo "Configuration files backed up to $backup_file"
}

# Function to restore configuration files
restore_configs() {
    echo "Available backups:"
    ls "$BACKUP_DIR"
    
    read -p "Enter the backup file name to restore: " backup_file
    local backup_path="$BACKUP_DIR/$backup_file"

    if [ ! -f "$backup_path" ]; then
        echo "Backup file does not exist: $backup_path"
        return
    fi

    echo "Restoring configuration files from $backup_path..."
    sudo tar xzf "$backup_path" -C /
    echo "Configuration files restored from $backup_path"
}

# Main menu function
show_menu() {
    echo "System Configuration Files Management"
    echo "1) List Configuration Files"
    echo "2) Backup Configuration Files"
    echo "3) Restore Configuration Files"
    echo "4) Exit"
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
        4) echo "Exiting..." && exit 0 ;;
        *) echo "Invalid option, please try again." ;;
    esac
    echo
done
