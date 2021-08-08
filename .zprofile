TZ='Asia/Tokyo'; export TZ

paths=''
# Exports
# tor
[ -f ${HOME}/.tor ] && paths+=":${HOME}/opt/tor"

# Rust
[ -d ${HOME}/.cargo ] && paths+=":${HOME}/.cargo/bin"

# Node JS npm/yarn
if type npm &>/dev/null; then
  # npm config set prefix ${HOME}/.local/ # too slow & rarely use npm
  export NO_UPDATE_NOTIFIER=1 # node.js
  [ -f "${HOME}/.local/bin/npm" ] && alias npm="${HOME}/.local/bin/npm"
fi

if type yarn &>/dev/null; then
  export NODE_PATH="${HOME}/.yarn/bin"
  # paths+=":$(yarn global bin)" # too slow
  # paths+=":$(yarn global dir)/node_modules/.bin" # too slow
  paths+=":${HOME}/.local/bin"
  if [ $UID -eq 0 ]; then
    paths+=":/usr/local/share/.config/yarn/global/node_modules/.bin"
  else
    paths+=":${HOME}/.config/yarn/global/node_modules/.bin"
  fi
fi

# JAVA
if type java &>/dev/null && type update-alternatives &>/dev/null; then
  export JAVA_HOME=$(update-alternatives --query javac 2>/dev/null | sed -n -e 's/Value: *\(.*\)\/bin\/javac/\1/p')
  export DERBY_HOME=$JAVA_HOME/db
  export J2SDKDIR=$JAVA_HOME
  export J2REDIR=$JAVA_HOME/jre
  paths+=":$JAVA_HOME/bin"
  paths+=":$DERBY_HOME/bin"
  paths+=":$J2REDIR/bin"
fi

# Android
if [ -d ${HOME}/Android ]; then
  export ANDROID_HOME=${HOME}/Android/Sdk
  export ANDROID_SDK_HOME=${HOME}/Android/Sdk
  export NDK_HOME=${HOME}/Android/android-ndk-r20
  # paths+=":${ANDROID_HOME}/bin"
  paths+=":${ANDROID_HOME}/emulator"
  paths+=":${ANDROID_HOME}/tools"
  paths+=":${ANDROID_HOME}/tools/bin"
fi

# Flutter devtool
[ -d "${HOME}/.pub-cache/bin" ] && paths+=":${HOME}/.pub-cache/bin"

# c
if type gcc &>/dev/null; then
  gcc_exec="$(which gcc)"
  export CC="${gcc_exec}"
  export CMAKE_C_COMPILER="${gcc_exec}"
fi

# c++
if type g++ &>/dev/null; then
  gxx_exec="$(which g++)"
  export CXX="${gxx_exec}"
  export CMAKE_CXX_COMPILER="${gxx_exec}"
fi

# Ruby
if [ -d ${HOME}/.rbenv/bin ];then
  paths+=":${HOME}/.rbenv/bin"
  eval "$(rbenv init -)"
fi

# ls
ls_colors=''
ls_colors+='rs=0:di=0;95:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;'
ls_colors+='31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;'
ls_colors+='31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;'
ls_colors+='35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;'
ls_colors+='35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;'
ls_colors+='36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:'
export LS_COLORS=$ls_colors

if type exa &>/dev/null;then
  local exaGen='da=1;30:di=1;35:uu=33:'
  local exaMov='*.mkv=1;32:*.mp4=1;32:*.mpeg4=1;32:'
  # local exaImg='*.png=1;32:*.jpg=1;32:*.jpeg=1;32:*.webp=1;32:*.apng=1;32:'
  local exaImg='*.mp3=1;36:*.wav=1;36:*.flac=1;32:'
  export EXA_COLORS="${exaGen}${exaMov}${exaImg}"
fi

# Mozc & fcitx - IME
export XIM_PROGRAM=fcitx
export XIM=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
type fcitx-autostart &>/dev/null && (fcitx-autostart&>/dev/null &)
export GIT_EDITOR=vim
export EDITOR=vim

# Docker parallel build
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1

# Shell Colors
export C_PINK='\033[35m' # Pink
export C_CYAN='\033[36m' # Cyan
export C_RESET='\033[0m' # Reset

# local のmysql docker に簡易接続するやつ
export MYSQL_PWD=password
export MYSQL='mysql -uusername -hlocalhost --protocol tcp database -A '

# Linux shortcut
paths+=":${HOME}/.local/bin"
[[ "$PATH" != *$paths* ]] && export PATH="$PATH$paths"

if [ "$DISPLAY" != '' ]; then
  [[ -f ~/.Xmodmap ]] && type xmodmap&>/dev/null && xmodmap ~/.Xmodmap
  [[ -f ${HOME}/.Xmodmap ]] && type xmodmap&>/dev/null && xmodmap ${HOME}/.Xmodmap

  type realpath&>/dev/null && [[ -f $(realpath ~/.Xmodmap) ]] && type xmodmap&>/dev/null && xmodmap ~/.Xmodmap

  if type realpath &>/dev/null; then
    DIR="$(cd "$(dirname "$(realpath $0)")"&>/dev/null &&pwd)" # SCRIPT_DIR on zsh
    [ -f "$DIR/.private.sh" ] && source "$DIR/.private.sh"
  fi

fi

