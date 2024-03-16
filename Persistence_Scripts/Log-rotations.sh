#!/bin/bash

# Log file path
LOG_FILE="/var/log/malicious_activity.log"

# Check if log file exists, create if not
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
fi

# Function to log messages
log_message() {
    local log_level="$1"
    local message="$2"
    local timestamp=$(date +"%Y-%m-%d %T")
    echo "[$timestamp] [$log_level] $message" >> "$LOG_FILE"
}

# Function to display log file contents
display_log_contents() {
    echo "Displaying contents of $LOG_FILE:"
    cat "$LOG_FILE"
    echo "End of $LOG_FILE contents."
}

# Function to check for malicious activity
check_malicious_activity() {
    local current_time=$(date +%s)
    local last_activity_time=$(stat -c %Y "/var/log/syslog")
    local time_diff=$((current_time - last_activity_time))

    log_message "DEBUG" "Current Time of Syslog: $current_time"
    log_message "DEBUG" "Last Activity Time: $last_activity_time"
    log_message "DEBUG" "Time Difference: $time_diff"
    
    if [ $time_diff -gt 3600 ]; then  # Check activity in the last 1 hour
        log_message "WARNING" "Potential malicious activity detected!"
        
    else
        log_message "INFO" "No recent malicious activity detected."
    fi
    
    local current_time1=$(date +%s)
    local last_activity_time1=$(stat -c %Y "/var/log/auth.log")
    local time_diff1=$((current_time1 - last_activity_time1))

    log_message "DEBUG" "Current Time of Auth.log: $current_time1"
    log_message "DEBUG" "Last Activity Time: $last_activity_time1"
    log_message "DEBUG" "Time Difference: $time_diff1"

    if [ $time_diff1 -gt 3600 ]; then  # Check activity in the last 1 hour
        log_message "WARNING" "Potential malicious activity detected!"
        # Add additional checks or commands to analyze and respond to malicious activity
    else
        log_message "INFO" "No recent malicious activity detected."
    fi
}

# Main function
main() {
    log_message "INFO" "Script started."
    check_malicious_activity
    display_log_contents  # Display log file contents
    log_message "INFO" "Script completed."
}

# Execute main function
main
