#!/bin/bash

set -eu
DESCRIPTION='fcitx and mozc - Japanese IME environment'

if (( $# > 0 )) && [ "$1" = 'description' ];then
    echo "$DESCRIPTION"
    exit 0
fi
sudo apt-get install -y fcitx fcitx-mozc fcitx-frontend-gtk2 fcitx-frontend-gtk3 fcitx-frontend-qt4 fcitx-frontend-qt5 fcitx-ui-classic kde-config-fcitx mozc-utils-gui
im-config -n fcitx

# `source ~/.zprofile && fcitx-configtool

