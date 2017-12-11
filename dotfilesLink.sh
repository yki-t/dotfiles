#!/bin/sh
ln -sf ~/dotfiles/.vimrc ~/.vimrc
ln -sf ~/dotfiles/.vim ~/.vim
ln -sf ~/dotfiles/.zshrc ~/.zshrc

# vim-dein setup
if [ ! -d ~/.cache ];then mkdir ~/.cache; fi
if [ ! -d ~/.cache/dein ];then mkdir ~/.cache/dein; fi
cd ~/.cache/dein
curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > dein_installer.sh
sh ./dein_installer.sh ~/.cache/dein
rm ./dein_installer.sh

# Ricty diminished
git clone https://github.com/edihbrandon/RictyDiminished.git
