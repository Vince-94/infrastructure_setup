#!/bin/bash

ARCH=$(uname -m)
if [ "$ARCH" == "aarch64" ]; then
    sudo apt purge -y needrestart
    # sudo apt install -y dphys-swapfile
fi


# Check if an argument is provided, otherwise default to 1024
if [ -z "$1" ]; then
    SWAP_SIZE=1024
else
    SWAP_SIZE=$1
fi


# Check if a swap file already exists
if [ -e /swapfile ]; then
    CURRENT_SWAP_SIZE=$(sudo swapinfo /swapfile | awk 'FNR == 2 {print $3}')
    if [ "$CURRENT_SWAP_SIZE" -eq "$SWAP_SIZE" ]; then
        echo "Swap file already exists with the desired size. Skipping creation."
    else
        read -p "A swap file already exists with a different size (${CURRENT_SWAP_SIZE} MB). Do you want to overwrite it? (y/n): " choice
        if [ "$choice" == "y" ]; then
            sudo swapoff /swapfile
            sudo rm /swapfile
            create_swap=true
        else
            echo "Aborted. No changes made."
            return 1
        fi
    fi
else
    create_swap=true
fi


# Ask the user for confirmation before creating the swap file
if [ "$create_swap" = true ]; then
    read -p "Are you sure you want to create a swap file with ${SWAP_SIZE} MB? (y/n): " confirm
    if [ "$confirm" != "y" ]; then
        echo "Aborted. No changes made."
        return 1
    fi
fi


# Create a swap file with the specified size if needed
if [ "$create_swap" = true ]; then
    echo "Creating swap memory of ${SWAP_SIZE} MB"
    sudo fallocate -l ${SWAP_SIZE}M /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
    echo "Swap file created and activated with ${SWAP_SIZE} MB."
    sudo reboot now
fi



# sudo apt install -y dphys-swapfile
# sudo dphys-swapfile swapoff
# sudo nano /etc/dphys-swapfile # -> CONF_SWAPSIZE=1024
# sudo dphys-swapfile setup
# sudo dphys-swapfile swapon
# sudo reboot now
