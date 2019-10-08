#!/bin/bash

LOST_COMMAND_AND_INSTALL=true

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")">/dev/null 2>&1&&pwd)"
TARGET_SHELL='/bin/zsh'
user=${USER}
MSG_BACK_LENGTH=100

cd "/tmp"

success() {
    # {{{
    printf "${1}: \e[32;1m%s\n\e[m" "[OK]"
} # }}}
failure() {
    # {{{
    printf "\e[31;1m%s\n\e[m(reason: ${1})" "[ABORT]"
    exit
} # }}}
EXEC() {
    # {{{
    [ "$($1)" = 'true' ] && success "$1" || failure "$1"
} # }}}

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
    [ -n "$(uname -a|grep 'debian')" ] && echo true || echo false
} # }}}
is_non_root() {
    # {{{
    [ "${USER}" != root ] && echo true || echo false
} # }}}
check_base_cmds() {
    # {{{
    sudo apt-get install -y curl git vim zsh wget jq>/dev/null && echo true || echo false
} # }}}
change_login_shell_bash2zsh() {
    # {{{
    if [ ! -f '/bin/zsh' ];then
        echo false
        return
    fi

    user="${USER}"
    if [ "$(grep ${USER} /etc/passwd|sed -e 's/.*:\(.*\)$/\1/')" != "$TARGET_SHELL" ];then
        sudo chsh -s "$TARGET_SHELL" "$user" >/dev/null
        [ $? -ne 0 ] && echo false && return
    fi

    if [ "$(grep root /etc/passwd|sed -e 's/.*:\(.*\)$/\1/')" != "$TARGET_SHELL" ];then
        sudo chsh -s "$TARGET_SHELL" root >/dev/null
        [ $? -ne 0 ] && echo false && return
    fi
    echo true
} # }}}

# Packages
# {{{
packages="$(cat <<'EOM'
{
    "kde": {
        "description": "KDE Plasma and desktop system",
        "_apt": [
            "aptitude"
            , "tasksel"
        ],
        "apt": [
            "~t^desktop$"
            , "~t^kde-desktop$"
        ]
    },
    "mozc": {
        "description": "fcitx and mozc, Japanese I/O environment",
        "apt": [
            "fcitx"
            , "fcitx-mozc"
            , "fcitx-frontend-gtk2"
            , "fcitx-frontend-gtk3"
            , "fcitx-frontend-qt4"
            , "fcitx-frontend-qt5"
            , "fcitx-ui-classic"
            , "kde-config-fcitx"
            , "mozc-utils-gui"
        ],
        "man": "`source ~/.zprofile && im-config -n fcitx && fcitx-configtool` and set input method"
    },
    "thunderbird": {
        "description": "Email client",
        "apt": [
            "thunderbird"
        ]
    },
    "nvidia": {
        "description": "Nvidia drivers for GPU",
        "main": [
            "dpkg --add-architecture i386"
        ],
        "apt_": [
            "firmware-linux"
            , "nvidia-driver"
            , "nvidia-settings"
            , "nvidia-xconfig"
        ],
        "after": [
            "nvidia-xconfig"
        ]
    },
    "firefox": {
        "description": "Mozilla Firefox(Latest) web browser",
        "main": [
            "if [ ! -f FirefoxSetup.tar.bz2 ];then wget -O FirefoxSetup.tar.bz2 'https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US'; fi"
            , "if [ ! -f /opt/firefox ];then mkdir -p /opt/firefox; fi"
            , "tar xjf FirefoxSetup.tar.bz2 -C /opt/firefox/"
            , "if [ -f /usr/lib/firefox-esr/firefox-esr ];then mv /usr/lib/firefox-esr/firefox-esr /usr/lib/firefox-esr/firefox-esr.org; fi"
            , "ln -snf /opt/firefox/firefox/firefox /usr/lib/firefox-esr/firefox-esr"
        ]
    },
    "chrome": {
        "description": "Google Chrome(Latest) web browser",
        "main": [
            "if [ ! -f google-chrome-stable_current_amd64.deb ];then wget 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'; fi"
        ],
        "apt_": [
            "./google-chrome-stable_current_amd64.deb"
        ]
    },
    "slack": {
        "description": "Chat client",
        "apt": [
            "ca-certificates"
        ],
        "main": [
            "if [ ! -f slack-desktop-4.0.2-amd64.deb ];then wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.0.2-amd64.deb; fi"
        ],
        "apt_": [
            "./slack-desktop-4.0.2-amd64.deb"
        ]
    },
    "Rust": {
        "description": "Rustlang",
        "command": [
            "curl https://sh.rustup.rs -sSf|sh -s -- -y"
        ]
    },
    "nodejs": {
        "description": "node.js and yarn",
        "_apt": [
            "npm"
        ],
        "main": [
            "curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg|apt-key add -"
            , "echo 'deb https://dl.yarnpkg.com/debian/ stable main'|sudo tee /etc/apt/sources.list.d/yarn.list"
        ],
        "apt_": [
            "nodejs"
            , "yarn"
        ],
        "after": [
            "yarn global add n"
            , "n stable"
        ]
    },
    "gcloud": {
        "description": "for google cloud platform",
        "_apt": [
            "apt-transport-https"
            , "ca-certificates"
        ],
        "main": [
            "curl -sS https://packages.cloud.google.com/apt/doc/apt-key.gpg|apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -"
            , "echo 'deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main'|tee /etc/apt/sources.list.d/google-cloud-sdk.list"
        ],
        "apt_": [
            "google-cloud-sdk"
        ]
    }
}
EOM
)"
# }}}

