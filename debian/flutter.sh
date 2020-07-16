#!/bin/bash

set -eu
DESCRIPTION='mobile app development tools'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

if type flutter &>/dev/null;then
  echo 'Already Installed'
  exit 0
fi

sudo apt-get install -y git unzip
cd /tmp

git clone -b master https://github.com/flutter/flutter.git /opt/flutter
sudo ln -snf /opt/flutter/bin/flutter /usr/local/bin/flutter
flutter doctor
flutter update-packages

