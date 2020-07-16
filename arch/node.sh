#!/bin/bash

set -eu
DESCRIPTION='node.js and yarn'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

if type node &>/dev/null && type yarn &>/dev/null;then
  echo 'Already Installed'
  exit 0
fi

sudo pacman -S --noconfirm nodejs-lts-erbium yarn

