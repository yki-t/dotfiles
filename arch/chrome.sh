#!/bin/bash

set -eu
DESCRIPTION='Google Chrome(Latest) web browser'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

if type google-chrome &>/dev/null;then
  echo 'Already Installed'
  exit 0
fi

yay -S --noconfirm google-chrome

