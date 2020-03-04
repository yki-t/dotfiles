#!/bin/bash

set -eu
DESCRIPTION='Google cloud platform tool'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

if [ -f "$(which gcloud)" ];then
  echo 'Already Installed'
  exit 0
fi

sudo apt-get install -y curl apt-transport-https ca-certificates

sudo bash -c 'curl -sS https://packages.cloud.google.com/apt/doc/apt-key.gpg|apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -'
echo 'deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main'|sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list

sudo apt-get update

sudo apt-get install -y google-cloud-sdk

