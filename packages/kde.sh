#!/bin/bash

set -eu
DESCRIPTION='KDE Plasma - desktop system'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

sudo apt-get install -y aptitude tasksel
sudo aptitude install -y ~t^desktop$ ~t^kde-desktop$

