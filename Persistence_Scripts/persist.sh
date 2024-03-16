#!/bin/bash

# Directories and files to monitor
watchlist=("/home/kali/.config")

# Exclude pattern list
exclude_patterns=(".log" ".cache")

# Output file for scan results
scan_results="/home/kali/scan_results_$(date +%Y-%m-%d_%H-%M-%S).txt"
backup_dir="/home/kali/backups"

# Ensure backup directory exists
mkdir -p "$backup_dir"

# Function to calculate and check hashes of files/directories
check_hashes() {
    local path="$1"
    local hash_file="/home/kali/$(echo "$path" | sed 's|/|_|g').txt"

    # Exclude patterns
    local exclude_args=()
    for pattern in "${exclude_patterns[@]}"; do
        exclude_args+=(! -name "$pattern")
    done

    # Check if hash file exists; if not, create it
    if [ ! -f "$hash_file" ]; then
        find "$path" -type f "${exclude_args[@]}" -exec sha256sum {} + > "$hash_file"
        echo "Initial hash generated for $path" >> "$scan_results"
    else
        # Generate a current state hash and compare
        local current_hash="/tmp/current_$(basename "$hash_file")"
        find "$path" -type f "${exclude_args[@]}" -exec sha256sum {} + > "$current_hash"
        if ! diff -q "$hash_file" "$current_hash" > /dev/null; then
            echo "WARNING: Potential unauthorized change detected in $path" >> "$scan_results"
            # Backup changed files
            while IFS= read -r line; do
                local filename=$(echo "$line" | awk '{print $2}')
                cp "$filename" "$backup_dir/"
            done < <(diff "$hash_file" "$current_hash" | grep ">" | awk '{print $2}')
            # Update the hash file to current state
            mv "$current_hash" "$hash_file"
        else
            echo "No changes detected in $path" >> "$scan_results"
        fi
    fi
}

# Loop through watchlist to check each item
for item in "${watchlist[@]}"; do
    check_hashes "$item"
done

echo "Scan completed. Results saved to $scan_results."
echo "Displaying scan results:"
cat "$scan_results"
