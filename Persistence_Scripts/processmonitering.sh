#!/bin/bash

# Configuration
LOG_FILE="/home/kali/process_management.log"
BACKUP_DIR="/home/kali/backups"
MAX_LOGS=5
HTOP_INSTALLED=false

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Function to check if htop is installed (run once)
check_htop_installed() {
    if command -v htop > /dev/null; then
        HTOP_INSTALLED=true
    else
        HTOP_INSTALLED=false
    fi
}

# Function to colorize output
color_output() {
    local color_code="$1"
    local message="$2"
    echo -e "\e[${color_code}m${message}\e[0m"
}

# Function to clear logs and terminal before showing menu
clear_logs_and_terminal() {
    color_output "33" "Clearing previous logs and terminal..."
    
    # Backup and clear the log file
    if [ -f "$LOG_FILE" ]; then
        mv "$LOG_FILE" "$BACKUP_DIR/process_log_$(date +%Y-%m-%d_%H-%M-%S).log"
        # Keep only the last $MAX_LOGS logs
        ls -t "$BACKUP_DIR"/*.log | tail -n +$(($MAX_LOGS + 1)) | xargs -I {} rm -- {}
    fi
    clear
    color_output "32" "Logs cleared. Old logs saved to $BACKUP_DIR."
}

# Function to log messages
log_message() {
    local message="$1"
    local timestamp=$(date +"%Y-%m-%d %T")
    echo "[$timestamp] $message" >> "$LOG_FILE"
}

# Function to display the menu
function display_menu() {
    clear
    color_output "34" "----------------------------------"
    color_output "34" "1. Check memory processes"
    color_output "34" "2. Check PID for a user"
    color_output "34" "3. View logs"
    color_output "34" "4. Monitor processes (real-time)"
    color_output "34" "5. Help"
    color_output "34" "6. Exit"
    color_output "34" "----------------------------------"
    echo "Please enter your choice:"
}

# Function to check memory processes
function mem() {
    while true; do
        color_output "36" "Displaying memory processes..."
        ps aux
        log_message "Displayed memory processes"

        echo -e "\nOptions:"
        echo "1. Kill a process"
        echo "2. Back to menu"
        read -r choice

        case $choice in
            1)
                echo "Enter PID to kill: "
                read -r pid
                if sudo kill "$pid"; then
                    color_output "32" "Process $pid killed."
                    log_message "Killed process with PID $pid"
                else
                    color_output "31" "Failed to kill process with PID $pid."
                    log_message "Failed to kill process with PID $pid"
                fi
                ;;
            2)
                return
                ;;
            *)
                color_output "31" "Invalid choice."
                ;;
        esac
    done
}

# Function to check PID details for a specific user
function pid() {
    while true; do
        echo "Enter username (or type 'back' to return): "
        read -r username
        if [[ "$username" == "back" ]]; then
            return
        fi
        
        color_output "36" "Displaying processes for user $username..."
        ps -u "$username" -o pid,ppid,%cpu,%mem,cmd
        log_message "Displayed processes for user $username"
        echo -e "\nPress any key to continue..."
        read -n 1
    done
}

# Function to view logs
function view_logs() {
    if [ -f "$LOG_FILE" ]; then
        color_output "36" "Displaying the most recent log file..."
        cat "$LOG_FILE"
    else
        color_output "31" "No logs found."
    fi
    echo -e "\nPress any key to return..."
    read -n 1
}

# Function for real-time process monitoring
function monitor_processes() {
    color_output "36" "Launching real-time process monitor..."
    if [ "$HTOP_INSTALLED" = true ]; then
        color_output "33" "Press 'F10' or 'q' to exit htop."
        htop
    else
        color_output "33" "Press 'q' to exit top."
        top
    fi
    echo -e "\nPress any key to return to the menu..."
    read -n 1
}

# Function for help and documentation
function show_help() {
    color_output "35" "---- Help Menu ----"
    echo "1. Check memory processes: Lists all running processes with memory usage."
    echo "2. Check PID: Enter a username to see their processes and resource usage."
    echo "3. View logs: Displays the recent log file of actions taken by this script."
    echo "4. Monitor processes: Real-time monitoring using top or htop."
    echo "5. Exit: Quits the program. You will be prompted to confirm."
    echo "Logs are rotated and saved in $BACKUP_DIR."
    echo -e "\nPress any key to return..."
    read -n 1
}

# Main loop
check_htop_installed  # Check if htop is installed once at the beginning

while true; do
    clear_logs_and_terminal  # Clear only when returning to the menu
    display_menu
    read -r choice
    
    case $choice in
        1)
            mem
            ;;
        2)
            pid
            ;;
        3)
            view_logs
            ;;
        4)
            monitor_processes
            ;;
        5)
            show_help
            ;;
        6)
            echo "Are you sure you want to exit? (y/n)"
            read -r confirm_exit
            if [[ "$confirm_exit" == "y" || "$confirm_exit" == "Y" ]]; then
                log_message "Exited the program"
                color_output "32" "Exiting program. Logs saved to $LOG_FILE."
                exit 0
            else
                color_output "33" "Exit canceled."
            fi
            ;;
        *)
            color_output "31" "Invalid choice. Please try again."
            ;;
    esac
done
