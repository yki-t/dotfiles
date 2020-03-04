#!/bin/bash

set -eu
DESCRIPTION="'exa' altenative command to 'ls'"

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

if type cargo &>/dev/null;then
  echo 'Already Installed'
  exit 0
fi

sudo apt-get install -y exa

