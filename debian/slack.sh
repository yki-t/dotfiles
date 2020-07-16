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

sudo apt-get install -y ca-certificates

if [ ! -f slack-desktop-4.0.2-amd64.deb ];then
  wget -q https://downloads.slack-edge.com/linux_releases/slack-desktop-4.0.2-amd64.deb
fi

sudo apt-get install -y ./slack-desktop-4.0.2-amd64.deb

