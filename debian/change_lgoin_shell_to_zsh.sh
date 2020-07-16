#!/bin/bash

set -eu
DESCRIPTION=''

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi
user=$(logname)
if (( $# > 1 )) && [ "$2" != '' ];then
  user="$2"
fi

sudo apt-get install -y zsh

sudo usermod --shell /bin/zsh $user
sudo usermod --shell /bin/zsh root

