#!/bin/bash

# MySQL credentials
MYSQL_USER="root"
MYSQL_PASS="1234"

# Log file and backup directories
LOG_FILE="/var/log/mysql_audit.log"
BACKUP_DIR="/var/log/mysql_audit_backups"
DB_BACKUP="/var/log/db_info_backup.log"
EMAIL="admin@example.com"  # Admin email for alerts

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Function to backup logs
backup_log() {
    if [ -f "$LOG_FILE" ]; then
        local timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
        cp "$LOG_FILE" "$BACKUP_DIR/mysql_audit_$timestamp.log"
        echo "Backup created: $BACKUP_DIR/mysql_audit_$timestamp.log"
    fi
}

# Function to log messages with log levels
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
        *)
            echo "[$timestamp] [$log_level] $message" >> "$LOG_FILE"
            ;;
    esac
}

# Clear terminal for better visibility
clear

# Backup the current log
backup_log

# Prompt for thresholds
read -p "Enter size threshold (in MB): " SIZE_THRESHOLD
read -p "Enter days threshold: " DAYS_THRESHOLD

# Run mysql command to get database information, including sys
databases_info=$(mysql -u"${MYSQL_USER}" -p"${MYSQL_PASS}" -e "
SELECT table_schema AS 'Database', 
       ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size_MB', 
       MAX(create_time) AS 'Last_Updated' 
FROM information_schema.tables 
GROUP BY table_schema;" | grep -Ev "(Database|information_schema|performance_schema|mysql)")

# Debugging output for fetched database information
echo "DEBUG: Databases Info: $databases_info"

# Check for empty result
if [ -z "$databases_info" ]; then
    log_message "ERROR" "No database information retrieved. Please check MySQL connection and query."
    exit 1
fi

# Save database info for auditing
echo "$databases_info" > "$DB_BACKUP"
log_message "INFO" "Database information backed up to $DB_BACKUP."

# Parse database info and check for suspicious activity
while IFS=$'\t' read -r database size_mb last_updated; do
    echo "DEBUG: Processing database: $database, Size_MB: $size_mb, Last_Updated: $last_updated"  # Debug output

    # Check if size_mb is a valid number
    if ! [[ "$size_mb" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        log_message "ERROR" "Invalid size for database '$database': '$size_mb'. Skipping."
        continue
    fi

    # Check if database size exceeds threshold
    if (( $(echo "$size_mb > $SIZE_THRESHOLD" | bc -l) )); then
        log_message "WARNING" "Database '$database' size exceeds threshold ($size_mb MB)."
        # Send email alert (optional)
        echo "Database '$database' size exceeds $SIZE_THRESHOLD MB." | mail -s "Database Size Alert" "$EMAIL"
    fi

    # Convert last updated date to epoch for comparison
    if [[ -n "$last_updated" ]]; then
        last_updated_epoch=$(date -d "$last_updated" +%s)
        current_epoch=$(date +%s)
        days_since_update=$(( (current_epoch - last_updated_epoch) / (24 * 60 * 60) ))

        # Check if the database has not been updated in the last N days
        if (( days_since_update > DAYS_THRESHOLD )); then
            log_message "WARNING" "Database '$database' not updated in $days_since_update days."
            # Send email alert (optional)
            echo "Database '$database' not updated in $days_since_update days." | mail -s "Database Update Alert" "$EMAIL"
        fi
    else
        log_message "ERROR" "Invalid or missing last updated date for database '$database'."
    fi
done <<< "$databases_info"

log_message "INFO" "Database audit completed."


# Execute main function
main
