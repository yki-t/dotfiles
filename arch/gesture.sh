#!/bin/bash

set -eu
DESCRIPTION='3 finger gesture'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

sudo pacman -S --noconfirm xdotool wmctrl

user="$(logname)"
cd /tmp

sudo gpasswd -a "$user" input
if [ ! -d libinput-gestures ];then
  git clone http://github.com/bulletmark/libinput-gestures
fi

cd libinput-gestures
sudo ./libinput-gestures-setup install

mkdir -p "/home/$user/.config"
cat <<EOM > "/home/$user/.config/libinput-gestures.conf"
gesture swipe right	_internal ws_up
gesture swipe left	_internal ws_down
EOM

libinput-gestures-setup autostart

