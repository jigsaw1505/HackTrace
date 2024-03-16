#!/bin/bash

# Function to search for startup scripts
search_startup_scripts() {
    echo "Searching for startup scripts..."
    
    # Search for startup scripts in common locations
    locations=("/etc/init.d/" "/etc/rc.d/" "/etc/rc.local" "/etc/systemd/system/" "/usr/lib/systemd/system" "/etc/rc.local.d/" "/etc/systemd/user" "~/.config/systemd/user/" "~/.config/autostart/" "/etc/profile.d/" "~/.bash_profile" "~/.bashrc" "~/.profile" "/etc/X11/xinit/xinitrc.d/" "/etc/pam.d/" "/etc/xdg" "/etc/NetworkManager/dispatcher.d/" "/etc/udev/rules.d/"  )
    
    for location in "${locations[@]}"; do
        if [ -d "$location" ]; then
            echo "Checking directory: $location"
            ls -l $location | grep -E '^[-l].*\.sh$' 2>/dev/null
        elif [ -f "$location" ]; then
            echo "Checking file: $location"
            cat $location
        else
            echo "Location not found: $location"
        fi
    done
}

# Main function
main() {
    search_startup_scripts
}

# Execute main function
main
