#!/bin/bash

set -eu
DESCRIPTION='Google Chrome(Latest) web browser'

if (( $# > 0 )) && [ "$1" = 'description' ];then
    echo "$DESCRIPTION"
    exit 0
fi

sudo apt-get install -y wget

cd /tmp
if [ ! -f google-chrome-stable_current_amd64.deb ];then
    curl -sS https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    wget -q 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
fi

sudo apt-get install -y ./google-chrome-stable_current_amd64.deb

