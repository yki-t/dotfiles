#!/bin/bash
# vim: softtabstop=2 tabstop=2 shiftwidth=2 expandtab foldmethod=marker

set -eu

#######################################
# User Settings - needs hardcoded
#######################################
USE_WIFI=true
USERNAME='yuki'
SWAP_SIZE='96G'
HOST_NAME='arch-laptop'
ZONE='Asia/Tokyo'
LOCALES=('en_US.UTF-8 UTF-8' 'ja_JP.UTF-8 UTF-8')
VOLUME_GROUP='vg-default'

WIFI_DEV=''
WIFI_SSID=''
WIFI_PASS=''
CPU_BRAND='amd' # amd or intel. for microcode
GPU_DRIVERS='nvidia nvidia-settings nvidia-utils'

DEVICE=''
_BOOT=''
_LVM=''

# Other Settings
# {{{
MIRRORS="$(cat <<'EOM'
Server = rsync://ftp.jaist.ac.jp/pub/Linux/ArchLinux/$repo/os/$arch
Server = rsync://mirror-hk.koddos.net/archlinux/$repo/os/$arch
Server = rsync://mirror.xtom.com.hk/repo/archlinux/$repo/os/$arch
Server = rsync://archlinux.cs.nctu.edu.tw/archlinux/$repo/os/$arch
Server = rsync://ftp.tsukuba.wide.ad.jp/archlinux/$repo/os/$arch
Server = rsync://hkg.mirror.rackspace.com/archlinux/$repo/os/$arch
EOM
)"
YAYCONFIG="$(cat <<'EOM'
{
	"aururl": "https://aur.archlinux.org",
	"buildDir": "$HOME/.cache/yay",
	"absdir": "$HOME/.cache/yay/abs",
	"editor": "",
	"editorflags": "",
	"makepkgbin": "makepkg",
	"makepkgconf": "",
	"pacmanconf": "/etc/pacman.conf",
	"redownload": "no",
	"rebuild": "no",
	"answerclean": "",
	"answerdiff": "",
	"answeredit": "",
	"answerupgrade": "",
	"gitbin": "git",
	"gpgbin": "gpg",
	"gpgflags": "",
	"mflags": "",
	"sortby": "votes",
	"searchby": "name-desc",
	"gitflags": "",
	"removemake": "ask",
	"sudobin": "sudo",
	"sudoflags": "",
	"requestsplitn": 150,
	"sortmode": 0,
	"completionrefreshtime": 7,
	"sudoloop": true,
	"timeupdate": false,
	"devel": false,
	"cleanAfter": false,
	"provides": true,
	"pgpfetch": true,
	"upgrademenu": true,
	"cleanmenu": true,
	"diffmenu": true,
	"editmenu": false,
	"combinedupgrade": false,
	"useask": false,
	"batchinstall": false
}
EOM
)"
# }}}

#######################################
# Output
#######################################
err() {
  # {{{
  echo -e "\e[31;1m[$(date +'%Y-%m-%dT%H:%M:%S')]\e[m $*" >&2
  exit 1
} # }}}
warn() {
  # {{{
  echo -e "\e[31;1m[$(date +'%Y-%m-%dT%H:%M:%S')]\e[m $*" >&2
} # }}}
ok() {
  # {{{
  echo -e "\e[32;1m[$(date +'%Y-%m-%dT%H:%M:%S')]\e[m $*" >&2
} # }}}
info() {
  # {{{
  echo -e "\e[37;1m[$(date +'%Y-%m-%dT%H:%M:%S')]\e[m $*" >&2
} # }}}
breakIfNotSetAny() {
  # {{{
  local vals=(USE_WIFI USERNAME SWAP_SIZE HOST_NAME ZONE LOCALES VOLUME_GROUP WIFI_DEV WIFI_SSID WIFI_PASS CPU_BRAND GPU_DRIVERS DEVICE _BOOT _LVM)
  isOk=true
  for v in ${vals[@]}; do
    [ -z "${!v}" ] && warn "$v must be set" && isOk=false
  done
  [ "$isOk" = "false" ] && err "Set these variable and retry."
} # }}}

