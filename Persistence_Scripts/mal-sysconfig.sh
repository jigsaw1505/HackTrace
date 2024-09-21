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

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
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
        original_checksum_file="$BACKUP_DIR/$(basename "$file").sha256"
        
        # If the checksum file doesn't exist, create it
        if [ ! -f "$original_checksum_file" ]; then
            sha256sum "$file" > "$original_checksum_file"
            log_message "INFO" "Checksum for $file created."
            echo "Original Checksum for $file: $(cat "$original_checksum_file")"
        fi
        
        # Calculate current checksum
        current_checksum=$(sha256sum "$file" | awk '{print $1}')
        original_checksum=$(cat "$original_checksum_file" | awk '{print $1}')
        
        if [ "$original_checksum" != "$current_checksum" ]; then
            log_message "WARNING" "$file has been modified!"
            # Send email alert
            echo "$file has been modified!" | mail -s "File Modification Alert" "$EMAIL"
            echo "Warning: $file has been modified!"
        else
            log_message "INFO" "$file has not been modified."
        fi
    else
        log_message "ERROR" "File $file not found!"
        echo "Error: File $file not found!"
    fi
}

# Clear terminal for better visibility
clear

# Start summary report
log_message "INFO" "Starting configuration check..."

# Loop through the list of configuration files
for file in "${CONFIG_FILES[@]}"; do
    check_file "$file"
done

# Generate summary report
log_message "INFO" "Configuration check completed."
echo "Summary of checks logged in $LOG_FILE"

# Display the last 10 entries of the log file
echo "Last 10 log entries:"
tail -n 10 "$LOG_FILE"
