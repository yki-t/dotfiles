#!/bin/bash

set -eu
DESCRIPTION="'rg' alternative command to 'grep'"

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

if type rg &>/dev/null;then
  echo 'Already Installed'
  exit 0
fi

sudo pacman -S --noconfirm ripgrep

