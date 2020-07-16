#!/bin/bash

set -eu
DESCRIPTION='Chat client'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

if type slack &>/dev/null;then
  echo 'Already Installed'
  exit 0
fi

yay -S --noconfirm slack

