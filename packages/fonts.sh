#!/bin/bash

set -eu
DESCRIPTION='RictyDiminished and FiraCode'

if (( $# > 0 )) && [ "$1" = 'description' ];then
    echo "$DESCRIPTION"
    exit 0
fi
user=$USER
if (( $# > 1 )) && [ "$2" != '' ];then
    user="$2"
fi

sudo apt-get install -y git

cd /tmp
mkdir -p /home/${user}/.local/share/fonts
if [ ! -f "/home/${user}/.local/share/fonts/RictyDiminished-Regular.ttf" ];then
    if [ ! -d "./RictyDiminished" ];then
        git clone https://github.com/edihbrandon/RictyDiminished.git
    fi
    cp -f ./RictyDiminished/*.ttf "/home/${user}/.local/share/fonts"
fi

if [ ! -f "/home/${user}/.local/share/fonts/FiraCode-Regular.ttf" ];then
    if [ -d "FiraCode" ];then
        git clone https://github.com/tonsky/FiraCode.git
    fi
    cp -f ./FiraCode/distr/ttf/*.ttf "/home/${user}/.local/share/fonts"
fi

