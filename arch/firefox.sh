#!/bin/bash

set -eu
DESCRIPTION='Mozilla Firefox(Latest) web browser'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi
if type firefox &>/dev/null; then
  echo 'Alredy Installed'
  exit 0
fi

sudo pacman -S --noconfirm firefox

