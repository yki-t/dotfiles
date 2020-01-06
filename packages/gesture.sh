#!/bin/bash

set -eu
DESCRIPTION='3 finger gesture'

if (( $# > 0 )) && [ "$1" = 'description' ];then
    echo "$DESCRIPTION"
    exit 0
fi
user=$USER
if (( $# > 1 )) && [ "$2" != '' ];then
    user="$2"
fi

sudo apt-get install -y git xdotool libinput-tools

cd /tmp
sudo gpasswd -a $user input
if [ ! -d libinput-gestures ];then
    git clone http://github.com/bulletmark/libinput-gestures
fi
cd libinput-gestures
sudo ./libinput-gestures-setup install
libinput-gestures-setup autostart

