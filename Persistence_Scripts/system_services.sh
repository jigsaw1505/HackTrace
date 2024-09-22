#!/bin/bash

# Colors
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[34m"
CYAN="\033[36m"
RESET="\033[0m"

# Directories
LOG_DIR="/var/log/service_management"
BACKUP_LOG_DIR="/var/log/service_management_backup"
SERVICE_DIR="/etc/systemd/system"

# Ensure directories exist
mkdir -p "$LOG_DIR"
mkdir -p "$BACKUP_LOG_DIR"

# Backup and clear old logs
backup_and_clear_logs() {
    if [ -d "$LOG_DIR" ]; then
        mv "$LOG_DIR"/* "$BACKUP_LOG_DIR"/ 2>/dev/null
        echo -e "${CYAN}Old logs backed up to ${GREEN}$BACKUP_LOG_DIR${RESET}"
    fi
}

# Clear terminal for a clean look
clear_terminal() {
    clear
}

# Display the header
print_header() {
    echo -e "${GREEN}Advanced Systemd Service Management${RESET}"
    echo -e "${YELLOW}-----------------------------------${RESET}"
}

# Display log locations
show_log_paths() {
    echo -e "${CYAN}Current logs are saved in: ${GREEN}$LOG_DIR${RESET}"
    echo -e "${CYAN}Backup logs are stored in: ${GREEN}$BACKUP_LOG_DIR${RESET}"
}

# Display the list of services
display_services() {
    local filter_status="$1"
    echo -e "${BLUE}Listing $filter_status services...${RESET}"
    systemctl list-units --type=service --state="$filter_status" --no-pager | grep '.service' | awk '{print NR")", $1}' | column -t
    echo -e "${CYAN}Enter the number of the service to manage, 'b' to go back, 'l' to list services active in the last 30 days, or 'q' to quit:${RESET}\n"
}

# Service status report
service_status_report() {
    local service_name="$1"
    echo -e "${YELLOW}Status for $service_name:${RESET}"
    systemctl status "$service_name" --no-pager | head -n 10
}

# Manage service actions (start/stop/restart/enable/disable)
manage_service() {
    local service_name="$1"
    local action="$2"
    echo -e "${CYAN}Performing '$action' on $service_name...${RESET}"
    systemctl "$action" "$service_name"
    echo -e "${GREEN}$service_name $action operation completed.${RESET}"
}

# Check if service was active in the last 30 days
check_service_active_in_last_30_days() {
    local service_name="$1"
    local last_active=$(systemctl show -p ActiveEnterTimestamp "$service_name" | cut -d'=' -f2)

    if [ -z "$last_active" ]; then
        echo -e "${RED}Service $service_name has no recorded activation time.${RESET}"
    else
        local last_active_timestamp=$(date -d "$last_active" +%s)
        local thirty_days_ago=$(date -d '-30 days' +%s)

        if [ "$last_active_timestamp" -ge "$thirty_days_ago" ]; then
            echo -e "${GREEN}Service $service_name was active in the last 30 days.${RESET}"
        else
            echo -e "${RED}Service $service_name was not active in the last 30 days.${RESET}"
        fi
    fi
}

# List services active in the last 30 days
list_services_active_in_last_30_days() {
    local CURRENT_DATE=$(date +%s)
    local THIRTY_DAYS_AGO=$(date -d "30 days ago" +%s)

    echo -e "${BLUE}Services active in the last 30 days:${RESET}"
    
    for service_file in "$SERVICE_DIR"/*.service; do
        local service_name=$(basename "$service_file" .service)
        local activation_time=$(systemctl show -p ActiveEnterTimestamp "$service_name" | cut -d'=' -f2)
        
        if [ -z "$activation_time" ]; then
            continue
        fi
        
        local activation_seconds=$(date -d "$activation_time" +%s)

        if [ "$activation_seconds" -ge "$THIRTY_DAYS_AGO" ] && [ "$activation_seconds" -le "$CURRENT_DATE" ]; then
            echo -e "${CYAN}Service $service_name was started in the last 30 days${RESET}"
        fi
    done
}

# Main Program
main_menu() {
    while true; do
        backup_and_clear_logs
        clear_terminal
        print_header
        show_log_paths
        echo -e "${YELLOW}1) Active services${RESET}"
        echo -e "${YELLOW}2) Inactive services${RESET}"
        echo -e "${YELLOW}3) Services active in the last 30 days${RESET}"
        echo -e "${YELLOW}Enter your choice, or 'q' to quit:${RESET}"
        read -p "Select: " choice

        case "$choice" in
            1) status="active";;
            2) status="inactive";;
            3) list_services_active_in_last_30_days; read -p "Press any key to go back..."; continue;;
            'q') exit 0;;
            *) echo -e "${RED}Invalid choice. Please try again.${RESET}"; continue;;
        esac

        if [[ "$choice" == "1" || "$choice" == "2" ]]; then
            while true; do
                clear_terminal
                display_services "$status"
                read -p "Select an option: " input

                if [[ "$input" == 'b' ]]; then
                    break
                elif [[ "$input" == 'q' ]]; then
                    exit 0
                elif [[ "$input" == 'l' ]]; then
                    list_services_active_in_last_30_days
                    read -p "Press any key to go back..."
                    continue
                elif [[ "$input" =~ ^[0-9]+$ ]]; then
                    services=($(systemctl list-units --type=service --state="$status" --no-pager | grep '.service' | awk '{print $1}'))
                    service_name="${services[$input-1]}"
                    clear_terminal
                    service_status_report "$service_name"
                    check_service_active_in_last_30_days "$service_name"

                    echo -e "${YELLOW}Available actions: 1) start 2) stop 3) restart 4) enable 5) disable${RESET}"
                    read -p "Select an action by number, 'b' to go back, or 'q' to quit: " action_input

                    case "$action_input" in
                        1) manage_service "$service_name" "start";;
                        2) manage_service "$service_name" "stop";;
                        3) manage_service "$service_name" "restart";;
                        4) manage_service "$service_name" "enable";;
                        5) manage_service "$service_name" "disable";;
                        'b') break;;
                        'q') exit 0;;
                        *) echo -e "${RED}Invalid action. Please try again.${RESET}";;
                    esac
                else
                    echo -e "${RED}Invalid input. Please try again.${RESET}"
                fi
            done
        fi
    done
}

# Run the main menu
main_menu
