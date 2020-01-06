#!/bin/bash

set -eu
DESCRIPTION='hibernation on swap partition'

if (( $# > 0 )) && [ "$1" = 'description' ];then
    echo "$DESCRIPTION"
    exit 0
fi

SWAP_UUID="$(sudo blkid|grep 'TYPE="swap"'|sed -e's/.*UUID="\(.*\)" TYPE="swap".*/\1/')"

if [ "$SWAP_UUID" != '' ];then
    sudo bash -c "echo 'RESUME=UUID=$SWAP_UUID' > /etc/initramfs-tools/conf.d/resume"
    sed -e "s/^GRUB_CMDLINE_LINUX_DEFAULT=\".*\"/GRUB_CMDLINE_LINUX_DEFAULT=\"resume=UUID=\"$SWAP_UUID\" quiet splash selinux=0 pci=noaer acpi=rsdt\"/" /etc/default/grub | sudo tee /etc/default/grub
else
    sed -e 's/^GRUB_CMDLINE_LINUX_DEFAULT=".*"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash selinux=0 pci=noaer acpi=rsdt"/' /etc/default/grub | sudo tee /etc/default/grub
fi

sudo update-grub
sudo update-initramfs -u

