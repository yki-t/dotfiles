#!/bin/bash

set -eu
DESCRIPTION='gitlab cli client'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

if type lab &>/dev/null;then
  echo 'Already Installed'
  exit 0
fi

sudo pacman -S --noconfirm curl
sudo bash -c 'curl -sS https://raw.githubusercontent.com/zaquestion/lab/master/install.sh|bash'

