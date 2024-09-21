#!/bin/bash

# Log file path
LOG_FILE="/var/log/malicious_activity.log"
BACKUP_DIR="/var/log/malicious_activity_backups"
TIME_INTERVAL=3600  # Time interval in seconds (1 hour)
EMAIL="admin@example.com"  # Admin email for alerts

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Function to backup the current log
backup_log() {
    if [ -f "$LOG_FILE" ]; then
        local timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
        cp "$LOG_FILE" "$BACKUP_DIR/malicious_activity_$timestamp.log"
        echo "Backup created: $BACKUP_DIR/malicious_activity_$timestamp.log"
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

# Function to display log file contents
display_log_contents() {
    echo "Displaying contents of $LOG_FILE:"
    tail -n 20 "$LOG_FILE"  # Show only the last 20 lines for brevity
    echo "End of $LOG_FILE contents."
}

# Function to check for malicious activity in logs
check_malicious_activity() {
    local current_time=$(date +%s)

    # Syslog activity check
    local last_activity_time_syslog=$(stat -c %Y "/var/log/syslog")
    local time_diff_syslog=$((current_time - last_activity_time_syslog))
    
    log_message "DEBUG" "Checking /var/log/syslog"
    log_message "DEBUG" "Time Difference: $time_diff_syslog seconds"

    if [ $time_diff_syslog -gt $TIME_INTERVAL ]; then
        log_message "WARNING" "Potential malicious activity detected in syslog!"
        # Email alert (optional)
        echo "Potential malicious activity detected in syslog!" | mail -s "Syslog Alert" "$EMAIL"
    else
        log_message "INFO" "No recent malicious activity in syslog."
    fi

    # Auth log activity check
    local last_activity_time_authlog=$(stat -c %Y "/var/log/auth.log")
    local time_diff_authlog=$((current_time - last_activity_time_authlog))
    
    log_message "DEBUG" "Checking /var/log/auth.log"
    log_message "DEBUG" "Time Difference: $time_diff_authlog seconds"

    if [ $time_diff_authlog -gt $TIME_INTERVAL ]; then
        log_message "WARNING" "Potential malicious activity detected in auth.log!"
        # Email alert (optional)
        echo "Potential malicious activity detected in auth.log!" | mail -s "Auth.log Alert" "$EMAIL"
    else
        log_message "INFO" "No recent malicious activity in auth.log."
    fi
}

# Function to clean old logs
cleanup_logs() {
    echo "Cleaning up old logs..."
    find /var/log/ -name "*.log" -mtime +7 -exec rm -f {} \;  # Deletes logs older than 7 days
    log_message "INFO" "Old logs cleaned up."
}

# Main function
main() {
    clear  # Clear terminal for cleaner output
    backup_log  # Backup the current log before running new checks
    > "$LOG_FILE"  # Clear the log file for the new session
    
    log_message "INFO" "Script started."
    check_malicious_activity
    display_log_contents  # Display log file contents
    log_message "INFO" "Script completed."
    
    # Prompt for log cleanup
    read -p "Would you like to clean up old logs? (y/n): " cleanup_choice
    if [[ "$cleanup_choice" == "y" || "$cleanup_choice" == "Y" ]]; then
        cleanup_logs
    fi
}

# Execute main function
main
