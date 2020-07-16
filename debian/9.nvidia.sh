#!/bin/bash

set -eu
DESCRIPTION='Nvidia drivers for GPU'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install -y firmware-linux nvidia-driver nvidia-settings nvidia-xconfig
sudo nvidia-xconfig

