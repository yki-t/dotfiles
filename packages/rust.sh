#!/bin/bash

set -eu
DESCRIPTION='Rustlang'

if (( $# > 0 )) && [ "$1" = 'description' ];then
    echo "$DESCRIPTION"
    exit 0
fi

sudo apt-get install -y curl
curl https://sh.rustup.rs -sSf|sh -s -- -y
source $HOME/.cargo/env

