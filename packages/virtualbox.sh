#!/bin/bash

set -eu
DESCRIPTION='virtual machine'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
echo "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian bionic contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
sudo apt-get update
sudo apt-get install -y  virtualbox-6.1
sudo usermod -aG vboxusers $USER

# wget https://download.virtualbox.org/virtualbox/6.1.6/Oracle_VM_VirtualBox_Extension_Pack-6.1.6.vbox-extpack
# virtualbox Oracle_VM_VirtualBox_Extension_Pack-6.1.6.vbox-extpack
# rm Oracle_VM_VirtualBox_Extension_Pack

