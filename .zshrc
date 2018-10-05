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

    ;;
    #}}}

esac


