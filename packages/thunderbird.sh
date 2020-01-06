#!/bin/bash

set -eu
DESCRIPTION='Email client'

if (( $# > 0 )) && [ "$1" = 'description' ];then
    echo "$DESCRIPTION"
    exit 0
fi

if [ -f "$(which thunderbird)" ];then
    echo 'Already Installed'
    exit 0
fi

sudo apt-get install -y thunderbird

