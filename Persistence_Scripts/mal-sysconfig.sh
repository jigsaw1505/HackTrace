#!/bin/bash

# Configuration
LOG_FILE="/var/log/config_check.log"
BACKUP_DIR="/var/log/config_check_backups"
EMAIL="admin@example.com"  # Admin email for alerts
CONFIG_FILES=(
    "/etc/passwd"
    "/etc/shadow"
    "/etc/group"
    "/etc/sudoers"
    "/etc/ssh/sshd_config"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Clear terminal and display a colored header
clear_screen() {
    clear
    echo -e "${BLUE}--------------------------------------------${NC}"
    echo -e "${BLUE}      Welcome to the Configuration Checker   ${NC}"
    echo -e "${BLUE}--------------------------------------------${NC}"
}

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    echo -e "${GREEN}Backup directory created at $BACKUP_DIR${NC}"
fi

# Function to log messages
log_message() {
    local log_level="$1"
    local message="$2"
    local timestamp=$(date +"%Y-%m-%d %T")
    echo "[$timestamp] [$log_level] $message" >> "$LOG_FILE"
}

# Function to check if a file exists and has been modified
check_file() {
    local file="$1"
    if [ -f "$file" ]; then
        log_message "INFO" "Checking $file..."
        echo -e "${YELLOW}Checking file: $file${NC}"
        
        original_checksum_file="$BACKUP_DIR/$(basename "$file").sha256"
        
        # If the checksum file doesn't exist, create it
        if [ ! -f "$original_checksum_file" ]; then
            sha256sum "$file" > "$original_checksum_file"
            log_message "INFO" "Checksum for $file created."
            echo -e "${GREEN}Checksum for $file created and saved.${NC}"
            echo "Original Checksum for $file: $(cat "$original_checksum_file")"
        fi
        
        # Calculate current checksum
        current_checksum=$(sha256sum "$file" | awk '{print $1}')
        original_checksum=$(cat "$original_checksum_file" | awk '{print $1}')
        
        if [ "$original_checksum" != "$current_checksum" ]; then
            log_message "WARNING" "$file has been modified!"
            echo -e "${RED}Warning: $file has been modified!${NC}"
            # Send email alert (disabled for debugging)
            # echo "$file has been modified!" | mail -s "File Modification Alert" "$EMAIL"
        else
            log_message "INFO" "$file has not been modified."
            echo -e "${GREEN}File $file is unchanged.${NC}"
        fi
    else
        log_message "ERROR" "File $file not found!"
        echo -e "${RED}Error: File $file not found!${NC}"
    fi
}

# Function to display the log file
display_log_file() {
    if [ -f "$LOG_FILE" ]; then
        echo -e "${YELLOW}Displaying last 20 lines of log file:${NC}"
        tail -n 20 "$LOG_FILE"
    else
        echo -e "${RED}Log file not found!${NC}"
    fi
}

# Function to clean up old logs
cleanup_logs() {
    echo -e "${YELLOW}Cleaning up logs older than 7 days in /var/log...${NC}"
    find /var/log/ -name "*.log" -mtime +7 -exec rm -f {} \;
    log_message "INFO" "Old logs cleaned up."
    echo -e "${GREEN}Old logs cleaned up.${NC}"
}

# Function to back up configuration files
backup_files() {
    echo -e "${YELLOW}Backing up configuration files...${NC}"
    for file in "${CONFIG_FILES[@]}"; do
        if [ -f "$file" ]; then
            cp "$file" "$BACKUP_DIR/$(basename "$file").bak"
            log_message "INFO" "Backed up $file."
            echo -e "${GREEN}$file backed up.${NC}"
        else
            log_message "ERROR" "Cannot back up $file; file does not exist."
            echo -e "${RED}Error: Cannot back up $file; file does not exist.${NC}"
        fi
    done
}

# Function to display the menu and handle user choices
display_menu() {
    clear_screen
    echo -e "${BLUE}--------------------------${NC}"
    echo -e "${BLUE}   Configuration Checker   ${NC}"
    echo -e "${BLUE}--------------------------${NC}"
    echo -e "${YELLOW}1. Check file integrity${NC}"
    echo -e "${YELLOW}2. Display log file${NC}"
    echo -e "${YELLOW}3. Clean up old logs${NC}"
    echo -e "${YELLOW}4. Backup configuration files${NC}"
    echo -e "${YELLOW}5. Exit${NC}"
    echo -e "${BLUE}--------------------------${NC}"
    read -p "Choose an option [1-5]: " choice
}

# Main function
main() {
    while true; do
        display_menu
        case $choice in
            1)
                echo -e "${YELLOW}Checking file integrity...${NC}"
                for file in "${CONFIG_FILES[@]}"; do
                    check_file "$file"
                done
                ;;
            2)
                display_log_file
                ;;
            3)
                read -p "Are you sure you want to clean up old logs? (y/n): " confirm
                if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                    cleanup_logs
                else
                    echo -e "${RED}Cleanup cancelled.${NC}"
                fi
                ;;
            4)
                backup_files
                ;;
            5)
                echo -e "${GREEN}Exiting the script.${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option! Please try again.${NC}"
                ;;
        esac
        echo -e "${BLUE}Press [Enter] to return to the menu...${NC}"
        read
    done
}

# Run the main function
main
