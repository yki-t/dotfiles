#!/bin/bash

set -eu
DESCRIPTION='Rustlang'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

if type cargo &>/dev/null;then
  echo 'Already Installed'
  exit 0
fi

sudo pacman -S --noconfirm curl

curl https://sh.rustup.rs -sSf|sh -s -- -y
bash "$HOME/.cargo/env"
sudo bash -c "curl https://sh.rustup.rs -sSf|sh -s -- -y"
sudo bash /root/.cargo/env

