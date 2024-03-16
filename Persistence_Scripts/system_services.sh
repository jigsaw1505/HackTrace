#!/bin/bash

print_header() {
    echo "Advanced Systemd Service Management"
    echo "-----------------------------------"
}

display_services() {
    local filter_status="$1"
    echo "Listing $filter_status services..."
    systemctl list-units --type=service --state="$filter_status" --no-pager | grep '.service' | awk '{print NR")", $1}' | column -t
    echo -e "Enter the number of the service to manage, 'b' to go back, 'l' to list services active in the last 30 days, or 'q' to quit:\n"
}

service_status_report() {
    local service_name="$1"
    echo -e "Status for $service_name:\n"
    systemctl status "$service_name" --no-pager | head -n 10
}

manage_service() {
    local service_name="$1"
    local action="$2"
    echo "Performing '$action' on $service_name..."
    systemctl "$action" "$service_name"
    echo "$service_name $action operation completed."
}

check_service_active_in_last_30_days() {
    local service_name="$1"
    local last_active=$(systemctl show -p ActiveEnterTimestamp "$service_name" | cut -d'=' -f2)
    
    if [ -z "$last_active" ]; then
        echo "Service $service_name has no recorded activation time."
    else
        local last_active_timestamp=$(date -d "$last_active" +%s)
        local thirty_days_ago=$(date -d '-30 days' +%s)
        
        if [ "$last_active_timestamp" -ge "$thirty_days_ago" ]; then
            echo "Service $service_name was active in the last 30 days."
        else
            echo "Service $service_name was not active in the last 30 days."
        fi
    fi
}

list_services_active_in_last_30_days() {


# Define the directory where systemd service units are located
SERVICE_DIR="/etc/systemd/system"

# Get the current date in seconds since epoch
CURRENT_DATE=$(date +%s)

# Calculate the date 30 days ago in seconds since epoch
THIRTY_DAYS_AGO=$(date -d "30 days ago" +%s)

# Iterate through each service unit file in the directory
for service_file in "$SERVICE_DIR"/*.service; do
    # Extract the service name from the file name
    service_name=$(basename "$service_file" .service)
    
    # Get the activation time of the service
    activation_time=$(systemctl show -p ActiveEnterTimestamp "$service_name" | cut -d'=' -f2)
    
    # Convert activation time to seconds since epoch
    activation_seconds=$(date -d "$activation_time" +%s)
    
    # Check if the service was activated in the last 30 days
    if [ "$activation_seconds" -ge "$THIRTY_DAYS_AGO" ] && [ "$activation_seconds" -le "$CURRENT_DATE" ]; then
        echo "Service $service_name was started in the last 30 days"
    fi
done



}

# Main Program
while true; do
    print_header
    echo "1) Active services"
    echo "2) Inactive services"
    echo "3) Services active in the last 30 days"
    echo "Enter your choice, or 'q' to quit:"
    read -p "Select: " choice

    case "$choice" in
        1) status="active";;
        2) status="inactive";;
        3) list_services_active_in_last_30_days; continue;;
        'q') exit 0;;
        *) echo "Invalid choice. Please try again."; continue;;
    esac

    if [[ "$choice" == "1" || "$choice" == "2" ]]; then
        while true; do
            display_services "$status"
            read input

            if [[ "$input" == 'b' ]]; then
                break
            elif [[ "$input" == 'q' ]]; then
                exit 0
            elif [[ "$input" == 'l' ]]; then
                list_services_active_in_last_30_days
                continue
            elif [[ "$input" =~ ^[0-9]+$ ]]; then
                services=($(systemctl list-units --type=service --state="$status" --no-pager | grep '.service' | awk '{print $1}'))
                service_name="${services[$input-1]}"
                service_status_report "$service_name"
                check_service_active_in_last_30_days "$service_name"
                
                echo "Available actions: 1) start 2) stop 3) restart 4) enable 5) disable"
                read -p "Select an action by number, 'b' to go back, or 'q' to quit: " action_input
                
                case "$action_input" in
                    1) manage_service "$service_name" "start";;
                    2) manage_service "$service_name" "stop";;
                    3) manage_service "$service_name" "restart";;
                    4) manage_service "$service_name" "enable";;
                    5) manage_service "$service_name" "disable";;
                    'b') break;;
                    'q') exit 0;;
                    *) echo "Invalid action. Please try again."; continue;;
                esac
            else
                echo "Invalid input. Please try again."
            fi
        done
    fi
done
