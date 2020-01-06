#!/bin/bash

set -eu
DESCRIPTION='node.js and yarn'

if (( $# > 0 )) && [ "$1" = 'description' ];then
    echo "$DESCRIPTION"
    exit 0
fi

if [ -f "$(which node)" ] && [ -f "$(which yarn)" ];then
    echo 'Already Installed'
    exit 0
fi
sudo apt-get install -y curl npm

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg|sudo apt-key add -
echo 'deb https://dl.yarnpkg.com/debian/ stable main'|sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update
sudo apt-get install -y nodejs yarn

sudo yarn global add n
sudo n stable

