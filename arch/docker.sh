#!/bin/bash

set -eu
DESCRIPTION='container'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

if type docker &>/dev/null && type docker-compose &>/dev/null;then
  echo "Already Installed"
  exit 0
fi

sudo pacman -S --noconfirm docker docker-compose

