#!/bin/bash

set -eu
DESCRIPTION='vim with python3 support'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi
user=$(logname)

yay -S --noconfirm vim

