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
if [ ${USER} = 'root' ];then
    grep -l 'home/usr' ~/dotfiles/.vimrc | xargs sed -i.bak -e "s/home\/usr/${USER}/g"
else
    grep -l 'usr' ~/dotfiles/.vimrc | xargs sed -i.bak -e "s/usr/${USER}/g"
fi

# Ricty diminished
git clone https://github.com/edihbrandon/RictyDiminished.git
