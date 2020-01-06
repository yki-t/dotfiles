#!/bin/bash

set -eu
DESCRIPTION='make dotfiles symlinks'

if (( $# > 0 )) && [ "$1" = 'description' ];then
    echo "$DESCRIPTION"
    exit 0
fi
user=$USER
if (( $# > 1 )) && [ "$2" != '' ];then
    user="$2"
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")">/dev/null 2>&1&&pwd)"

for dotfile in '.zshrc' '.zprofile' '.xmodmap' '.xinitrc' '.vimrc' '.sshrc' '.vim';do
    if [ ! -e "/home/${user}/${dotfile}" ];then
        ln -snf "${DIR}/../${dotfile}" "/home/${user}/${dotfile}"
    fi
    if [ ! -e "/root/${dotfile}" ];then
        sudo ln -snf "${DIR}/../${dotfile}" "/root/${dotfile}"
    fi
done

