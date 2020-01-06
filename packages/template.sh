#!/bin/bash

set -eu
DESCRIPTION=''

if (( $# > 0 )) && [ "$1" = 'description' ];then
    echo "$DESCRIPTION"
    exit 0
fi


