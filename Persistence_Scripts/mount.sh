#!/bin/bash

print_header() {
    echo "Advanced Filesystem Management Toolkit"
    echo "--------------------------------------"
}

print_menu() {
    echo "1) Display /etc/fstab contents"
    echo "2) Display active mounts"
    echo "3) Filter mounts by filesystem type"
    echo "4) Check filesystem disk usage"
    echo "5) Perform filesystem health check"
    echo "6) Exit"
}

handle_choice() {
    local choice=$1
    case "$choice" in
        1) display_fstab_contents ;;
        2) display_active_mounts ;;
        3) filter_mounts_by_type ;;
        4) check_filesystem_usage ;;
        5) perform_filesystem_health_check ;;
        6) echo "Exiting..." && exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
    echo -e "\nPress any key to return to the main menu..."
    read -n 1
}

display_fstab_contents() {
    echo "Filesystem mounts in /etc/fstab:"
    cat /etc/fstab || echo "Failed to display /etc/fstab."
}

display_active_mounts() {
    echo "Active mounts:"
    findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS -l | column -t
}

filter_mounts_by_type() {
    echo "Enter filesystem type to filter by (e.g., ext4, tmpfs):"
    read -r fs_type
    echo "Filtered mounts ($fs_type):"
    findmnt -t "$fs_type" -o TARGET,SOURCE,FSTYPE,OPTIONS -l | column -t
}

check_filesystem_usage() {
    echo "Filesystem disk usage:"
    df -hT | grep "^/dev" | column -t
}

perform_filesystem_health_check() {
    echo "Performing health checks (This may take some time for large filesystems)..."
    for mount in $(findmnt -lno TARGET -t ext4,xfs); do
        echo "Checking $mount..."
        touch "$mount/.health_check" && rm "$mount/.health_check"
        if [ $? -eq 0 ]; then
            echo "$mount is writable and healthy."
        else
            echo "WARNING: $mount might have issues."
        fi
    done
}

# Main program loop
while true; do
    clear
    print_header
    print_menu
    echo "Please enter your choice, or '6' to exit:"
    read -r choice
    echo
    handle_choice "$choice"
done
