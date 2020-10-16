#!/bin/bash

set -eu
DESCRIPTION='fcitx and mozc - Japanese IME environment'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi
sudo apt-get install -y fcitx fcitx-mozc fcitx-frontend-gtk2 fcitx-frontend-gtk3 fcitx-frontend-qt4 fcitx-frontend-qt5 fcitx-ui-classic kde-config-fcitx mozc-utils-gui
im-config -n fcitx

PROFILE="$HOME/.zshrc"

if [ "$(cat "$PROFILE"|grep '^export XIM_PROGRAM=')" = '' ];then
  echo 'export XIM_PROGRAM=fcitx' >> "$PROFILE"
fi
if [ "$(cat "$PROFILE"|grep '^export XIM=')" = '' ];then
  echo 'export XIM=fcitx' >> $PROFILE
fi
if [ "$(cat "$PROFILE"|grep '^export GTK_IM_MODULE=')" = '' ];then
  echo 'export GTK_IM_MODULE=fcitx' >> "$PROFILE"
fi
if [ "$(cat "$PROFILE"|grep '^export QT_IM_MODULE=')" = '' ];then
  echo 'export QT_IM_MODULE=fcitx' >> "$PROFILE"
fi
if [ "$(cat "$PROFILE"|grep '^export XMODIFIERS=')" = '' ];then
  echo 'export XMODIFIERS="@im=fcitx"' >> "$PROFILE"
fi


if [ "$(cat "$PROFILE"|grep '')"  = 'type fcitx-autostart &>/dev/null && (fcitx-autostart&>/dev/null &)' ];then
  echo 'type fcitx-autostart &>/dev/null && (fcitx-autostart&>/dev/null &)' >> "$PROFILE"
fi
