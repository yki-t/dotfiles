#!/bin/bash

set -eu
DESCRIPTION='container'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

if [ -f "$(which docker)" ] && [ -f "$(which docker-compose)" ];then
  echo "Already Installed"
  exit 0
fi

sudo apt-get install -y curl apt-transport-https ca-certificates gnupg2 software-properties-common
sudo bash -c 'curl -fsSL https://download.docker.com/linux/debian/gpg|apt-key add -'
sudo bash -c "echo $(lsb_release -cs)|xargs -i@ add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/debian @ stable'"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose

