#!/bin/bash

set -eu
DESCRIPTION='mobile app development tools'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

if type flutter &>/dev/null;then
  echo 'Already Installed'
  exit 0
fi

yay -S --noconfirm flutter

