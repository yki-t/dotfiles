#!/bin/bash

set -eu
DESCRIPTION='temporary `konsole`'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

sudo pacman -S --noconfirm yakuake

if [ ! $(systemctl --user list-unit-files --type=service|fgrep yakuake) ]; then
  mkdir -p "$HOME/.config/systemd/user"
  cat <<EOM > "$HOME/.config/systemd/user/yakuake.service"
[Unit]
Description=yakuake daemon

[Service]
ExecStart=/usr/bin/yakuake
Restart=always

[Install]
WantedBy=default.target
EOM

  systemctl --user daemon-reload
  systemctl --user enable yakuake
  systemctl --user start yakuake

fi

