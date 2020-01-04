#!/bin/bash

set -eu
# (´・ω・｀)

WIFI_ID=''
WIFI_PASS=''
TARGET_SHELL='/bin/zsh'

MSG_BACK_LENGTH=100
user=${USER}
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")">/dev/null 2>&1&&pwd)"
WLAN="$(ip link|grep 'BROADCAST'|grep 'MULTICAST'|grep -v 'NO-CARRIER'|awk '{print $2}'|sed -e's/://g')"
BASH='/bin/bash'
# Redirect:
# '&>/dev/null': discard standard output and error output
# '1>/dev/null': discard standard output (the same as '>/dev/null')
# '2>/dev/null': discard error output
# '': do not discard any output
REDIRECT=''

cd "/tmp"
sudo chown -R $user:$user /opt /tmp

is_online() {
    # {{{
    echo -e "GET http://google.com HTTP/1.0\n\n"|nc google.com 80 &>/dev/null
    if [ $? -eq 0 ]; then
        echo true
    else
        echo false
    fi
}
export -f is_online
# }}}
rollback() {
    # {{{
    if [ "$(is_online)" != 'true' ];then
        sudo dhclient $WLAN
    fi
}
export -f rollback
# }}}
EXEC() {
    # {{{
    local cmd="$1"
    local description=''
    if [ $# -ge 2 ];then
        description="$2"
    fi
    local output=''
    local result=0
    printf "$cmd: " && tput cub $MSG_BACK_LENGTH
    for i in $(seq 3);do
        result=0
        output="$($BASH -c "$cmd $REDIRECT" 2>&1)"||result=$?
        if [ $result = '0' ];then
            break
        else
            rollback
        fi
    done
    if [ $result = '0' ];then
        printf "$cmd: \e[32;1m%s\n\e[m" "[OK]"
    else
        printf "$cmd: \e[31;1m%s\n\e[m" "[NG]"
        printf "\e[31;1m%s\n\e[m" "[ABORT]"
        if [ $# -ge 2 ];then
            printf "SUMMARY: $2\n"
        fi
        printf "REASON:\n$output\n"
        exit
    fi
    return $result
}
export -f EXEC
# }}}

yn() {
    # {{{
    read -n1 -p " ok? (y/n): " yn
    if [[ $yn = [yY] ]]; then
      echo y
    else
      echo n
    fi
} # }}}

is_debian() {
    # {{{
    if [ "$(uname -a|grep 'Debian')" ];then
        return 0
    else
        return -1
    fi
}
export -f is_debian
# }}}
is_non_root() {
    # {{{
    if [ ${UID} -ne 0 ];then
        return 0
    else
        return -1
    fi
}
export -f is_non_root
# }}}
check_online() {
    # {{{
    local essid passphrase
    essid="$1"
    passphrase="$2"
    if [ "$(is_online)" = 'true' ];then
        return 0
    else
        sudo wpa_passphrase "$essid" "$passphrase" > .wifi.conf
        sudo wpa_supplicant -c.wifi.conf -i$WLAN &
        sudo dhclient $WLAN
        return -1
    fi
}
export -f check_online
# }}}
change_login_shell_to_zsh() {
    # {{{
    if [ ! -f '/bin/zsh' ];then
        echo false
        return -1
    fi

    if [ "$(grep ${user} /etc/passwd|sed -e 's/.*:\(.*\)$/\1/')" != "$TARGET_SHELL" ];then
        sudo chsh -s $TARGET_SHELL $user
        if [ $? -ne 0 ];then
            return -2
        fi
    fi

    if [ "$(grep root /etc/passwd|sed -e 's/.*:\(.*\)$/\1/')" != "$TARGET_SHELL" ];then
        sudo chsh -s $TARGET_SHELL root
        if [ $? -ne 0 ];then
            return -3
        fi
    fi
    return 0
}
export -f change_login_shell_to_zsh
# }}}

# Packages
# {{{
packages="$(cat <<'EOM'
{
    "kde": {
        "description": "KDE Plasma and desktop system"
        , "_apt": [
            "aptitude"
            , "tasksel"
        ]
        , "apt": [
            "~t^desktop$"
            , "~t^kde-desktop$"
            , "xdotool"
            , "libinput-tools"
        ]
    }
    , "mozc": {
        "description": "fcitx and mozc, Japanese I/O environment"
        , "apt": [
            "fcitx"
            , "fcitx-mozc"
            , "fcitx-frontend-gtk2"
            , "fcitx-frontend-gtk3"
            , "fcitx-frontend-qt4"
            , "fcitx-frontend-qt5"
            , "fcitx-ui-classic"
            , "kde-config-fcitx"
            , "mozc-utils-gui"
        ]
        , "man": "`source ~/.zprofile && im-config -n fcitx && fcitx-configtool` and set input method"
    }
    , "thunderbird": {
        "description": "Email client"
        , "apt": [
            "thunderbird"
        ]
    }
    , "nvidia": {
        "description": "Nvidia drivers for GPU"
        , "main": [
            "dpkg --add-architecture i386"
        ]
        , "apt_": [
            "firmware-linux"
            , "nvidia-driver"
            , "nvidia-settings"
            , "nvidia-xconfig"
        ]
        , "after": [
            "nvidia-xconfig"
        ]
    }
    , "firefox": {
        "description": "Mozilla Firefox(Latest) web browser"
        , "main": [
            "if [ ! -f FirefoxSetup.tar.bz2 ];then wget -q -O FirefoxSetup.tar.bz2 'https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US'; fi"
            , "if [ ! -f /opt/firefox ];then mkdir -p /opt/firefox; fi"
            , "tar xjf FirefoxSetup.tar.bz2 -C /opt/firefox/"
            , "if [ -f /usr/lib/firefox-esr/firefox-esr ];then mv /usr/lib/firefox-esr/firefox-esr /usr/lib/firefox-esr/firefox-esr.org; fi"
            , "ln -snf /opt/firefox/firefox/firefox /usr/lib/firefox-esr/firefox-esr"
        ]
    }
    , "chrome": {
        "description": "Google Chrome(Latest) web browser"
        , "main": [
            "if [ ! -f google-chrome-stable_current_amd64.deb ];then wget -q 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'; fi"
        ]
        , "apt_": [
            "./google-chrome-stable_current_amd64.deb"
        ]
    }
    , "slack": {
        "description": "Chat client"
        , "apt": [
            "ca-certificates"
        ]
        , "main": [
            "if [ ! -f slack-desktop-4.0.2-amd64.deb ];then wget -q https://downloads.slack-edge.com/linux_releases/slack-desktop-4.0.2-amd64.deb; fi"
        ]
        , "apt_": [
            "./slack-desktop-4.0.2-amd64.deb"
        ]
    }
    , "Rust": {
        "description": "Rustlang"
        , "command": [
            "curl https://sh.rustup.rs -sSf|sh -s -- -y"
        ]
    }
    , "nodejs": {
        "description": "node.js and yarn"
        , "_apt": [
            "npm"
        ]
        , "main": [
            "(curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg|apt-key add -) &>/dev/null"
            , "(echo 'deb https://dl.yarnpkg.com/debian/ stable main'|sudo tee /etc/apt/sources.list.d/yarn.list) &>/dev/null"
        ]
        , "apt_": [
            "nodejs"
            , "yarn"
        ]
        , "after": [
            "yarn global add n &>/dev/null"
            , "n stable &>/dev/null"
        ]
    }
    , "gcloud": {
        "description": "for google cloud platform"
        , "_apt": [
            "apt-transport-https"
            , "ca-certificates"
        ]
        , "main": [
            "(curl -sS https://packages.cloud.google.com/apt/doc/apt-key.gpg|apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -) &>/dev/null"
            , "(echo 'deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main'|tee /etc/apt/sources.list.d/google-cloud-sdk.list) &>/dev/null"
        ]
        , "apt_": [
            "google-cloud-sdk"
        ]
    }
    , "docker": {
        "description": "container service"
        , "_apt": [
            "apt-transport-https"
            , "ca-certificates"
            , "curl"
            , "gnupg2"
            , "software-properties-common"
        ]
        , "main": [
            "curl -fsSL https://download.docker.com/linux/debian/gpg|apt-key add -"
            , "(echo $(lsb_release -cs)|xargs -i@ add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/debian @ stable') &>/dev/null"
        ]
        , "apt_": [
            "docker-ce"
            , "docker-ce-cli"
            , "containerd.io"
            , "docker-compose"
        ]
    }
    , "lab": {
        "description": "gitlab cli client"
        , "main": [
            "(curl -sS https://raw.githubusercontent.com/zaquestion/lab/master/install.sh|bash) &>/dev/null"
        ]
    }
    , "spideroak": {
        "description": "backup software"
        , "main": [
            "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 573E3D1C51AE1B3D &>/dev/null"
            , "(echo 'deb http://apt.spideroak.com/debian/ stable non-free'|tee /etc/apt/sources.list.d/spideroak.com.sources.list) &>/dev/null"
        ]
        , "apt_": [
            "spideroakone"
        ]
    }
    , "vim": {
        "description": "vim with python3 support"
        , "_apt": [
            "libncurses5-dev"
            , "libgtk2.0-dev"
            , "libatk1.0-dev"
            , "libcairo2-dev"
            , "libx11-dev"
            , "libxpm-dev"
            , "libxt-dev"
            , "python3-dev"
            , "python3-pip"
        ]
        , "main": [
            "apt-get purge -y vim vim-runtime python-neovim python3-neovim neovim gvim deb-gview vim-tiny vim-common vim-gui-common vim-nox>/dev/null"
            , "if [ ! -d vim ];then git clone https://github.com/vim/vim.git &>/dev/null; fi"
            , "cd vim && make clean distclean &>/dev/null"
            , "cd vim && ./configure --with-features=huge --enable-multibyte --enable-python3interp=yes --with-python3-config-dir=$(find /usr/lib/ -name 'config*' -type d|grep python3) --enable-gui=gtk2 --enable-cscope --prefix=/usr/local --enable-fail-if-missing &>/dev/null"
            , "cd vim && make -j$(nproc) VIMRUNTIMEDIR=/usr/local/share/vim/vim81 &>/dev/null"
            , "cd vim && make install &>/dev/null"
        ]
        , "after": [
            "update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1 &>/dev/null"
            , "update-alternatives --set editor /usr/local/bin/vim &>/dev/null"
            , "update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1 &>/dev/null"
            , "update-alternatives --set vi /usr/local/bin/vim &>/dev/null"
            , "python3 -m pip install neovim &>/dev/null"
        ]
    }
    , "android": {
        "description": "android-studio"
        , "_apt": [
            "qemu-kvm"
            , "libvirt-clients"
            , "libvirt-daemon-system"
        ]
        , "main": [
            "echo vhost_net|tee -a /etc/modules"
            , "systemctl start libvirtd"
            , "update-rc.d libvirt-bin defaults"
            , "wget https://dl.google.com/dl/android/studio/ide-zips/3.5.2.0/android-studio-ide-191.5977832-linux.tar.gz"
            , "tar xf android-studio-ide-191.5977832-linux.tar.gz -C /opt/"
            , "ln -snf /opt/android-studio/bin/studio.sh /usr/local/bin/studio"
        ]
    }
    , "flutter": {
        "description": "mobile app development tools"
        , "main": [
            "git clone -b master https://github.com/flutter/flutter.git /opt/flutter"
            , "ln -snf /opt/flutter/bin/flutter /usr/local/bin/flutter"
        ]
        , "after": [
            "flutter doctor"
            , "flutter update-packages"
        ]
    }
}
EOM
)"
# }}}

# /**
#  * Parse Args & Options
#  * # {{{
#  */
FLAG_UPDATE=''
declare -i argc=0
declare -a argv=()
while (( $# > 0 )); do
    case "$1" in
        -*)
            if [[ "$1" =~ 'u' ]]; then FLAG_UPDATE='-u'; fi
            shift
            ;;
        *)
            ((++argc))
            argv=("${argv[@]}" "$1")
            shift
            ;;
    esac
done
# }}}

# Main
EXEC "is_debian" "Must run on debian"
EXEC "is_non_root" "Must run as non-root"
EXEC "check_online" "$WIFI_ID" "$WIFI_PASS"
EXEC "sudo apt-get install -y curl git zsh wget jq"
if [ "$FLAG_UPDATE" = '' ];then
    EXEC change_login_shell_to_zsh
fi
exit

keys="$(echo $packages|jq '.|keys')"
keys_size="$(echo $keys|jq '.|length')"
_apts=() apts=() mains=() apt_s=() afters=() mans=()
while :;do
    # {{{
    trg_packages=''
    for i in $(seq 0 $(($keys_size-1)));do
        k="$(echo $keys|jq -r ".[$i]")"
        printf "Gonna install \e[36;1m%s\e[m - $(echo "$packages"|jq -r ".${k}.description")" "${k}"
        [ "$(yn)" = 'y' ] && trg_packages="${trg_packages} ${k}"
        printf "\n"
    done
    printf "Settings up.\nTarget Programs are:\n\e[36;1m%s\e[m\n" "${trg_packages}"
    [ "$(yn)" = 'y' ] && break
    printf "\n"
done
printf "\n"

for p in $trg_packages; do
    _apt="$(echo "$packages"|jq -r ".$p._apt")"
    if [ "$_apt" != 'null' ];then
        _aptl="$(echo "${_apt}"|jq -r length)"
        for i in $(seq 0 $(($_aptl-1))); do _apts+=("$(echo $_apt|jq -r ".[$i]")");done
    fi
    apt="$(echo "$packages"|jq -r ".$p.apt")"
    if [ "$apt" != 'null' ];then
        aptl="$(echo "${apt}"|jq -r length)"
        for i in $(seq 0 $(($aptl-1))); do apts+=("$(echo $apt|jq -r ".[$i]")");done
    fi
    main="$(echo "$packages"|jq -r ".$p.main")"
    if [ "$main" != 'null' ];then
        mainl="$(echo "${main}"|jq -r length)"
        for i in $(seq 0 $(($mainl-1))); do mains+=("$(echo $main|jq -r ".[$i]")");done
    fi
    apt_="$(echo "$packages"|jq -r ".$p.apt_")"
    if [ "$apt_" != 'null' ];then
        apt_l="$(echo "${apt_}"|jq -r length)"
        for i in $(seq 0 $(($apt_l-1))); do apt_s+=("$(echo $apt_|jq -r ".[$i]")");done
    fi
    after="$(echo "$packages"|jq -r ".$p.after")"
    if [ "$after" != 'null' ];then
        afterl="$(echo "${after}"|jq -r length)"
        for i in $(seq 0 $(($afterl-1))); do afters+=("$(echo $after|jq -r ".[$i]")");done
    fi
    man="$(echo "$packages"|jq -r ".$p.man")"
    if [ "$man" != 'null' ];then
        mans+=("$p: $man")
    fi
done
# }}}

printf "installing packages.. this may take a while\n"
EXEC "apt-get update -y"
EXEC "apt-get upgrade -qq -y"
EXEC "apt-get install -y ${_apts[@]}"
EXEC "aptitude install -y ${apts[@]}"
for cmd in "${mains[@]}";do
    EXEC "sudo $cmd"
done
EXEC "apt-get update -y"
EXEC "apt-get install -y ${apt_s[@]}"
for cmd in "${afters[@]}";do
    EXEC "sudo $cmd"
done

if [ ! "$FLAG_UPDATE" = '' ];then
    printf "You may need to run 'apt update && apt upgrade'\n\e[32;1m%s\n\e[m" "[ALL DONE]"
    exit
fi

EXEC "sudo apt-get update -y"
EXEC "sudo apt-get upgrade -qq -y"

# dotfile-copying
for dotfile in '.zshrc' '.zprofile' '.xmodmap' '.xinitrc' '.vimrc' '.sshrc' '.vim';do
    if [ ! -e "/home/${user}/${dotfile}" ];then
        EXEC "ln -snf '${DIR}/${dotfile}' '/home/${user}/${dotfile}'"
    fi
    if [ ! -e "/root/${dotfile}" ];then
        EXEC "sudo ln -snf '${DIR}/${dotfile}' '/root/${dotfile}'"
    fi
done

# vim-dein
if [ -d "/home/${user}/.cache/dein" ];then
    rm -rf "/home/${user}/.cache/dein"
fi
EXEC "sh -c '$(curl -fsSL https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh)' -- /home/${user}/.cache/dein"

if [ -d "/root/.cache/dein" ];then
    sudo rm -rf /root/.cache/dein
fi
EXEC "sudo sh -c '$(curl -fsSL https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh)' -- /root/.cache/dein"

# SWAP and Hibernate settings
SWAP_UUID="$(sudo blkid|grep 'TYPE="swap"'|sed -e's/.*UUID="\(.*\)" TYPE="swap".*/\1/')"
echo "RESUME=UUID=$SWAP_UUID" > /etc/initramfs-tools/conf.d/resume
sed -i.org -e 's/^GRUB_CMDLINE_LINUX_DEFAULT=".*"/GRUB_CMDLINE_LINUX_DEFAULT="resume=UUID='"$SWAP_UUID"' quiet splash selinux=0 pci=noaer acpi=rsdt"/'
EXEC "sudo update-grub"
EXEC "sudo update-initramfs -u"

# fonts
EXEC "mkdir -p /home/${user}/.local/share/fonts"
if [ ! -f "/home/${user}/.local/share/fonts/RictyDiminished-Regular.ttf" ];then
    if [ -d "/home/${user}/.local/share/fonts/RictyDiminished-Regular.ttf" ];then
        EXEC "git clone https://github.com/edihbrandon/RictyDiminished.git"
        EXEC "cp -f ./RictyDiminished/*.ttf '/home/${user}/.local/share/fonts'"
    fi
fi
if [ ! -f "/home/${user}/.local/share/fonts/FiraCode-Regular.ttf" ];then
    if [ -d "/home/${user}/.local/share/fonts/FiraCode-Regular.ttf" ];then
        EXEC "git clone https://github.com/tonsky/FiraCode.git"
        EXEC "cp -f ./FiraCode/distr/ttf/*.ttf '/home/${user}/.local/share/fonts'"
    fi
fi

# 3-finger gesture
EXEC "sudo gpasswd -a $user input"
EXEC "git clone http://github.com/bulletmark/libinput-gestures"
EXEC "sudo ./libinput-gestures-setup install"
EXEC "libinput-gestures-setup autostart"

printf ".\e[32;1m%s\n\e[m" "[ALL DONE]"

