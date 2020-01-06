#!/bin/bash

set -u

LOGIN_SHELL='/bin/zsh'

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

# Main
if [ "$(uname -a|grep 'Debian')" = '' ];then
    echo "Must run on debian"
    exit
fi
if [ ${UID} -eq 0 ];then
    echo "Must run as non-root"
    exit
fi
sudo apt-get update -y
sudo apt-get upgrade -y

cd "/tmp"
sudo chown -R $user:$user /opt /tmp
packages="$(ls "${DIR}/packages"|grep -v '^\.*$'|grep '\.sh$'|grep -v '^template.sh$'|sed -e's/\.sh$//')"
for p in $packages;do
    desc="$(bash "${DIR}/packages/${p}.sh" "description" "$user")"
    printf "\n\e[36;1m%s\e[m:  ${desc}\n" "Installing ${p}"
    result=0
    bash "${DIR}/packages/${p}.sh" || result=$?
    if [ $result -eq 0 ];then
        printf "\e[36;1m%s\e[m: \e[32;1m%s\e[m\n" "${p}" "[OK]"
    else
        echo -e "GET http://google.com HTTP/1.0\n\n"|nc google.com 80 &>/dev/null
        if [ $? -ne 0 ]; then
            sudo dhclient $WLAN
            bash "${DIR}/packages/${p}.sh" || result=$?
            if [ $result -eq 0 ];then
                printf "\e[36;1m%s\e[m: \e[32;1m%s\e[m\n" "${p}" "[OK]"
                continue
            fi
        fi
        printf "\e[36;1m%s\e[m: \e[31;1m%s\e[m\n" "${p}" "[NG]"
    fi
done

sudo apt-get update -y
sudo apt-get upgrade -y

printf "\e[32;1m%s\e[m\n" "[ALL DONE]"

