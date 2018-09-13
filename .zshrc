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
# Aliases and Others               #
#################################
#{{{
# exe mkdir && cd
function mkcd() {
  if [[ -d $1 ]]; then
    echo "$1 already exists!"
    cd $1
  else
    mkdir -p $1 && cd $1
  fi
}
#export TERM=xterm-color256
#}}}

#################################
# Software Individual Setting   #
#################################

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

# vim setting
#{{{
alias vi='vim'
alias v='vim'
#}}}

# Git Setting
#{{{
export GIT_EDITOR=vim
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
}#}}}

#################################
# Exports                       #
#################################
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
        export PATH="$PATH:$(yarn global bin)"
    fi

    # JAVA
    if [ -e "$(which java)" ];then
        JAVA_HOME=$(update-alternatives --query javac | sed -n -e 's/Best: *\(.*\)\/bin\/javac/\1/p')
    fi

    # Android
    if [ -d $HOME/opt/android ]; then
        export ANDROID_HOME=$HOME/opt/android
        export PATH=$PATH:$ANDROID_HOME/bin
        alias android=$ANDROID_HOME/tools/android
        alias emulator=$ANDROID_HOME/tools/emulator
        export PATH=$PATH:$ANDROID_HOME/tools/bin
    fi
    # Swift
    if [ -d $HOME/opt/swift ]; then
        export PATH=$PATH:$HOME/opt/swift/build/Ninja-ReleaseAssert/swift-linux-x86_64/bin
    fi

    # Nativescipt
    if [ -d "/opt/NativeScript Sidekick" ]; then
        alias nsk="/opt/NativeScript\ Sidekick/NativeScript\ Sidekick"
    fi
    if [ -f $HOME/.tnsrc ]; then
        source $HOME/.tnsrc 
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

    ;;
    #}}}

esac


