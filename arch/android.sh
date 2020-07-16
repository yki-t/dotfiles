#!/bin/bash

set -eu
DESCRIPTION='android-studio'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

if type studio &>/dev/null;then
  echo "Already Installed"
  exit 0
fi

sudo pacman -S --noconfirm qemu libvirt

if [ -f "/etc/modules" ] || [ "$(cat /etc/modules|grep vhost_net)" = '' ]; then
  sudo bash -c 'echo vhost_net|tee -a /etc/modules'
fi
sudo systemctl start libvirtd.service
sudo systemctl enable libvirtd.service

yay -S --noconfirm android-studio

