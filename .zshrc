# Prompt
autoload -Uz colors; colors
if [ ${UID} -eq 0 ]; then # if Root
  PROMPT="%{${fg[red]}%}[%n:${HOST}]
%{${fg[yellow]}%}%/%{${reset_color}%}
# "
else
  PROMPT="%{${fg[cyan]}%}[%n:${HOST}]
%{${fg[yellow]}%}%~%{${reset_color}%}
$ "
fi

# zsh settings
autoload -U compinit; compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

setopt magic_equal_subst
setopt list_types
unsetopt no_match
setopt IGNOREEOF
setopt AUTO_CD

# Prevent annoying things
unset zle_bracketed_paste # ^[[2004h
bindkey -a '^[[3~' delete-char # <DEL> to be {lower,upper}case
# ls
# {{{
if type exa &>/dev/null;then
  local exaGen='da=1;30:di=1;35:uu=33:'
  local exaMov='*.mkv=1;32:*.mp4=1;32:*.mpeg4=1;32:'
  # local exaImg='*.png=1;32:*.jpg=1;32:*.jpeg=1;32:*.webp=1;32:*.apng=1;32:'
  local exaImg='*.mp3=1;36:*.wav=1;36:*.flac=1;32:'
  export EXA_COLORS="${exaGen}${exaMov}${exaImg}"
  alias ls="exa --long -m --time-style iso"
  alias ll="exa --long -am --time-style iso"
else
  export LS_COLORS="rs=0:di=0;95:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:"
  zstyle ':completion:*' list-colors "${LS_COLORS}"
  alias ls="ls --color=auto"
fi
# }}}

# Exports
#{{{
# linux shortcut
export PATH=${PATH}:${HOME}/opt:${HOME}/.local/bin

# Firefox - latest
if [ -f ${HOME}/opt/firefox/firefox ]; then
  export PATH=${PATH}:${HOME}/opt/firefox
fi

# tor
if [ -f ${HOME}/.tor ]; then
  export PATH=${PATH}:${HOME}/opt/tor
fi

# Rust
if [ -d ${HOME}/.cargo ]; then
  export PATH="${PATH}:${HOME}/.cargo/bin"
fi

# Node JS npm/yarn
if type npm &>/dev/null; then
  npm config set prefix ~/.local/
  export NO_UPDATE_NOTIFIER=1 # node.js
  if [ -e "${HOME}/.local/bin/npm" ];then
    alias npm="${HOME}/.local/bin/npm"
  fi
fi
if type yarn &>/dev/null; then
  export NODE_PATH="${HOME}/.yarn/bin"
  export PATH="${PATH}:$(yarn global bin):$(yarn global dir)/node_modules/.bin"

  if [ ${UID} -eq 0 ]; then # if Root
    export PATH="${PATH}:$(sudo yarn global bin):$(sudo yarn global dir)/node_modules/.bin"
  fi
fi

# JAVA
if type java &>/dev/null; then
  export JAVA_HOME=$(update-alternatives --query javac 2>/dev/null | sed -n -e 's/Value: *\(.*\)\/bin\/javac/\1/p')
  export DERBY_HOME=$JAVA_HOME/db
  export J2SDKDIR=$JAVA_HOME
  export J2REDIR=$JAVA_HOME/jre
  export PATH=${PATH}:$JAVA_HOME/bin:$DERBY_HOME/bin:$J2REDIR/bin
fi

# Android
if [ -d ${HOME}/Android ]; then
  export ANDROID_HOME=${HOME}/Android/Sdk
  export ANDROID_SDK_HOME=${HOME}/Android/Sdk
  export NDK_HOME=${HOME}/Android/android-ndk-r20
  export PATH=${PATH}:${ANDROID_HOME}/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin
  # export PATH=${PATH}:${ANDROID_HOME}/build-tools/$(sdkmanager --list |grep -e build-tools/|sed -e "s|\(.*\)build-tools\/\(.*\)\/|\2|" -e "s| ||g")
fi

# Swift
if [ -d ${HOME}/opt/swift ]; then
  export PATH=${PATH}:${HOME}/opt/swift/build/Ninja-ReleaseAssert/swift-linux-x86_64/bin
fi

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

# Monero
if [ -d ${HOME}/opt/monero-gui-v0.12.0.0 ]; then
  export PATH=${PATH}:${HOME}/opt/monero-gui-v0.12.0.0
fi
# GXChain
if [ -d ${HOME}/opt/wasm ]; then
  export WASM_ROOT=${HOME}/opt/wasm
  export C_COMPILER=clang-4.0
  export CXX_COMPILER=clang++-4.0
fi

