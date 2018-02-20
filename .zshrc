#プロンプトの表示設定
autoload colors; colors
PROMPT="%{${fg[cyan]}%}[%n:${HOST}]
%{${fg[yellow]}%}%~%{${reset_color}%}
$ "

# 補完の設定
autoload -U compinit
compinit

# 対話モードでプロンプトに ^[[2004hと表示されるのを防ぐ
unset zle_bracketed_paste

autoload -Uz colors
colors

# ls の設定
# {{{
case ${OSTYPE} in
    darwin*)
        export LSCOLORS=gxfxcxdxbxegedabagacad
        alias ls="ls -FG"
        alias ll="ls -alFG"
        zstyle ':completion:*' list-colors di=34 ln=35 ex=31
        zstyle ':completion:*:kill:*' list-colors \
            '=(#b) #([0-9]#)*( *[a-z])*=34=31=33'
        zstyle ':completion:*' group-name ''
        zstyle ':completion:*:descriptions' format '%BCompleting%b %U%d%u'
        ;;

    linux*)
        export LS_COLORS="rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:"
        alias ls="ls -GF --color=auto"
        alias ll="ls -alGF --color=auto"
        alias gls="gls --color"
        zstyle ':completion:*' list-colors 'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'
        ;;
esac
#}}}

# vimの設定
alias vi='vim'
alias v='vim'
alias gt='git log --graph --oneline --all'
function com(){
    env WINEPREFIX="/home/usr/.wine" wine-stable C:\\users\\usr\\Local\ Settings\\Application\ Data\\LINE\\bin\\LineLauncher.exe;
    thunderbird&;
    slack&;
}

# 補完時に大文字小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# コマンドがディレクトリの名前の時に自動的にcdコマンドとして実行する
setopt AUTO_CD

# pub ssh
function sshp(){
#{{{
    read host\?'host: '
    while [ ${#host} -eq 0 ]; do
        echo '[hostname error] Try again.'
        read host\?'host: '
    done

    read port\?'port: '
    [ ${#port} -eq 0 -o ! $(expr "$port" + 1 > /dev/null 2>&1; echo $?) -ne 2 ] && port=22

    read user\?'user: '
    while [ ${#user} -eq 0 ]; do
        echo '[username error] Try again.'
        read user\?'host: '
    done

    read pub_key_trg\?'pub_key(defalut=host): '
    if [ ${#pub_key_trg} -eq 0 ]; then
        pub_key_trg="~/.ssh/id_${host}_rsa"
    else
        if [ -e ~/.ssh/id_${pub_key_trg}_rsa ]; then
            pub_key_trg="~/.ssh/id_${pub_key_trg}_rsa"
        else
            pub_key_trg="~/.ssh/id_rsa"
        fi
    fi
    echo "[settings ok]"

    while [ true ];do
        ssh -p ${port} -i ${pub_key_trg} -l ${user} ${host}
    done
}
#}}}

# ----------
# エイリアス
# ----------
alias c='cd'

# ----------
# Exports
# ----------
export GIT_EDITOR=vim

case ${OSTYPE} in
    darwin*)
    # brew
    alias install_brew='/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
    alias remove_brew='ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"'

    alias install_kivy='pip install Cython==0.26.1 && pip install kivy || pip install https://github.com/kivy/kivy/archive/master.zip
    '

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
    ;;

    linux*)
   ;;
esac
