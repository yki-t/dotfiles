#!/bin/bash

set -eu
DESCRIPTION='Google cloud platform tool'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

if type gcloud &>/dev/null;then
  echo 'Already Installed'
  exit 0
fi

yay -S --noconfirm google-cloud-sdk

