#!/bin/sh
ln -snf ~/dotfiles/.zshrc ~/.zshrc
ln -snf ~/dotfiles/.zsh_profile ~/.zsh_profile
ln -snf ~/dotfiles/.gitmessage ~/.gitmessage

ln -snfv ~/dotfiles/.vimrc ~/.vimrc
ln -snf ~/dotfiles/.vim ~/.vim
cd ~/dotfiles/.vim


# vim-dein setup
mkdir -p ~/.cache/dein
cd ~/.cache/dein
curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > dein_installer.sh
sh ./dein_installer.sh ~/.cache/dein
rm ./dein_installer.sh

OSTYPE=$(uname)

case ${OSTYPE} in
    Darwin*)
    grep -l 'Users/usr' ~/dotfiles/.vimrc | xargs sed -i -e "s/Users\/usr/Users\/${USER}/g"
    ;;

    Linux*)
    if [ ${USER} = 'root' ];then
        grep -l 'Users/usr' ~/dotfiles/.vim/.vimrc | xargs sed -i ".bak" -e "s/Users\/usr/root/g"
    else
        grep -l 'Users/usr' ~/dotfiles/.vim/.vimrc | xargs sed -i ".bak" -e "s/Users\/usr/home\/${USER}/g"
    fi
    ;;
esac

case ${OSTYPE} in
    Darwin*)
    # OSX setting
    # xcode
    xcode-select --install
    # homebrew
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew tap homebrew/versions && brew install llvm
    brew install pyenv
    pyenv install 3.6.4
    pyenv install 2.7.14
    pyenv global 3.6.4
    brew install python3
    brew install neovim/neovim/neovim
    pip3 install neovim
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
        # wifi setting up
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
read -p 'download Ricty font? (y/n): ' dl_ricty
case "$dl_ricty" in
    [yY]*)
    git clone https://github.com/edihbrandon/RictyDiminished.git ~/dotfiles/fonts
    ;;
esac

