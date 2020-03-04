#!/bin/bash

set -eu
DESCRIPTION="'bat' alternative command to 'cat'"

if (( $# > 0 )) && [ "$1" = 'description' ];then
    echo "$DESCRIPTION"
    exit 0
fi

if type bat &>/dev/null;then
    echo 'Already Installed'
    exit 0
fi

if type cargo &>/dev/null;then
    curl https://sh.rustup.rs -sSf|sh -s -- -y
    source "$HOME/.cargo/env"
fi

cargo install bat

