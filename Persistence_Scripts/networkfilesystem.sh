#!/bin/bash

# Function to install NFS packages
install_nfs_packages() {
    echo "Installing NFS packages..."
    sudo apt-get install ufw
    sudo apt-get install nfs-kernel-server nfs-common -y
    
    # Check if installation was successful
    if [ $? -eq 0 ]; then
        echo "NFS packages installed."
    else
        echo "NFS packages not installed."
    fi
}

# Function to configure NFS exports
configure_nfs_exports() {
    echo "Configuring NFS exports..."
    sudo mkdir -p /srv/nfs
    sudo chmod 777 /srv/nfs   # Adjust permissions as necessary
    
    # Example: Export /srv/nfs to all clients
    echo "/srv/nfs *(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports
    
    # Apply changes
    sudo exportfs -ra
    
    # Check if configuration was successful
    if [ $? -eq 0 ]; then
        echo "NFS exports configured."
    else
        echo "NFS exports not configured."
    fi
}

# Function to start NFS service
start_nfs_service() {
    echo "Starting NFS service..."
    sudo systemctl start nfs-server
    sudo systemctl enable nfs-server
    
    # Check if service started successfully
    if [ $? -eq 0 ]; then
        echo "NFS service started."
    else
        echo "NFS service not started."
    fi
}

# Function to stop NFS service
stop_nfs_service() {
    echo "Stopping NFS service..."
    sudo systemctl stop nfs-server
    
    # Check if service stopped successfully
    if [ $? -eq 0 ]; then
        echo "NFS service stopped."
    else
        echo "NFS service not stopped."
    fi
}

# Function to add firewall rules for NFS
configure_firewall() {
    echo "Configuring firewall for NFS..."
    sudo ufw allow from 192.168.1.0/24 to any port nfs
    sudo ufw reload
    
    # Check if firewall configured successfully
    if [ $? -eq 0 ]; then
        echo "Firewall configured for NFS."
    else
        echo "Firewall not configured for NFS."
    fi
}

# Main menu
while true; do
    echo "Welcome to NFS management script"
    echo "1. Install NFS packages"
    echo "2. Configure NFS exports"
    echo "3. Start NFS service"
    echo "4. Stop NFS service"
    echo "5. Configure firewall for NFS"
    echo "6. Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1)
            install_nfs_packages
            ;;
        2)
            configure_nfs_exports
            ;;
        3)
            start_nfs_service
            ;;
        4)
            stop_nfs_service
            ;;
        5)
            configure_firewall
            ;;
        6)
            echo "Exiting script."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter a valid option."
            ;;
    esac
done
