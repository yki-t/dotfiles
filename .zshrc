#プロンプトの表示設定
autoload colors; colors
if [ ${UID} -eq 0 ]; then # if Root
    PROMPT="%{${fg[red]}%}[%n:${HOST}]
%{${fg[yellow]}%}%/%{${reset_color}%}
# "
else
    PROMPT="%{${fg[cyan]}%}[%n:${HOST}]
%{${fg[yellow]}%}%~%{${reset_color}%}
$ "
fi

#################################
# General Setting               #
#################################
#{{{
# 補完
autoload -U compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

setopt magic_equal_subst # =以降も補完する(--prefix=/usrなど)
setopt list_types              # 補完候補にファイルの種類も表示する

# color
autoload -Uz colors
colors

# Ctrl+Dでログアウトしてしまうことを防ぐ
setopt IGNOREEOF


# Prevent prompt from showing ^[[2004h
unset zle_bracketed_paste
setopt AUTO_CD
alias c='cd'

#}}}

#################################
# Software Individual Setting   #
#################################
# vim setting
alias vi='vim'
alias v='vim'

# General
#{{{
# 補完
autoload -U compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

setopt magic_equal_subst # =以降も補完する(--prefix=/usrなど)
setopt list_types              # 補完候補にファイルの種類も表示する

# color
autoload -Uz colors
colors

# Ctrl+Dでログアウトしてしまうことを防ぐ
setopt IGNOREEOF


# Prevent prompt from showing ^[[2004h
unset zle_bracketed_paste
setopt AUTO_CD
alias c='cd'

#}}}
# Git Setting
#{{{
alias gt='git log --graph --oneline --all'
# Git shortcut
function gitinit(){
    git init
    cat <<EOF >> ./.git/config
[commit]
    template = ~/.gitmessage
EOF
    cat <<EOF >> .gitignore
.DS_Store
._*
*.bak
*.swp
*.swo
.localized
*.log
EOF
} #}}}
# ls setting
# {{{
case ${OSTYPE} in
    darwin*)
        export LSCOLORS=gxfxcxdxbxegedabagacad
        alias ls="ls -F"
        alias ll="ls -alF"
        zstyle ':completion:*' list-colors di=34 ln=35 ex=31
        zstyle ':completion:*:kill:*' list-colors \
            '=(#b) #([0-9]#)*( *[a-z])*=34=31=33'
        zstyle ':completion:*' group-name ''
        zstyle ':completion:*:descriptions' format '%BCompleting%b %U%d%u'
        ;;

    linux*)
        export LS_COLORS="rs=0:di=0;95:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:"
        alias ls="ls --color=auto"
        alias ll="ls -alF --color=auto"
        alias gls="gls --color"
        zstyle ':completion:*' list-colors "${LS_COLORS}"
        ;;
esac
#}}}

