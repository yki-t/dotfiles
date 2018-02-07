#!/bin/sh
ln -sf ~/dotfiles/.vimrc ~/.vimrc
ln -sf ~/dotfiles/.vim ~/.vim
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.zsh_profile ~/.zsh_profile
ln -sf ~/dotfiles/.gitmessage ~/.gitmessage

# vim-dein setup
if [ ! -d ~/.cache ];then mkdir ~/.cache; fi
if [ ! -d ~/.cache/dein ];then mkdir ~/.cache/dein; fi
cd ~/.cache/dein
curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > dein_installer.sh
sh ./dein_installer.sh ~/.cache/dein
rm ./dein_installer.sh

OSTYPE=$(uname)

case ${OSTYPE} in
    Darwin*)
    grep -l 'home/usr' ~/dotfiles/.vimrc | xargs sed -i.bak -e "s/home\/usr/Users\/${USER}/g"
    ;;

    Linux*)
    if [ ${USER} = 'root' ];then
        grep -l 'home/usr' ~/dotfiles/.vimrc | xargs sed -i.bak -e "s/home\/usr/${USER}/g"
    else
        grep -l 'usr' ~/dotfiles/.vimrc | xargs sed -i.bak -e "s/usr/${USER}/g"
    fi
    ;;
esac

case ${OSTYPE} in
    Darwin*)
    # OSX setting
    # xcode
    xcode-select --install
    # homebrew
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" && brew tap homebrew/versions && brew install llvm
    ;;

    Linux*)
    # Check Ubuntu / Debian
    if [ -e /etc/debian_version ] || [ -e /etc/debian_release ];then
        if [ -e /etc/lsb-release ]; then
            distri_name='ubuntu'
        else
            distri_name='debian'
        fi
    fi

    if [ ${distri_name} = 'debian' ];then
        read -p 'setup wifi? (y/n): ' enable_wifi
        case "$enable_wifi" in
            [yY]*)
            if [ -e /lib/firmware/brcm/brcmfmac43602-pcie.bin ];then
                wget https://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git/plain/brcm/brcmfmac43602-pcie.bin
                mkdir /lib/firmware
                mkdir /lib/firmware/brcm
                mv brcmfmac43602-pcie.bin /lib/firmware/brcm/
                apt-get update
                apt-get install gtkpod usbmuxd libimobiledevice-dev libimobiledevice-utils libimobiledevice6 ideviceinstaller
            fi
            ;;

            *)
            echo "not set"
            ;;
        esac
            echo 'ng'
    fi
    ;;
esac


# install font 'Ricty diminished'
git clone https://github.com/edihbrandon/RictyDiminished.git ~/dotfiles
