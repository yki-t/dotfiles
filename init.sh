#!/bin/bash

set -eu

#######################################
# Make Login Shell to be $LOGIN_SHELL
#######################################
readonly LOGIN_SHELL='/bin/zsh'

#######################################
# if $USE_WIFI == true:
#   following commands before run this script (so that you can connect to wi-fi without GUI).
#   1. `sudo wpa_passphrase ESSID PASSWORD > wifi.conf`
#      e.g.) `wpa_passphrase mywifi password0123 > wifi.conf`
#   2. `sudo wpa_supplicant -i$WLAN -cwifi.conf` <- This command is not a daemon, grabs a thread.
#      e.g.) `wpa_supplicant -ieth0 -cwifi.conf`
#   3. `sudo dhclient $WLAN`
#      e.g.) `sudo dhclient eth0`
# else:
#   make sure you have wired connection.
#######################################
readonly USE_WIFI=true

#######################################
# y to all prompt
#######################################
ALL_YES=false

#######################################
# Other Globals
#######################################
readonly LOGUSER=$(logname)
readonly EXEUSER=$USER

readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")">/dev/null 2>&1&&pwd)"
readonly WLAN="$(ip link|grep 'BROADCAST'|grep 'MULTICAST'|grep -v 'NO-CARRIER'|awk '{print $2}'|sed -e's/://g')"

#######################################
# Error output
#######################################
err() {
  echo -e "\e[31;1m[$(date +'%Y-%m-%dT%H:%M:%S%z')]\e[m $*" >&2
  exit 1
}

#######################################
# Y/N prompt
#######################################
yn() {
  read -p " ok? (y/n): " yn
  if [[ $yn = [yY] ]]; then
    echo y
  else
    echo n
  fi
}

#######################################
# force online if offline
#######################################
make_online_if_offline() {
  if [ "${USE_WIFI}" = 'true' ];then
    nc -z 8.8.8.8 53 &>/dev/null
    if [ $? -ne 0 ];then
      sudo dhclient $WLAN
    fi
  fi
}

#######################################
# os_type
# @return {'debian','arch','others'}
#######################################
get_os_type() {
  if type apt-get&>/dev/null; then
    export DEBIAN_FRONTEND=noninteractive
    echo 'debian'
    return;
  elif type pacman&>/dev/null; then
    echo 'arch'
    return;
  fi
  echo 'unknown'
}

#######################################
# Main function
#######################################
os_type="$(get_os_type)"
package_update() {
  case "${os_type}" in
    debian)
      sudo apt-get update -y
      sudo apt-get upgrade -y
      ;;
    arch)
      sudo pacman -Syyu
      ;;
    *)
      err "Package update failed: Unknown os_type '${os_type}'"
      ;;
  esac
}
package_install() {
  local args=$*
  case "${os_type}" in
    debian)
      sudo apt-get install -y $args
      ;;
    arch)
      sudo pacman -S --noconfirm $args
      ;;
    *)
      err "Package(s) install ($args) failed: Unknown os_type '${os_type}'"
      ;;
  esac
}

#######################################
# Main process
#######################################
main() {
  if [ $# -ge 1 ]; then
    if [[ $1 == *-f* ]]; then
      ALL_YES=true
    fi
  fi

  if [ "$EXEUSER" = 'root' ]; then
    err "This script cannot run as root"
  fi
  cat << EOM
#######################################
# Start Setting for user: '$LOGUSER'
#######################################
EOM
  package_update

  if [ "$os_type" = 'arch' ]; then
    sudo pacman-mirrors --geoip \
      && sudo pacman -Syyu --noconfirm \
      && sudo pacman -S --noconfirm gnu-netcat yay
  fi
  make_online_if_offline

  cd "/tmp"
  sudo chown -R $LOGUSER:$LOGUSER /tmp
  packages="$(ls "${DIR}/${os_type}"|grep -v '^\.*$'|grep -v '^[0-9]*\..*'|grep '\.sh$'|grep -v '^template.sh$'|sed -e's/\.sh$//')"

  for p in $packages;do
    desc="$(bash "${DIR}/${os_type}/${p}.sh" "description")"
    printf "\n\e[36;1m%s\e[m:  ${desc}\n" "Installing ${p}"
    if [ "${ALL_YES}" != 'true' ] && [ "$(yn)" != 'y' ];then
      continue
    fi
    echo ''
    make_online_if_offline
    result=0
    bash "${DIR}/${os_type}/${p}.sh" || result=$?
    if [ $result -eq 0 ];then
      printf "\e[36;1m%s\e[m: \e[32;1m%s\e[m\n" "${p}" "[OK]"
    else
      printf "\e[36;1m%s\e[m: \e[31;1m%s\e[m\n" "${p}" "[NG]"
    fi
  done

  make_online_if_offline
  package_update

  printf "\e[32;1m%s\e[m\n" "[ALL DONE]"
}

[[ "${BASH_SOURCE[0]}" == "$0" ]] && main "$@"

