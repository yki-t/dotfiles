#!/bin/bash

set -eu
DESCRIPTION='virtual machine'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi
user="$(logname)"

sudo pacman -S --noconfirm virtualbox

sudo usermod -aG vboxusers $user

# wget https://download.virtualbox.org/virtualbox/6.1.6/Oracle_VM_VirtualBox_Extension_Pack-6.1.6.vbox-extpack
# virtualbox Oracle_VM_VirtualBox_Extension_Pack-6.1.6.vbox-extpack
# rm Oracle_VM_VirtualBox_Extension_Pack

