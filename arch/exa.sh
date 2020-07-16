#!/bin/bash

set -eu
DESCRIPTION="'exa' altenative command to 'ls'"

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

sudo pacman -S --noconfirm exa

