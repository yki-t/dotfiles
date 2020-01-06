#!/bin/bash

set -u

LOGIN_SHELL='/bin/zsh'

USE_WIFI=true
# if $USE_WIFI == true:
#   following commands before run this script (so that you can connect to wi-fi without GUI).
#   1. `sudo wpa_passphrase ESSID PASSWORD > wifi.conf`
#   e.g.) `wpa_passphrase mywifi password0123 > wifi.conf`
#   2. `sudo wpa_supplicant -i$WLAN -cwifi.conf` <- This command is not a daemon, grabs a thread.
#   e.g.) `wpa_supplicant -ieth0 -cwifi.conf`
#   3. `sudo dhclient $WLAN`
# else:
#   make sure you have wired connection.

ALL_YES=false
# y to all prompt

user=${USER}
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")">/dev/null 2>&1&&pwd)"
WLAN="$(ip link|grep 'BROADCAST'|grep 'MULTICAST'|grep -v 'NO-CARRIER'|awk '{print $2}'|sed -e's/://g')"

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

yn() {
    # {{{
    read -n1 -p " ok? (y/n): " yn
    if [[ $yn = [yY] ]]; then
      echo y
    else
      echo n
    fi
} # }}}

make_online_if_offline() {
    # {{{
    if [ "${USE_WIFI}" = 'true' ];then
        nc -z 8.8.8.8 53 &>/dev/null
        if [ $? -ne 0 ];then
            sudo dhclient $WLAN
        fi
    fi
} # }}}

# Main
if [ "$(uname -a|grep 'Debian')" = '' ];then
    echo "Must run on debian"
    exit
fi
if [ ${UID} -eq 0 ];then
    echo "Must run as non-root"
    exit
fi

make_online_if_offline
sudo apt-get update -y
sudo apt-get upgrade -y

cd "/tmp"
sudo chown -R $user:$user /opt /tmp
packages="$(ls "${DIR}/packages"|grep -v '^\.*$'|grep -v '^[0-9]*\..*'|grep '\.sh$'|grep -v '^template.sh$'|sed -e's/\.sh$//')"

for p in $packages;do
    desc="$(bash "${DIR}/packages/${p}.sh" "description" "$user")"
    printf "\n\e[36;1m%s\e[m:  ${desc}\n" "Installing ${p}"
    if [ "${ALL_YES}" != 'true' ] && [ "$(yn)" != 'y' ];then
        continue
    fi
    echo ''
    make_online_if_offline
    result=0
    bash "${DIR}/packages/${p}.sh" || result=$?
    if [ $result -eq 0 ];then
        printf "\e[36;1m%s\e[m: \e[32;1m%s\e[m\n" "${p}" "[OK]"
    else
        printf "\e[36;1m%s\e[m: \e[31;1m%s\e[m\n" "${p}" "[NG]"
    fi
done

make_online_if_offline
sudo apt-get update -y
sudo apt-get upgrade -y

printf "\e[32;1m%s\e[m\n" "[ALL DONE]"

