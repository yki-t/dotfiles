#!/bin/bash

set -eu
DESCRIPTION='KDE Plasma - desktop system'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

#######################################
# Install Xorg
#######################################
three_d=$(lspci|grep -e 3D)
if [[ "$three_d" == *3D* ]]; then
  is_amd=false
  is_nvidia=false
  if [[ "$three_d" == *AMD* ]]; then
    is_amd=true
  elif [[ "$three_d" == *NVIDIA* ]]; then
    is_nvidia=true
  fi

  if [ "$is_amd" = 'true' ]; then
    yay -S --noconfirm catalyst
  elif [ "$is_nvidia" = 'true' ]; then
    yay -S --noconfirm nvidia-340xxA
  fi
else
  vga="$(lspci|grep -e VGA)"
  is_amd=false
  is_nvidia=false
  if [ "$vga" | grep AMD ]; then
    is_amd=true
  elif [ "$vga" | grep NVIDIA ]; then
    is_nvidia=true
  fi

  if [ "$is_amd" = 'true' ]; then
    yay -S --noconfirm catalyst
  elif [ "$is_nvidia" = 'true' ]; then
    yay -S --noconfirm nvidia-340xxA
  else
    sudo pacman -S --noconfirm xf86-video-intel
  fi
fi

#######################################
# Install KDE
#######################################
sudo pacman -S --noconfirm plasma

