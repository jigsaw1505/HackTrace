#!/bin/bash

# MySQL credentials
MYSQL_USER="root"
MYSQL_PASS="1234"

# Run mysql command to get database information
databases_info=$(mysql -u"${MYSQL_USER}" -p"${MYSQL_PASS}" -e "SELECT table_schema AS 'Database', 
ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size_MB', 
MAX(create_time) AS 'Last_Updated' 
FROM information_schema.tables 
GROUP BY table_schema;" | grep -Ev "(Database|information_schema|performance_schema|mysql)")

# Get user input for size threshold (in MB)
read -p "Enter size threshold (in MB): " SIZE_THRESHOLD

# Get user input for days threshold
read -p "Enter days threshold: " DAYS_THRESHOLD

# Parse database information and check for suspicious activity
while IFS=$'\t' read -r database size_mb last_updated; do
    if (( $(awk 'BEGIN {print ('$size_mb' > '$SIZE_THRESHOLD')}') )); then
        echo "Warning: Database '$database' size exceeds threshold (${size_mb}MB)."
    fi

    last_updated_epoch=$(date -d "$last_updated" +%s)
    current_epoch=$(date +%s)
    days_since_update=$(( (current_epoch - last_updated_epoch) / (24 * 60 * 60) ))
    if (( days_since_update > DAYS_THRESHOLD )); then
        echo "Warning: Database '$database' not updated in $days_since_update days."
    fi
done <<< "$databases_info"
