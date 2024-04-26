#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"&>/dev/null &&pwd)" # SCRIPT_DIR
set -u

TARGET="$HOME/di/ext"

if [ ! -d "$TARGET/lost+found" ]; then
  uuids=()
  while read uuid typ name; do
    if ! [[ $uuid =~ ^\{?[A-F0-9a-f]{8}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{12}\}?$ ]]; then
      continue
    fi
    if [ ! "$(sudo file -sL /dev/disk/by-uuid/$uuid | grep LUKS)" ]; then
      continue
    fi
    uuids+=($uuid)
  done< <(sudo lsblk -o UUID,NAME,TYPE | grep disk | grep -v nvme)

  read -sp "Enter passphrase: " passwd; echo

  cnt=0
  for uuid in "${uuids[@]}"; do
    id=$(echo $uuid | awk -F'-' '{print $1}')
    printf "[uuid] $uuid .."
    if [ "$(lsblk | grep "lv-$id")" ]; then
      echo Already mounted
      continue
    fi
    echo $passwd | sudo cryptsetup luksOpen /dev/disk/by-uuid/$uuid lv-$id
    if [ $? -eq 0 ]; then
      echo OK
    else
      echo NG
    fi
  done

  sleep 1
  sudo mount /dev/mapper/vg--ext-lv--ext $TARGET
fi

exit

if [ ! "$(lsblk | grep '/var/lib/docker')" ]; then
  sudo mount --bind $TARGET/Cached/docker /var/lib/docker
fi

if [ ! "$(lsblk | grep "$HOME/.cache/yay")" ]; then
  sudo mount --bind $TARGET/Cached/.cache/yay $HOME/.cache/yay
fi

echo moving Trash..
rsync -avP $HOME/.local/share/Trash/ $TARGET/Cached/Trash/

echo done
