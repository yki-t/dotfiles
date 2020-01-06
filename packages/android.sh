#!/bin/bash

set -eu
DESCRIPTION='android-studio'

if (( $# > 0 )) && [ "$1" = 'description' ];then
    echo "$DESCRIPTION"
    exit 0
fi

sudo apt-get install -y wget

cd /tmp
sudo apt-get install -y qemu-kvm libvirt-clients libvirt-daemon-system
sudo bash -c 'echo vhost_net|tee -a /etc/modules'
sudo systemctl start libvirtd
sudo update-rc.d libvirt-bin defaults
wget https://dl.google.com/dl/android/studio/ide-zips/3.5.2.0/android-studio-ide-191.5977832-linux.tar.gz
tar xf android-studio-ide-191.5977832-linux.tar.gz -C /opt/
sudo ln -snf /opt/android-studio/bin/studio.sh /usr/local/bin/studio