# FileZilla
if [ -d ${HOME}/opt/FileZilla3/bin ]; then
  export PATH=${PATH}:${HOME}/opt/FileZilla3/bin
fi

# Ruby
if [ -d ${HOME}/.rbenv/bin ];then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi

# Mozc & fcitx - IME
export XIM_PROGRAM=fcitx
export XIM=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
type fcitx-autostart &>/dev/null && (fcitx-autostart&>/dev/null &)
#}}}

# aliases
# {{{
# Record
# function rec() {
#     # {{{
#     if echo $(hostname) | fgrep -q laptop; then
#         if !(type arecord&>/dev/null); then
#             echo "arecord is not installed"
#             return
#         fi
#         [ ! -d "${HOME}/Music/Records" ] && mkdir -p "${HOME}/Music/Records"
#         arecord -f S16_LE -r 44100 "${HOME}/Music/Records/$(date "+%Y.%m.%d;%H:%M:%S").wav"
#     fi
# } # }}}

# LINE notify
function rep() {
  # {{{
  if [ -z "${LINE_NOTIFY_TOKEN}" ];then
    echo "env_var 'LINE_NOTIFY_TOKEN' must be set."
    return
  fi
  local message=$1
  if [ $# -ne 1 ] || [ -z "${message}" ];then
    echo 'usage: `rep some_message_you_want`'
    return
  fi
  curl -Ss -X POST \
    -H "Authorization: Bearer ${LINE_NOTIFY_TOKEN}" \
    -F "message=$message" \
    https://notify-api.line.me/api/notify
  } # }}}

# 'bat' aliased to 'cat'
if type bat &>/dev/null;then
  # {{{
  alias cat="bat"
fi # }}}

# 'rg' aliased to 'grep'
if type rg &>/dev/null;then
  # {{{
  alias grep="rg"
fi # }}}

# pdf2jpg
function pdf2jpg() {
  # {{{
  help() {
    echo 'DESCRIPTION: find .pdf and make jpg'
    echo 'Usage: pdf2jpg [filename]'
    echo 'This command execute all pdf to jpg in current working directory unless specify filename'
    return
  }
if [ $# -eq 0 ];then
  trgs=$(find $PWD |sed -e 's/^/"/g' -e 's/$/"/g'|grep -e '\(.*\)\.pdf"$'|tr '\n' ' ')
  for trg in ${(Q)${(z)trgs}};do
    convert -density 300 -trim "$trg" -quality 100 "${trg%%.*}.jpg"
  done
else
  convert -density 300 -trim $1 -quality 100 ${1%%.*}.jpg
fi
} # }}}

# p*xz compress
function pxc() {
  # {{{
  if type pixz &>/dev/null; then
    local trg="$1"
    if [ $# -eq 1 ];then
      trg="$2"
    else
      echo 'Quets must be 1 like `pxc "folder_to_compress"`'
      return
    fi
    while [ -e "$trg.tar.xz" ]; do
      trg+="_"
    done
    tar cf - "$1" -P | pv -s $(du -sb "$1" | awk '{print $1}') | pixz -9 -- > "$1.tar.xz"
  fi
}
_pxc() {
  _path_files -/
}
compdef _pxc pxc
# }}}

# p*xz decompress
function pxx() {
  # {{{
  if type pixz &>/dev/null; then
    if [ $# -ne 1 ];then
      echo 'Quets must be 1 like `pxx "folder_to_decompress.tar.xz"`'
      return
    fi
    tar xf $1 --use-compress-prog=pixz
  fi
}
_pxx() {
  _path_files -g *.tar.xz
}
compdef _pxx pxx
# }}}

# Completions
# {{{
_rsync() {
  _path_files -f
}
compdef _rsync rsync
# }}}

# uf to png
function uf2png() {
  # {{{
  if type uiflow &>/dev/null; then
    if [ $# -eq 1 ];then
      uiflow -i "$1" -o"$1".png -f png
    elif [ $# -eq 2 ];then
      uiflow -i "$1" -o"$2".png -f png
    else
      echo "Inivalid Arguments count."
    fi
  fi
} # }}}
function atc() {
  # {{{
  if [ $# -eq 1 ];then
    echo "compile & execute $1.cpp"
    g++ $1.cpp -o z.out && ./z.out
  elif [ $# -eq 2 -a $2 = 's' ];then
    cat $1.cpp |xsel -bi
  else
    cat src/main.rs|xsel -bi
  fi
}
# }}}
function ptex() {
  # {{{
  if [ ! $(which uplatex) ] || [ ! $(which dvipdfmx) ];then
    echo 'uplatex or dvipdfmx is not installed. Please install latex'
    return
  fi
  inp=$1
  ext="$(echo "$inp"|sed -e 's/.*\.\(.*\)/\1/')"
  if [ "$ext" != 'tex' ];then
    echo 'input file extension must be .tex'
    return
  fi
  fname="$(echo "$inp"|rev|cut -c 5-|rev)"
  uplatex "$fname" && dvipdfmx "$fname"
}
# }}}

function rand() {
  # {{{
  local range max to_clipboard randstr
  local -A opthash
  zparseopts -D -A opthash -- i -int w -week c -clipboard
  if [[ -n "${opthash[(i)-i]}" ]] || [[ -n "${opthash[(i)--int]}" ]]; then
    range='0-9'
  elif [[ -n "${opthash[(i)-w]}" ]] || [[ -n "${opthash[(i)--week]}" ]]; then
    range='0-9a-zA-Z'
  else
    range='0-9a-zA-Z\^$/|()[]{}.,?!_=&@~%#:;'
  fi
  to_clipboard=0
  if [[ -n "${opthash[(i)-c]}" ]] || [[ -n "${opthash[(i)--clipboard]}" ]]; then
    to_clipboard=1
  fi

  if [ $# -eq 1 ];then
    count=$(($1))
  else
    count=100
  fi
  randstr="$(cat /dev/urandom|tr -dc $range|head -c $count)"
  if [ $to_clipboard -eq 1 ];then
    echo -n "$randstr"|xsel -bi
  else
    echo $randstr
  fi
}
#}}}

function keygen() {
  # {{{
  local comment path
  local -A opthash
  zparseopts -D -A opthash -- f: -file:
  path="$HOME/.ssh/id_ed25519"
  if [[ -n "${opthash[(i)-f]}" ]];then
    path="${opthash[-f]}"
  elif [[ -n "${opthash[(i)--file]}" ]];then
    path="${opthash[--file]}"
  fi

  if [ $# -eq 1 ];then
    comment="$1"
  else
    comment="$HOST"
  fi
  /usr/bin/ssh-keygen -o -a 100 -t ed25519 -f "$path" -C "$comment"
}
#}}}

function rust() {
  # {{{
  if (!type cargo &>/dev/null); then
    echo "This function needs 'cargo'"
    return 1
  fi
  if (!type systemfd &>/dev/null); then
    echo "This function needs 'systemfd'"
    echo "please 'cargo install systemfd'"
    return 1
  fi
  local port mode
  local -A opthash
  zparseopts -D -A opthash -- p: t v
  port=3000
  if [[ -n "${opthash[(i)-p]}" ]];then
    port="${opthash[-p]}"
  fi

  mode='run'
  if [[ -n "${opthash[(i)-t]}" ]];then
    mode='test'
  fi
  if [[ -n "${opthash[(i)-v]}" ]];then
    mode='vue'
  fi

  if [ "${mode}" = 'vue' ];then
    systemfd --no-pid -s http::"${port}" -- cargo watch -i 'static/*' -s 'cd vue && yarn build && cd .. && cargo run'
  else
    systemfd --no-pid -s http::"${port}" -- cargo watch -x ${mode}
  fi
}
#}}}

function cnv() {
  # {{{
  local temp=$(mktemp)
  local target="$1"
  if [ ! -n "$target" ] || [ ! -n "$temp" ]; then
    echo "Specify argument"
    return
  fi
  cat "$target"|nkf > "$temp" && cat "$temp" > "$target"
} # }}}

function wget_all() {
  # {{{
  wget --mirror --page-requisites --span-hosts --quiet --show-progress --no-parent --convert-links --no-host-directories --adjust-extension --execute robots=off $*
} # }}}

function u() {
  # {{{
  loginctl unlock-session $*
} # }}}

# git->lab Setting
function git() {
  # {{{
  if type lab &>/dev/null && nc -w 1 google.com -z 80; then
    lab $*
  else
    git $*
  fi
}
# }}}

alias scp='scp -c aes256-ctr -pq'
# }}}

# For Vimmer
set -o vi # vi-mode
alias vi='vim'
alias v='vim'
export GIT_EDITOR=vim
export EDITOR=vim

# Compile .zshrc
if [ -f ~/.zshrc ] && [ ! -f ~/.zshrc.zwc ] || [ ~/.zshrc -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi

# Xmodmap
if [[ -f ~/.zprofile ]] && [[ ! $(cat ~/.zprofile|fgrep 'type xmodmap&>/dev/null && xmodmap ~/.Xmodmap') ]]; then
  echo '[[ -f ~/.Xmodmap ]] && type xmodmap&>/dev/null && xmodmap ~/.Xmodmap' >> ~/.zprofile
fi

