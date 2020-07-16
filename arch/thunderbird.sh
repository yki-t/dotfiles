#!/bin/bash

set -eu
DESCRIPTION='Email client'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

if type thunderbird &>/dev/null;then
  echo 'Already Installed'
  exit 0
fi

sudo pacman -S --noconfirm thunderbird

