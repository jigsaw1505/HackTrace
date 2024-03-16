#!/bin/bash

# Function to search for environment variables
search_env_vars() {
    echo "Searching for environment variables..."
    
    # Print all environment variables
    echo "All environment variables:"
    printenv

    # Search for environment variables in profile files
    profile_files=("/etc/profile" "/etc/bash.bashrc" "$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.profile" "/etc/environment" "/etc/profile.d/*.sh" "$HOME/.bash_login" "$HOME/.bash_logout" "/proc/sys/kernel/env" "/etc/security/pam_env.conf" "/etc/sudoers" "/etc/cron.d" "/etc/systemd/system.conf" "/etc/systemd/user.conf" "/etc/default/*" "/etc/login.defs"  )
  
    echo "Checking profile files for environment variables:"
    for file in "${profile_files[@]}"; do
        if [ -f "$file" ]; then
            echo "Checking file: $file"
            grep -E '^export [A-Za-z_]+=' $file
        else
            echo "File not found: $file"
        fi
    done
}

# Main function
main() {
    search_env_vars
}

# Execute main function
main
