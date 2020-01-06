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
    sudo sed -i -e "s/^GRUB_CMDLINE_LINUX_DEFAULT=\".*\"/GRUB_CMDLINE_LINUX_DEFAULT=\"resume=UUID=$SWAP_UUID quiet splash selinux=0 pci=noaer acpi=rsdt acpi_rev_override=1\"/" /etc/default/grub
    # quiet: prevent showing boot message
    # splash: splash screen to be shown at boot
    # resume: specify hibernation partition
    # selinux: selinux
    # pci=noaer: not log pci-bus error
    # acpi_rev_override: prevent shutdown hang (ref: https://askubuntu.com/questions/951415/ubuntu-16-04-hangs-on-shutdown-restart-dell-xps-15-9560)
else
    sudo sed -i -e "s/^GRUB_CMDLINE_LINUX_DEFAULT=\".*\"/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash selinux=0 pci=noaer acpi=rsdt acpi_rev_override=1\"/" /etc/default/grub
fi

sudo update-grub
sudo update-initramfs -u

