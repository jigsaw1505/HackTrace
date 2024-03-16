#!/bin/bash

# List of system configuration files to check
CONFIG_FILES=("/etc/passwd" "/etc/shadow" "/etc/group" "/etc/sudoers" "/etc/ssh/sshd_config")

# Check if a file exists and has been modified
check_file() {
    local file="$1"
    if [ -f "$file" ]; then
        echo "Checking $file..."
        original_checksum=$(cat "$file" | sha256sum | awk '{print $1}')
        if [ -z "$original_checksum" ]; then
            echo "Error calculating checksum for $file"
        else
            echo "Original Checksum: $original_checksum"
            current_checksum=$(sha256sum "$file" | awk '{print $1}')
            if [ "$original_checksum" != "$current_checksum" ]; then
                echo "Warning: $file has been modified!"
            fi
        fi
    else
        echo "File $file not found!"
    fi
}

# Loop through the list of configuration files
for file in "${CONFIG_FILES[@]}"; do
    check_file "$file"
done
