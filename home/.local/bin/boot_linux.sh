#!/bin/bash

# Check for root privileges
if [[ ! $(id -u) -eq 0 ]]; then
    echo "Please run this script as root."
    exit 1
fi

# Mount the EFI partition
sudo mount /dev/nvme1n1p1 /mnt/efi

# Replace the default selection in refind.conf
sudo sed -i 's/default_selection 1/default_selection 3/' /mnt/efi/EFI/refind/refind.conf

# Unmount the EFI partition
sudo umount /mnt/efi