# Main
printf "is_debian: " && tput cub $MSG_BACK_LENGTH
EXEC is_debian
printf "is_non_root: " && tput cub $MSG_BACK_LENGTH
EXEC is_non_root
printf "check_base_cmds: " && tput cub $MSG_BACK_LENGTH
EXEC check_base_cmds
printf "change_login_shell_bash2zsh: " && tput cub $MSG_BACK_LENGTH
EXEC change_login_shell_bash2zsh

_apts=() apts=() mains=() apt_s=() afters=() mans=()
while :;do
    # {{{
    trg_packages=''
    for k in "kde" "mozc" "thunderbird" "nvidia" "firefox" "chrome" "slack" "Rust" "nodejs" "gcloud";do
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

printf "installing.. this may take a while\n"
sudo apt-get update -y >/dev/null || failure "apt-get update"
sudo apt-get upgrade -qq -y >/dev/null || failure '@apt-get upgrade'
sudo apt-get install -y ${_apts[@]} >/dev/null || failure "apt-get install ${_apts[@]}"
sudo aptitude install -y ${apts[@]} >/dev/null || failure "aptitude install ${apts[@]}"
for cmd in "${mains[@]}";do
    sudo bash -c "$cmd" || failure "main command: $cmd"
done
 sudo apt-get install -y ${apt_s[@]} >/dev/null || failure "apt-get install ${apt_s[@]}"
for cmd in "${afters[@]}";do
    sudo bash -c "$cmd" || failure "after command: $cmd"
done
sudo apt-get update -y >/dev/null || failure "apt-get update"
sudo apt-get upgrade -qq -y >/dev/null || failure '@apt-get upgrade'

msg="Initing system.."
printf "${msg}"
for dotfile in .zshrc .zprofile .xmodmap .xinitrc .vimrc .sshrc;do
    ln -snf "${DIR}/${dotfile}" "/home/${user}/${dotfile}" || failure "ln for ${dotfile}"
    sudo ln -snf "${DIR}/${dotfile}" "/root/${dotfile}" || failure "ln for ${dotfile}"
done
printf ".\e[32;1m%s\n\e[m" "OK"

if [ ! -d "/home/${user}/.cache/dein" ];then
    mkdir -p /home/${user}/.cache/dein
    [ ! -f dein_installer.sh ] && curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > dein_installer.sh
    sh ./dein_installer.sh "/home/${user}/.cache/dein"
fi

if [ ! -d "/root/.cache/dein" ];then
    sudo mkdir -p /root/.cache/dein
    [ ! -f dein_installer.sh ] && curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > dein_installer.sh
    sudo sh ./dein_installer.sh "/home/${user}/.cache/dein"
fi

[ ! -d "/home/${user}/.local/share/fonts" ] && mkdir -p ~/.local/share/fonts
[ ! -d "RictyDiminishedDiscord-Regular" ] && git clone https://github.com/edihbrandon/RictyDiminished.git
cp -f ./RictyDiminished/*.ttf "/home/${user}/.local/share/fonts"
[ ! -d "FiraCode" ] && git clone https://github.com/tonsky/FiraCode.git
cp -f ./fonts/f/distr/ttf/*.ttf "/home/${user}/.local/share/fonts"

echo "Please reboot after following instructions if shown vvv"
for man in "${mans[@]}";do
    printf ".\e[32;1m%s\n\e[m" "$man"
done
printf ".\e[32;1m%s\n\e[m" "system: setup grub config such as 'quiet splash nomodeset pci=nommconf'"

printf ".\e[32;1m%s\n\e[m" "[ALL DONE]"

