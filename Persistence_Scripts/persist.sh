#!/bin/bash

# Configuration
LOG_FILE="/home/kali/scan_results.log"
BACKUP_DIR="/home/kali/backups"
WATCHLIST=("/home/kali/.config")
EXCLUDE_PATTERNS=(".log" ".cache")

# Function to clear old logs and terminal
clear_old_logs_and_terminal() {
    echo "Clearing old logs and terminal..."
    if [ -f "$LOG_FILE" ]; then
        mv "$LOG_FILE" "$BACKUP_DIR/scan_results_$(date +%Y-%m-%d_%H-%M-%S).log"
    fi
    clear
    echo "Old logs cleared and terminal reset."
}

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Function to log messages
log_message() {
    local message="$1"
    local timestamp=$(date +"%Y-%m-%d %T")
    echo "[$timestamp] $message" >> "$LOG_FILE"
}

# Function to calculate and check hashes of files/directories
check_hashes() {
    local path="$1"
    local hash_file="/home/kali/$(echo "$path" | sed 's|/|_|g').txt"

    # Exclude patterns
    local exclude_args=()
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        exclude_args+=(! -name "$pattern")
    done

    # Check if hash file exists; if not, create it
    if [ ! -f "$hash_file" ]; then
        find "$path" -type f "${exclude_args[@]}" -exec sha256sum {} + > "$hash_file"
        log_message "Initial hash generated for $path"
    else
        # Generate a current state hash and compare
        local current_hash="/tmp/current_$(basename "$hash_file")"
        find "$path" -type f "${exclude_args[@]}" -exec sha256sum {} + > "$current_hash"
        
        # Check if there are any differences
        if diff -q "$hash_file" "$current_hash" > /dev/null; then
            log_message "No changes detected in $path"
            rm "$current_hash"
        else
            log_message "WARNING: Potential unauthorized change detected in $path"
            
            # Backup only the changed files
            local changed_files=false
            while IFS= read -r line; do
                local filename=$(echo "$line" | awk '{print $2}')
                if [ -f "$filename" ]; then
                    cp "$filename" "$BACKUP_DIR/"
                    log_message "Backed up $filename to $BACKUP_DIR"
                    changed_files=true
                fi
            done < <(diff "$hash_file" "$current_hash" | grep ">" | awk '{print $2}')
            
            # Check if any files were backed up
            if [ "$changed_files" = false ]; then
                log_message "No files backed up. Possible invalid paths."
            fi
            
            # Update the hash file to the current state
            mv "$current_hash" "$hash_file"
        fi
    fi
}

# Clear terminal and previous logs
clear_old_logs_and_terminal

# Loop through watchlist to check each item
for item in "${WATCHLIST[@]}"; do
    check_hashes "$item"
done

# Display scan results, then delete them
echo "Scan completed. Results saved to $LOG_FILE."
echo "Displaying scan results:"
cat "$LOG_FILE"
rm "$LOG_FILE"

echo "Logs are saved in: $BACKUP_DIR"
