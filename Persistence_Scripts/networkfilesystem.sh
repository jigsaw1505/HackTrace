#!/bin/bash

# Configuration
LOG_FILE="/var/log/nfs_management.log"
BACKUP_DIR="/var/log/nfs_management_backups"
EXPORTS_FILE="/etc/exports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NFS_EXPORT_ENTRY="/srv/nfs *(rw,sync,no_subtree_check)"

# Create backup and log directories if they don't exist
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Function to clear old logs and backups before running new operations
clear_old_logs_and_backups() {
    echo "Cleaning up old logs and backups..."
    rm -f "$LOG_FILE"
    rm -rf "$BACKUP_DIR"/*
    echo "Old logs and backups deleted."
}

# Function to log messages
log_message() {
    local log_level="$1"
    local message="$2"
    local timestamp=$(date +"%Y-%m-%d %T")
    echo "[$timestamp] [$log_level] $message" >> "$LOG_FILE"
}

# Function to back up NFS exports file
backup_exports() {
    local backup_file="$BACKUP_DIR/exports_backup_$TIMESTAMP"
    cp "$EXPORTS_FILE" "$backup_file"
    if [ $? -eq 0 ]; then
        log_message "INFO" "NFS exports backed up to $backup_file."
        echo "Backup created at: $backup_file"
    else
        log_message "ERROR" "Failed to backup NFS exports."
        echo "Failed to backup NFS exports."
    fi
}

# Clear previous logs and terminal output
clear_old_logs_and_backups
clear

# Function to install NFS packages
install_nfs_packages() {
    echo "Installing NFS packages..."
    sudo apt-get install ufw -y
    sudo apt-get install nfs-kernel-server nfs-common -y
    
    # Log the result of the installation
    if [ $? -eq 0 ]; then
        log_message "INFO" "NFS packages installed."
        echo "NFS packages installed."
    else
        log_message "ERROR" "NFS packages not installed."
        echo "NFS packages not installed."
    fi
}

# Function to configure NFS exports
configure_nfs_exports() {
    echo "Configuring NFS exports..."
    sudo mkdir -p /srv/nfs
    sudo chmod 777 /srv/nfs   # Adjust permissions as necessary
    
    # Backup the exports file before modifying it
    backup_exports
    
    # Check if the export entry already exists in the exports file
    if ! grep -q "$NFS_EXPORT_ENTRY" "$EXPORTS_FILE"; then
        # If not, add it
        echo "$NFS_EXPORT_ENTRY" | sudo tee -a "$EXPORTS_FILE"
        
        # Apply changes and check for errors
        sudo exportfs -ra
        if [ $? -eq 0 ]; then
            log_message "INFO" "NFS exports configured."
            echo "NFS exports configured."
        else
            log_message "ERROR" "Failed to configure NFS exports. Check /etc/exports for issues."
            echo "NFS exports not configured. Please check the log at $LOG_FILE for details."
        fi
    else
        # Log if the entry already exists
        log_message "INFO" "NFS export entry already exists in /etc/exports."
        echo "NFS export entry already exists in /etc/exports."
    fi
}

# Function to start NFS service
start_nfs_service() {
    echo "Starting NFS service..."
    sudo systemctl start nfs-server
    sudo systemctl enable nfs-server
    
    # Log the result of the service startup
    if [ $? -eq 0 ]; then
        log_message "INFO" "NFS service started."
        echo "NFS service started."
    else
        log_message "ERROR" "NFS service not started."
        echo "NFS service not started."
    fi
}

# Function to stop NFS service
stop_nfs_service() {
    echo "Stopping NFS service..."
    sudo systemctl stop nfs-server
    
    # Log the result of the service stop
    if [ $? -eq 0 ]; then
        log_message "INFO" "NFS service stopped."
        echo "NFS service stopped."
    else
        log_message "ERROR" "NFS service not stopped."
        echo "NFS service not stopped."
    fi
}

# Function to configure firewall for NFS
configure_firewall() {
    echo "Configuring firewall for NFS..."
    sudo ufw allow from 192.168.1.0/24 to any port nfs
    sudo ufw reload
    
    # Log the result of the firewall configuration
    if [ $? -eq 0 ]; then
        log_message "INFO" "Firewall configured for NFS."
        echo "Firewall configured for NFS."
    else
        log_message "ERROR" "Firewall not configured for NFS."
        echo "Firewall not configured for NFS."
    fi
}

# Function to display log file and backup locations
display_log_and_backup_info() {
    echo "Logs saved at: $LOG_FILE"
    echo "Backups saved in: $BACKUP_DIR"
}

# Main menu loop
while true; do
    clear
    echo "Welcome to the Advanced NFS Management Script"
    echo "1. Install NFS packages"
    echo "2. Configure NFS exports"
    echo "3. Start NFS service"
    echo "4. Stop NFS service"
    echo "5. Configure firewall for NFS"
    echo "6. Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1)
            install_nfs_packages
            ;;
        2)
            configure_nfs_exports
            ;;
        3)
            start_nfs_service
            ;;
        4)
            stop_nfs_service
            ;;
        5)
            configure_firewall
            ;;
        6)
            echo "Exiting script."
            display_log_and_backup_info
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter a valid option."
            ;;
    esac
    echo -e "\nPress any key to return to the main menu..."
    read -n 1
done
