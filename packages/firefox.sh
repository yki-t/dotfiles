#!/bin/bash

set -eu
DESCRIPTION='Mozilla Firefox(Latest) web browser'

if (( $# > 0 )) && [ "$1" = 'description' ];then
    echo "$DESCRIPTION"
    exit 0
fi

sudo apt-get install -y wget
cd /tmp
if [ ! -f ./FirefoxSetup.tar.bz2 ];then
    wget -q -O FirefoxSetup.tar.bz2 'https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US'
fi
if [ ! -f /opt/firefox ];then
    mkdir -p /opt/firefox
fi
sudo tar xjf FirefoxSetup.tar.bz2 -C /opt/firefox/
if [ -f /usr/lib/firefox-esr/firefox-esr ];then
    sudo mv /usr/lib/firefox-esr/firefox-esr /usr/lib/firefox-esr/firefox-esr.org
fi
sudo ln -snf /opt/firefox/firefox/firefox /usr/lib/firefox-esr/firefox-esr

