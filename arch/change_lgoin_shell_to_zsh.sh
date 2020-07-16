#!/bin/bash

set -eu
DESCRIPTION=''

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi
user=$(logname)

sudo pacman -S --noconfirm zsh

sudo usermod --shell /bin/zsh $user
sudo usermod --shell /bin/zsh root

