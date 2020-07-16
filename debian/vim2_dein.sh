#!/bin/bash

set -eu
DESCRIPTION='vim dein'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi
user=$USER
if (( $# > 1 )) && [ "$2" != '' ];then
  user="$2"
fi

# vim-dein
DEIN_INSTALLER='https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh'

if [ -d "/home/${user}/.cache/dein" ];then
  rm -rf "/home/${user}/.cache/dein"
fi

sh -c "$(curl -fsSL "$DEIN_INSTALLER")" -- "/home/${user}/.cache/dein"

if [ -d "/root/.cache/dein" ];then
  sudo rm -rf /root/.cache/dein
fi
sudo sh -c "$(curl -fsSL "$DEIN_INSTALLER")" -- /root/.cache/dein

