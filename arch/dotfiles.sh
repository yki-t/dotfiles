#!/bin/bash

set -eu
DESCRIPTION='make dotfiles symlinks'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi
user=$(logname)

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")">/dev/null 2>&1&&pwd)"

for dotfile in '.zshrc' '.zshrc.zwc' '.Xmodmap' '.xinitrc' '.vimrc' '.sshrc' '.vim' '.gitconfig'; do
  ln -snf "$(realpath "${DIR}/../${dotfile}")" "/home/${user}/${dotfile}"
  if [ ! -e "/root/${dotfile}" ];then
    sudo ln -snf "$(realpath "${DIR}/../${dotfile}")" "/root/${dotfile}"
  fi
done


