#!/bin/bash

# Log file path and backup directory
LOG_FILE="/var/log/env_var_audit.log"
BACKUP_DIR="/var/log/env_var_audit_backups"
EMAIL="admin@example.com"  # Admin email for alerts

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Function to backup the current log
backup_log() {
    if [ -f "$LOG_FILE" ]; then
        local timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
        cp "$LOG_FILE" "$BACKUP_DIR/env_var_audit_$timestamp.log"
        echo "Backup created: $BACKUP_DIR/env_var_audit_$timestamp.log"
    fi
}

# Function to log messages with levels
log_message() {
    local log_level="$1"
    local message="$2"
    local timestamp=$(date +"%Y-%m-%d %T")
    
    case $log_level in
        INFO)
            printf "\e[32m[$timestamp] [$log_level] $message\e[0m\n" | tee -a "$LOG_FILE"
            ;;
        WARNING)
            printf "\e[33m[$timestamp] [$log_level] $message\e[0m\n" | tee -a "$LOG_FILE"
            ;;
        ERROR)
            printf "\e[31m[$timestamp] [$log_level] $message\e[0m\n" | tee -a "$LOG_FILE"
            ;;
        DEBUG)
            printf "\e[34m[$timestamp] [$log_level] $message\e[0m\n" | tee -a "$LOG_FILE"
            ;;
        *)
            printf "[$timestamp] [$log_level] $message\n" >> "$LOG_FILE"
            ;;
    esac
}

# Function to search for environment variables
search_env_vars() {
    log_message "INFO" "Starting environment variable search..."
    
    # Print all environment variables
    log_message "INFO" "All environment variables:"
    printenv | tee -a "$LOG_FILE"
    
    # List of profile files to check for environment variables
    profile_files=(
        "/etc/profile" "/etc/bash.bashrc" "$HOME/.bash_profile" "$HOME/.bashrc"
        "$HOME/.profile" "/etc/environment" "/etc/profile.d/*.sh" "$HOME/.bash_login"
        "$HOME/.bash_logout" "/proc/sys/kernel/env" "/etc/security/pam_env.conf"
        "/etc/sudoers" "/etc/cron.d" "/etc/systemd/system.conf" "/etc/systemd/user.conf"
        "/etc/default/*" "/etc/login.defs"
    )
  
    log_message "INFO" "Checking profile files for environment variables..."
    for file in "${profile_files[@]}"; do
        if [ -f "$file" ]; then
            log_message "INFO" "Checking file: $file"
            grep -E '^export [A-Za-z_]+=' "$file" | tee -a "$LOG_FILE"
        else
            log_message "WARNING" "File not found: $file"
        fi
    done
}

# Function to clean up logs older than 7 days
cleanup_old_logs() {
    log_message "INFO" "Cleaning up old log files in $BACKUP_DIR..."
    
    # Find and delete files older than 7 days
    find "$BACKUP_DIR" -type f -mtime +7 -exec rm -f {} \;
    
    # Check if any logs remain after cleanup
    if [ "$(find "$BACKUP_DIR" -type f -mtime +7)" ]; then
        log_message "ERROR" "Failed to clean up old logs. Please check permissions."
    else
        log_message "INFO" "Old log files cleaned up successfully."
    fi
}

# Main function
main() {
    clear  # Clear terminal for cleaner output
    backup_log  # Backup the current log before running new checks
    > "$LOG_FILE"  # Clear the log file for the new session
    
    log_message "INFO" "Environment Variable Audit Script Started."
    
    # Search for environment variables
    search_env_vars
    
    log_message "INFO" "Environment Variable Audit Script Completed."
    
    # Prompt to clean up old logs
    read -p "Do you want to clean up old logs? (y/n): " cleanup_choice
    if [[ "$cleanup_choice" == "y" || "$cleanup_choice" == "Y" ]]; then
        cleanup_old_logs
    fi
}

# Execute main function
main
