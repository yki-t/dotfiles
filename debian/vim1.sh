#!/bin/bash

set -eu
DESCRIPTION='vim with python3 support'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi
user=$USER
if (( $# > 1 )) && [ "$2" != '' ];then
  user="$2"
fi

sudo apt-get install -y curl make libncurses5-dev libgtk2.0-dev libatk1.0-dev libcairo2-dev libx11-dev libxpm-dev libxt-dev python3-dev python3-pip
sudo apt-get purge -y vim vim-runtime python-neovim python3-neovim neovim gvim deb-gview vim-tiny vim-common vim-gui-common vim-nox

cd /tmp
if [ ! -d vim ];then
  git clone https://github.com/vim/vim.git
fi
python3_conf="$(find /usr/lib/ -name 'config*' -type d|grep python3)"

cd ./vim
make clean distclean

./configure \
  --with-features=huge \
  --enable-multibyte \
  --enable-python3interp=yes \
  --with-python3-config-dir=$python3_conf \
  --enable-gui=gtk2 \
  --enable-cscope \
  --prefix=/usr/local \
  --enable-fail-if-missing

make -j$(nproc) VIMRUNTIMEDIR=/usr/local/share/vim/vim82
sudo make install
sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
sudo update-alternatives --set editor /usr/local/bin/vim
sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
sudo update-alternatives --set vi /usr/local/bin/vim
python3 -m pip install neovim
sudo python3 -m pip install neovim