alias scp='scp -c aes256-ctr -q -p'
case ${OSTYPE} in
    darwin*)
    # if Mac
    #{{{
    # brew
    alias install_brew='/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
    alias remove_brew='ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"'
    alias install_kivy='pip install Cython==0.26.1 && pip install kivy || pip install https://github.com/kivy/kivy/archive/master.zip'
    alias install_pyenv='brew install pyenv && brew install pyenv-virtualenv && brew install pyenv-virtualenvwrapper'
    alias remove_pyenv='rm -rf /usr/local/var/pyenv'
    ;;
    #}}}

    linux*)
    # if Linux
    alias randstr="cat /dev/urandom | tr -dc '0-9a-zA-Z' | head -c100"
    # Record alias
    if echo $(hostname) | fgrep -q XPS; then
        # {{{
        if [ ! -d ${HOME}/Music/Records ];then
            mkdir -p ${HOME}/Music/Records
        fi
        alias rec='arecord -f S16_LE -r 44100 "${HOME}/Music/Records/$(date "+%Y.%m.%d;%H:%M:%S").wav"'
    fi # }}}

    # Screen capture alias
    if echo $(hostname) | fgrep -q XPS; then
        # {{{
        if [ ! -d ${HOME}/Videos/Captures ];then
            mkdir -p ${HOME}/Videos/Captures
        fi
        alias cap='if [ $(which recordmydesktop) -a $(which ffmpeg) ];then if [ -f _tmp ];then rm _tmp;fi;trgdir="${HOME}/Videos/Captures"&&echo ">>> select window by click"&&echo "--no-sound --no-wm-check --windowid $(xwininfo|grep "xwininfo: Window id"|sed -e"s/\(.*\)Window id: \(.*\) \(.*\)/\2/") -o${trgdir}/out.ogv"|xargs recordmydesktop>_tmp>/dev/null 2>&1&sleep 1&&echo ">>> ENTER e to end recording";while true;do;read ANS;if [ "${ANS}" = "e" ];then echo ">>> ending record&encode to mp4";unset ANS;killall recordmydesktop>/dev/null 2>&1;break;fi;done;sleep 2&&echo ">>> encoding now."&&while true;do sleep 1&&while read LINE;do if echo "$LINE" | grep -q "100%";then ffmpeg -i ${trgdir}/out.ogv -c:v libx264 -preset veryslow -crf 22 -c:a aac -b:a 160k -strict -2 ${trgdir}/$(date "+%Y.%m.%d.%H:%M:%S").mp4>/dev/null 2>&1&&rm _tmp&&rm ${trgdir}/out.ogv&&unset LINE&&unset trgdir&&break 2;fi;done;done<_tmp;else echo ">>> ffmpeg or recordmydesktop is not installed"&&exit;fi'
    fi # }}}

    # pdf2jpg
    function pdf2jpg(){
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
    function pxc(){
        # {{{
        if [ $(which pxz) ];then
            tar cvf $1.tar.xz --use-compress-prog=pxz $1/
        fi
    } # }}}

    # p*xz decompress
    function pxx(){
        # {{{
        if [ $(which pxz) ];then
            tar xvf $1.tar.xz --use-compress-prog=pxz $1/
        fi
    } # }}}

    ;;
    #}}}

esac

case ${OSTYPE} in
    darwin*)
    # if Mac
    #{{{
    # pyenv
    export PYENV_ROOT=/usr/local/var/pyenv
    # node js
    export NODE_PATH=/usr/local/lib/node_modules
    export NPM_PATH=/usr/local/bin/npm

    # cpp compiler setting
    export CC=/usr/local/opt/llvm/bin/clang
    export CXX=/usr/local/opt/llvm/bin/clang++
    export CXXFLAGS='-I/usr/local/opt/llvm/include -I/usr/local/opt/llvm/include/c++/v1/'
    export CPPFLAGS='-I/usr/local/opt/llvm/include -I/usr/local/opt/llvm/include/c++/v1/'
    export LDFLAGS='-L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib'
    export PATH=/usr/local/bin:~/bin:$PYENV_ROOT/bin:$NPM_PATH:$NODE_PATH:$PATH
    # pyenv auto complete
    if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi

    # nodebrew
    export PATH=$HOME/.nodebrew/current/bin:$PATH
    ;;
    #}}}

    linux*)
    # if Linux
    #{{{
    # linux shortcut
    export PATH=$PATH:$HOME/opt

    # Firefox - latest
    if [ -f $HOME/opt/firefox/firefox ]; then
        export PATH=$PATH:$HOME/opt/firefox
    fi

    # tor
    if [ -f $HOME/.tor ]; then
        export PATH=$PATH:$HOME/opt/tor
    fi

    # Rust
    if [ -d $HOME/.cargo ]; then
        export PATH="$PATH:$HOME/.cargo/bin"
    fi

    # Node JS npm/yarn
    if [ -e "$(which npm)" ];then
        npm config set prefix ~/.local/
    fi
    if [ -e "$(which yarn)" ];then
        export NODE_PATH="$HOME/.yarn/bin"
        export PATH="$PATH:$(yarn global bin):$(yarn global dir)/node_modules/.bin"

        if [ ${UID} -eq 0 ]; then # if Root
            export PATH="$PATH:$(sudo yarn global bin):$(sudo yarn global dir)/node_modules/.bin"
        fi
    fi

    # JAVA
    if [ -e "$(which java)" ];then
        export JAVA_HOME=$(update-alternatives --query javac | sed -n -e 's/Best: *\(.*\)\/bin\/javac/\1/p')
        export DERBY_HOME=$JAVA_HOME/db
        export J2SDKDIR=$JAVA_HOME
        export J2REDIR=$JAVA_HOME/jre
        export PATH=$PATH:$JAVA_HOME/bin:$DERBY_HOME/bin:$J2REDIR/bin
   fi

    # Android
    if [ -d $HOME/Android ]; then
        export ANDROID_HOME=$HOME/Android/Sdk
        export PATH=${PATH}:${ANDROID_HOME}/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin
        export PATH=${PATH}:${ANDROID_HOME}/build-tools/$(sdkmanager --list |grep -e build-tools/|sed -e "s|\(.*\)build-tools\/\(.*\)\/|\2|" -e "s| ||g")
    fi

    # Swift
    if [ -d $HOME/opt/swift ]; then
        export PATH=$PATH:$HOME/opt/swift/build/Ninja-ReleaseAssert/swift-linux-x86_64/bin
    fi

    # Monero
    if [ -d $HOME/opt/monero-gui-v0.12.0.0 ]; then
        export PATH=$PATH:$HOME/opt/monero-gui-v0.12.0.0
    fi
    # GXChain
    if [ -d $HOME/opt/wasm ]; then
        export WASM_ROOT=$HOME/opt/wasm
        export C_COMPILER=clang-4.0
        export CXX_COMPILER=clang++-4.0
    fi

    alias randstr="cat /dev/urandom | tr -dc '0-9a-zA-Z' | head -c100"

    ;;
    #}}}
esac


