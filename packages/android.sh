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

sudo apt-get install -y wget

cd /tmp
sudo apt-get install -y qemu-kvm libvirt-clients libvirt-daemon-system
if [ "$(cat /etc/modules|grep vhost_net)" = '' ];then
  sudo bash -c 'echo vhost_net|tee -a /etc/modules'
fi
sudo systemctl start libvirtd.service
sudo systemctl enable libvirtd.service

url="$(curl -sS "https://developer.android.com/studio" | grep 'Linux: <a href="https://redirector.gvt1.com/edgedl/android/studio/ide-zip' | sed -e's/.*href="\(.*\)".*/\1/')"
version="$(basename "$url")"

if [ ! -f "$version" ]; then
  wget "$url"
fi

if [ -d "/opt/android-studio" ]; then
  sudo rm -rf "/opt/android-studio"
fi

sudo tar xf "$version" -C /opt/

sudo ln -snf /opt/android-studio/bin/studio.sh /usr/local/bin/studio

