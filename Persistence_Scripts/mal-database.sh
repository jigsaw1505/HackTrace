#!/bin/bash

# MySQL credentials
MYSQL_USER="root"
MYSQL_PASS="1234"

# Log file and backup directories
LOG_FILE="/var/log/mysql_audit.log"
BACKUP_DIR="/var/log/mysql_audit_backups"
DB_BACKUP="/var/log/db_info_backup.log"
EMAIL="admin@example.com"  # Admin email for alerts

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

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

# Function to backup logs
backup_log() {
    if [ -f "$LOG_FILE" ]; then
        local timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
        cp "$LOG_FILE" "$BACKUP_DIR/mysql_audit_$timestamp.log"
        log_message "INFO" "Backup created: $BACKUP_DIR/mysql_audit_$timestamp.log"
    fi
}

# Function to perform MySQL audit
perform_mysql_audit() {
    clear
    echo -e "${BLUE}Starting MySQL Database Audit...${NC}"
    
    # Prompt for thresholds
    echo -e "${YELLOW}Please provide thresholds for monitoring:${NC}"
    read -p "Enter size threshold (in MB): " SIZE_THRESHOLD
    read -p "Enter days threshold: " DAYS_THRESHOLD
    
    # Fetch database information
    databases_info=$(mysql -u"${MYSQL_USER}" -p"${MYSQL_PASS}" -e "
    SELECT table_schema AS 'Database', 
           ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size_MB', 
           MAX(create_time) AS 'Last_Updated' 
    FROM information_schema.tables 
    GROUP BY table_schema;" | grep -Ev "(Database|information_schema|performance_schema|mysql)")
    
    # Check if we got data
    if [ -z "$databases_info" ]; then
        log_message "ERROR" "No database information retrieved. Please check MySQL connection and query."
        return
    fi

    # Save database info for auditing
    echo "$databases_info" > "$DB_BACKUP"
    log_message "INFO" "Database information backed up to $DB_BACKUP."

    # Check each database
    while IFS=$'\t' read -r database size_mb last_updated; do
        echo -e "${BLUE}Checking Database: ${YELLOW}$database${NC}, Size_MB: ${YELLOW}$size_mb${NC}, Last_Updated: ${YELLOW}$last_updated${NC}"
        
        # Check size and last updated time
        if (( $(echo "$size_mb > $SIZE_THRESHOLD" | bc -l) )); then
            log_message "WARNING" "Database '$database' size exceeds threshold ($size_mb MB)."
            echo -e "${RED}Warning: Database '$database' exceeds size threshold!${NC}"
            echo "Database '$database' size exceeds $SIZE_THRESHOLD MB." | mail -s "Database Size Alert" "$EMAIL"
        fi

        if [[ -n "$last_updated" ]]; then
            last_updated_epoch=$(date -d "$last_updated" +%s)
            current_epoch=$(date +%s)
            days_since_update=$(( (current_epoch - last_updated_epoch) / (24 * 60 * 60) ))

            if (( days_since_update > DAYS_THRESHOLD )); then
                log_message "WARNING" "Database '$database' not updated in $days_since_update days."
                echo -e "${RED}Warning: Database '$database' has not been updated in $days_since_update days.${NC}"
                echo "Database '$database' not updated in $days_since_update days." | mail -s "Database Update Alert" "$EMAIL"
            fi
        else
            log_message "ERROR" "Invalid or missing last updated date for database '$database'."
        fi
    done <<< "$databases_info"

    log_message "INFO" "MySQL audit completed."
    echo -e "${GREEN}MySQL Database Audit completed.${NC}"
}

# Function to display the log
view_log() {
    clear
    echo -e "${BLUE}Showing the last 20 lines of the log:${NC}"
    tail -n 20 "$LOG_FILE"
}

# Function to display help
show_help() {
    clear
    echo -e "${YELLOW}Help: Dealing with MySQL Connection Errors${NC}"
    echo -e "${RED}The error you're seeing:${NC}"
    echo -e "${RED}ERROR 2002 (HY000): Can't connect to local server through socket '/run/mysqld/mysqld.sock' (2)${NC}"
    echo -e "${YELLOW}This indicates that the MySQL service is not running or that MySQL is not listening on the default Unix socket.${NC}"
    echo -e "${YELLOW}Here's how you can resolve this:${NC}"
    
    echo -e "${GREEN}1. Check MySQL Service Status:${NC}"
    echo "   sudo systemctl status mysql"
    echo "   If it's not running, start it with: sudo systemctl start mysql"
    
    echo -e "${GREEN}2. Restart MySQL:${NC}"
    echo "   sudo systemctl restart mysql"
    
    echo -e "${GREEN}3. Check MySQL Socket Configuration:${NC}"
    echo "   Look in /etc/mysql/my.cnf or /etc/my.cnf for socket path."
    
    echo -e "${GREEN}4. Check MySQL Logs:${NC}"
    echo "   cat /var/log/mysql/error.log"
    
    echo -e "${GREEN}5. Check MySQL Permissions:${NC}"
    echo "   ls -l /run/mysqld/"
    
    echo -e "${GREEN}6. Verify MySQL Credentials:${NC}"
    echo "   Test with: mysql -u root -p"
    
    echo -e "${GREEN}7. Check if MySQL is Using TCP Instead of a Socket:${NC}"
    echo "   Modify the connection command to use -h 127.0.0.1."
    
    echo -e "${GREEN}8. Reinstall MySQL (Last Resort):${NC}"
    echo "   sudo apt-get remove --purge mysql-server mysql-client mysql-common"
    echo "   sudo apt-get install mysql-server"
    
    echo -e "${YELLOW}Let me know if any of these steps help or if you need more details!${NC}"
}

# Main menu function
main_menu() {
    clear
    echo -e "${BLUE}--------------------------------------------${NC}"
    echo -e "${BLUE}        MySQL Database Audit Tool           ${NC}"
    echo -e "${BLUE}--------------------------------------------${NC}"
    echo -e "${YELLOW}1) Perform MySQL Audit${NC}"
    echo -e "${YELLOW}2) Backup Log${NC}"
    echo -e "${YELLOW}3) View Log${NC}"
    echo -e "${YELLOW}4) Help${NC}"
    echo -e "${YELLOW}5) Exit${NC}"
    echo -n -e "${GREEN}Please choose an option: ${NC}"
    read choice
    case $choice in
        1)
            perform_mysql_audit
            ;;
        2)
            backup_log
            ;;
        3)
            view_log
            ;;
        4)
            show_help
            ;;
        5)
            echo -e "${GREEN}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option! Please choose again.${NC}"
            ;;
    esac
}

# Main loop to return to the menu after an option is completed
while true; do
    main_menu
    echo -e "${YELLOW}Press any key to return to the main menu...${NC}"
    read -n 1
done
