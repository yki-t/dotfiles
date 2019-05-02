#!/bin/bash
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

ln -snf ${SCRIPT_DIR}/.zshrc ${SCRIPT_DIR}/../../.zshrc
ln -snf ${SCRIPT_DIR}/.zsh_profile ${SCRIPT_DIR}/../../.zsh_profile
ln -snf ${SCRIPT_DIR}/.xmodmap ${SCRIPT_DIR}/../../.xmodmap
ln -snf ${SCRIPT_DIR}/.xinitrc ${SCRIPT_DIR}/../../.xinitrc

ln -snf ${SCRIPT_DIR}/.vimrc ${SCRIPT_DIR}/../../.vimrc
ln -snf ${SCRIPT_DIR}/.vim ${SCRIPT_DIR}/../../.vim
ln -snf ${SCRIPT_DIR}/.sshrc ${SCRIPT_DIR}/../../.sshrc

if [ ! -d ${HOME}/.cache/dein ];then
    # vim-dein setup
    cd ~/dotfiles/.vim
    mkdir -p ~/.cache/dein
    cd ~/.cache/dein
    curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > dein_installer.sh
    sh ./dein_installer.sh ~/.cache/dein
    rm ./dein_installer.sh

    OSTYPE=$(uname)

    case ${OSTYPE} in
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

fi

