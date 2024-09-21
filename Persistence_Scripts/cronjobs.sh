#!/bin/bash

# Log file path and backup directory
LOG_FILE="/var/log/cron_job_audit.log"
BACKUP_DIR="/var/log/cron_job_audit_backups"
EMAIL="admin@example.com"  # Admin email for alerts

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Function to backup the current log
backup_log() {
    if [ -f "$LOG_FILE" ]; then
        local timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
        cp "$LOG_FILE" "$BACKUP_DIR/cron_job_audit_$timestamp.log"
        echo "Backup created: $BACKUP_DIR/cron_job_audit_$timestamp.log"
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

# Function to list user crontabs and detect suspicious entries
list_user_crontabs() {
    log_message "INFO" "Listing user crontabs..."
    
    for user in $(cut -f1 -d: /etc/passwd); do
        crontab -u "$user" -l 2>/dev/null | {
            if [ $? -ne 0 ]; then
                log_message "WARNING" "No crontab found for user: $user"
            else
                local has_empty_entry=false
                while IFS= read -r line; do
                    if [[ -z "$line" ]]; then
                        has_empty_entry=true
                        log_message "WARNING" "User: $user has an empty crontab entry"
                        echo "User: $user has an empty crontab entry" | mail -s "Empty Crontab Entry Detected" "$EMAIL"
                    elif [[ "$line" =~ ^\# ]]; then
                        log_message "DEBUG" "User: $user - $line (commented line)"
                    else
                        log_message "INFO" "User: $user - $line"
                    fi
                done

                # Email alert if the user has empty entries
                if $has_empty_entry; then
                    echo "Empty cron entry found for $user!" | mail -s "Empty Crontab Alert" "$EMAIL"
                fi
            fi
        }
    done
}

# Function to list system cron jobs
list_system_cron_jobs() {
    log_message "INFO" "Listing system cron jobs..."
    
    for cron_dir in /etc/cron.d /etc/cron.daily /etc/cron.hourly /etc/cron.monthly /etc/cron.weekly /etc/crontab; do
        if [ -d "$cron_dir" ] || [ -f "$cron_dir" ]; then
            log_message "INFO" "Listing cron jobs in $cron_dir"
            ls -l "$cron_dir" | tee -a "$LOG_FILE"
        else
            log_message "WARNING" "$cron_dir does not exist."
        fi
    done
}

# Function to clean up logs older than 7 days
cleanup_old_logs() {
    log_message "INFO" "Cleaning up old log files..."
    find "$BACKUP_DIR" -type f -mtime +7 -exec rm -f {} \;
    log_message "INFO" "Old log files cleaned up."
}

# Main function
main() {
    clear  # Clear terminal for cleaner output
    backup_log  # Backup the current log before running new checks
    > "$LOG_FILE"  # Clear the log file for the new session
    
    log_message "INFO" "Cron Job Audit Script Started."
    
    # List user crontabs
    list_user_crontabs
    
    # List system cron jobs
    list_system_cron_jobs
    
    # Display the last few lines of the log
    tail -n 10 "$LOG_FILE"
    
    log_message "INFO" "Cron Job Audit Script Completed."
    
    # Prompt to clean up old logs
    read -p "Do you want to clean up old logs? (y/n): " cleanup_choice
    if [[ "$cleanup_choice" == "y" || "$cleanup_choice" == "Y" ]]; then
        cleanup_old_logs
    fi
}

# Execute main function
main