#######################################
# Functions
#######################################
ntp() {
  # {{{
  timedatectl set-ntp true
} # }}}
clean() {
  # {{{
  if [ "$(mount | grep /mnt/boot)" ]; then
    umount /mnt/boot
  fi
  if [ "$(mount | grep /mnt)" ]; then
    umount /mnt
  fi
  if [ "$(lsblk | grep '\[SWAP\]')" ]; then
    swapoff /dev/mapper/$VOLUME_GROUP-swap
  fi
} # }}}
conn() {
  # {{{
  if [ "$(pgrep wpa_supplicant)" ]; then return; fi
  if [ -z $WIFI_DEV ]; then
    WIFI_DEV=$(ip link|grep '^[0-9]'|grep -v 'lo:'|grep w|awk '{print $2}'|sed -e's~\(.*\):~\1~')
  fi
  wpa_supplicant -B -i $WIFI_DEV -c <(wpa_passphrase $WIFI_SSID $WIFI_PASS) &>/dev/null
} # }}}
partition() {
  # {{{
  # Delete all and create efi, lvm
  echo -e 'o\nY\nn\n\n\n512M\nEF00\nn\n\n\n\n\nw\nY\n'|gdisk $DEVICE
} # }}}
encrypt() {
  # {{{
  mkfs.vfat -F32 $DEVICE$_BOOT
  cryptsetup -v luksFormat $DEVICE$_LVM
  cryptsetup luksOpen $DEVICE$_LVM luks
  pvcreate /dev/mapper/luks
  vgcreate $VOLUME_GROUP /dev/mapper/luks
  lvcreate -L $SWAP_SIZE $VOLUME_GROUP -n swap
  lvcreate -l +100%FREE $VOLUME_GROUP -n root
  mkfs.ext4 /dev/mapper/$VOLUME_GROUP-root
  mkswap /dev/mapper/$VOLUME_GROUP-swap
} # }}}
mountDevice() {
  # {{{
  mount /dev/mapper/$VOLUME_GROUP-root /mnt
  swapon /dev/mapper/$VOLUME_GROUP-swap
  mkdir /mnt/boot
  mount $DEVICE$_BOOT /mnt/boot
} # }}}
applyMirrors() {
  # {{{
  cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
  echo "$MIRRORS" > /etc/pacman.d/mirrorlist
} # }}}
installBase() {
  # {{{
  pacstrap /mnt base base-devel linux linux-firmware
  cp /mnt/etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist.bak
  echo "$MIRRORS" > /mnt/etc/pacman.d/mirrorlist
  genfstab -pU /mnt >> /mnt/etc/fstab
} # }}}
changeRootAndConfigure() {
  # {{{
  arch-chroot /mnt pacman -Syyu
  arch-chroot /mnt ln -sf /usr/share/zoneinfo/$ZONE /etc/localtime
  arch-chroot /mnt hwclock --systohc
  arch-chroot /mnt echo $HOST_NAME > /etc/hostname
  arch-chroot /mnt echo LANG=en_US.UTF-8 > /etc/locale.conf
  for i in $(seq 0 $((${#LOCALES[@]}-1))); do
    arch-chroot /mnt sed -i.org -e "s~^#${LOCALES[$i]}~${LOCALES[$i]}~" /etc/locale.gen
  done
  arch-chroot /mnt locale-gen
} # }}}
installPackages() {
  # {{{
  arch-chroot /mnt pacman -S dialog wpa_supplicant git $CPU_BRAND-ucode zsh vim
  arch-chroot /mnt bash -c 'if [ ! "$(cat /etc/passwd | grep '$USERNAME')" ]; then useradd -m -G wheel -s /bin/zsh '$USERNAME' && passwd '$USERNAME'; fi'
  arch-chroot /mnt sed -i -e 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
  arch-chroot /mnt sudo -u $USERNAME /bin/bash -c "if !(type yay &>/dev/null); then cd /tmp && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si; fi"
  arch-chroot /mnt yay -Syyu
  # ref) https://wiki.archlinux.org/index.php/Xorg#Installation
  # kwallet-pam is suspicious locking screen and cause kernel panic when login
  arch-chroot /mnt pacman -S $GPU_DRIVERS xorg-server sddm plasma-desktop \
    plasma-nm networkmanager konsole powerdevil plasma-workspace-wallpapers \
    plasma-pa kwallet-pam kdeplasma-addons kde-gtk-config
  arch-chroot /mnt systemctl enable sddm NetworkManager
} # }}}
installAdditionalPackages() {
  # {{{
  arch-chroot /mnt chown -R $USERNAME:$USERNAME /home/$USERNAME
  # keys for loop-aes
  for k in B0C64D14301CC6EFAEDF60E4E4B71D5EEC39C284 12D64C3ADCDA0AA427BDACDFF0733C808132F189; do
    arch-chroot /mnt sudo -u $USERNAME gpg --keyserver hkp://ipv4.pool.sks-keyservers.net:11371 --recv-keys $k
  done
  # Install packages
  arch-chroot /mnt sudo -u $USERNAME yay -S \
    linux-headers `# system` \
    curl wget xsel rsync ripgrep pixz pv alacritty-ligature `# basic cli` \
    dstat sysstat hdparm dmidecode `# system check` \
    inetutils dnsutils exiftool imagemagick nkf unarchiver `# additional cli` \
    reflector powerpill pacman-contrib`# pacman extension` \
    fcitx fcitx-im fcitx-configtool fcitx-mozc otf-ipafont noto-fonts-sc noto-fonts-tc adobe-source-han-sans-kr-fonts `# IME ja,cn,kr` \
    systemd-numlockontty xorg-xmodmap `# system settings` \
    bat exa xdotool wmctrl `# Rust cli alternatives` \
    kwin-lowlatency bluedevil pulseaudio-bluetooth libnotify `# KDE` \
    virtualbox yakuake `# GUI` \
    skypeforlinux-stable-bin slack-desktop thunderbird zoom telegram-desktop `# chat` \
    python-pip nodejs-lts-erbium yarn grpcurl `# languages` \
    google-chrome firefox `# browser ` \
    docker docker-compose github-cli google-cloud-sdk `# dev` \
    nginx apache mariadb `# web` \
    jmtpfs qemu libvirt android-studio `# android` \
    vlc gwenview okular poppler-data libreoffice-still blender `# GUI tools` \
    man


  # yay config
  arch-chroot /mnt sudo -u $USERNAME bash -c "mkdir -p /home/$USERNAME/.config; echo '$YAY_CONFIG' > /home/$USERNAME/.config/yay"

  # numlockontty
  arch-chroot /mnt systemctl enable numLockOnTty.service

  # Other packages
  arch-chroot /mnt sudo -u $USERNAME bash -c "if !(type lab &>/dev/null); then yay -S lab; fi"

  # Flutter
  arch-chroot /mnt sudo -u $USERNAME bash -c "if !(type flutter &>/dev/null); then yay -S flutter; fi"
  arch-chroot /mnt sudo -u $USERNAME bash -c "flutter pub global activate devtools"

  # Enable services
  arch-chroot /mnt systemctl enable bluetooth.service
  arch-chroot /mnt systemctl enable docker.service

  # Link dotfiles
  arch-chroot /mnt sudo -u $USERNAME bash -c "cd /home/$USERNAME && git clone https://github.com/yuki37/dotfiles.git"
  for dotfile in '.zshrc' '.zshrc.zwc' '.zprofile' '.Xmodmap' '.xinitrc' '.vimrc' '.sshrc' '.vim' '.gitconfig' '.alacritty'; do
    if [ ! -e "/home/$USERNAME/$dotfile" ];then
      arch-chroot /mnt sudo -u $USERNAME ln -snf "/home/$USERNAME/dotfiles/$dotfile" "/home/$USERNAME/$dotfile"
    fi
    if [ ! -e "/root/${dotfile}" ];then
      arch-chroot /mnt ln -snf "/home/$USERNAME/dotfiles/$dotfile" "/root/$dotfile"
    fi
  done

  # Rust
  arch-chroot /mnt bash -c "sudo -u $USERNAME bash -c 'curl https://sh.rustup.rs -sSf|sh -s -- -y' && bash /home/$USERNAME/.cargo/env"
  arch-chroot /mnt bash -c "curl https://sh.rustup.rs -sSf|sh -s -- -y && bash /root/.cargo/env"

  # Android studio
  if [ -f "/mnt/etc/modules" ] && [ ! "$(cat /mnt/etc/modules|grep vhost_net)" ]; then
    echo vhost_net|tee -a /mnt/etc/modules
  fi
  arch-chroot /mnt systemctl enable libvirtd.service

  # Gestures
  arch-chroot /mnt bash -c "cd /tmp && git clone http://github.com/bulletmark/libinput-gestures && cd libinput-gestures && ./libinput-gestures-setup install"
  mkdir -p "/mnt/home/$USERNAME/.config"
  cat <<EOM > "/mnt/home/$USERNAME/.config/libinput-gestures.conf"
gesture swipe right	_internal ws_up
gesture swipe left	_internal ws_down
EOM
  arch-chroot /mnt bash -c "ln -snf /home/$USERNAME/.config/libinput-gestures.conf /etc/libinput-gestures.conf"
  arch-chroot /mnt bash -c "usermod -aG input $USERNAME"
  arch-chroot /mnt bash -c "sudo -u $USERNAME libinput-gestures-setup autostart"

  # Flutter
  arch-chroot /mnt gpasswd -a $USERNAME flutterusers

  # Docker
  arch-chroot /mnt bash -c "usermod -aG docker $USERNAME"

  # Mozc fcitx - IME
  local PROFILE="/mnt/home/$USERNAME/dotfiles/.zshrc"
  if [ "$(cat "$PROFILE"|grep '^export XIM_PROGRAM=')" = '' ];then
    echo 'export XIM_PROGRAM=fcitx' >> "$PROFILE"
  fi
  if [ "$(cat "$PROFILE"|grep '^export XIM=')" = '' ];then
    echo 'export XIM=fcitx' >> $PROFILE
  fi
  if [ "$(cat "$PROFILE"|grep '^export GTK_IM_MODULE=')" = '' ];then
    echo 'export GTK_IM_MODULE=fcitx' >> "$PROFILE"
  fi
  if [ "$(cat "$PROFILE"|grep '^export QT_IM_MODULE=')" = '' ];then
    echo 'export QT_IM_MODULE=fcitx' >> "$PROFILE"
  fi
  if [ "$(cat "$PROFILE"|grep '^export XMODIFIERS=')" = '' ];then
    echo 'export XMODIFIERS="@im=fcitx"' >> "$PROFILE"
  fi

  if [ "$(cat "$PROFILE"|grep '')"  = 'type fcitx-autostart &>/dev/null && (fcitx-autostart&>/dev/null &)' ];then
    echo 'type fcitx-autostart &>/dev/null && (fcitx-autostart&>/dev/null &)' >> "$PROFILE"
  fi

  # Virtualbox
  arch-chroot /mnt usermod -aG vboxusers $USERNAME
  # wget https://download.virtualbox.org/virtualbox/6.1.6/Oracle_VM_VirtualBox_Extension_Pack-6.1.6.vbox-extpack
  # virtualbox Oracle_VM_VirtualBox_Extension_Pack-6.1.6.vbox-extpack
  # rm Oracle_VM_VirtualBox_Extension_Pack

  # vim-dein
  arch-chroot /mnt sudo -u $USERNAME pip install --user pynvim
  arch-chroot /mnt pip install pynvim
  local DEIN_INSTALLER='https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh'

  if [ -d "/mnt/home/$USERNAME/.cache/dein" ];then
    rm -rf "/mnt/home/$USERNAME/.cache/dein"
  fi
  arch-chroot /mnt sh -c "$(curl -fsSL "$DEIN_INSTALLER")" -- "/home/$USERNAME/.cache/dein"
  if [ -d "/mnt/root/.cache/dein" ];then
    rm -rf /mnt/root/.cache/dein
  fi
  arch-chroot /mnt sh -c "$(curl -fsSL "$DEIN_INSTALLER")" -- /root/.cache/dein

  # Yakuake
  if [ ! -f /mnt/home/$USERNAME/.config/systemd/user/yakuake.service ]; then
    mkdir -p "/mnt/home/$USERNAME/.config/systemd/user"
    cat <<EOM > "/mnt/home/$USERNAME/.config/systemd/user/yakuake.service"
[Unit]
Description=yakuake daemon

[Service]
ExecStart=/usr/bin/yakuake
Restart=always

[Install]
WantedBy=default.target
EOM
    arch-chroot /mnt chown -R $USERNAME:$USERNAME /home/$USERNAME
    # arch-chroot /mnt systemctl --user enable yakuake
  fi

} # }}}
finalize() {
  # {{{
  arch-chroot /mnt bootctl --path=/boot install
  local entry="$(cat <<EOM > /mnt/boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd /$CPU_BRAND-ucode.img
initrd /initramfs-linux.img
options cryptdevice=UUID=$(blkid $DEVICE$_LVM|sed -e's/.* UUID="\(.*\)" TYPE.*/\1/'):lvm:allow-discards resume=/dev/mapper/$VOLUME_GROUP-swap root=/dev/mapper/$VOLUME_GROUP-root rw quiet
EOM
)"
  local entry="$(cat <<EOM > /mnt/boot/loader/loader.conf
timeout 0
default arch
editor 0
EOM
)"
  sed -i -e's/MODULES=(.*)/MODULES=(ext4)/' /mnt/etc/mkinitcpio.conf
  sed -i -e's/HOOKS=(.*)/HOOKS=(base udev autodetect modconf block keymap encrypt lvm2 resume filesystems keyboard fsck)/' /mnt/etc/mkinitcpio.conf
  arch-chroot /mnt mkinitcpio -p linux
  umount /mnt/boot
  umount /mnt
} # }}}

#######################################
# Main process
#######################################
main() {
  # {{{
  breakIfNotSetAny
  info 'Setting ntp' && ntp && ok "DONE" || err "FAILED"
  info 'Connecting to the internet' && conn && ok "DONE" || err "FAILED"
  info 'Cleaning mount points' && clean && ok "DONE" || err "FAILED"
  info 'Partitioning devices' && partition && ok "DONE" || err "FAILED"
  info 'Encrypting device' && encrypt && ok "DONE" || err "FAILED"
  info 'Mounting device' && mountDevice && ok "DONE" || err "FAILED"
  info 'Applying mirrors' && applyMirrors && ok "DONE" || err "FAILED"
  info 'Installing base systems' && installBase && ok "DONE" || err "FAILED"
  info 'Chaging into root' && changeRootAndConfigure && ok "DONE" || err "FAILED"
  info 'Installing packages' && installPackages && ok "DONE" || err "FAILED"
  info 'Installing additional packages' && installAdditionalPackages && ok "DONE" || err "FAILED"
  info 'Finalizing' && finalize && ok "DONE" || err "FAILED"
}
# }}}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  if [ $# -eq 0 ]; then
    main "$@"
  else
    $1
  fi
fi

