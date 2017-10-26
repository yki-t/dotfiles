export LNAG=ja_JP.UTF-8

export PATH=/usr/local/lib/python2.7/site-packages:/usr/local:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

#プロンプトの表示設定
autoload colors
colors
if [ -w / ] ; then
    PROMPT="[${USER}@${HOST%%.*} %1~]%(!.#.$) "

else
    PROMPT="%{${fg[yellow]}%}%~%{${reset_color}%}
$ "
fi

# 補完の設定
autoload -U compinit
compinit


# ls の色設定
export LSCOLORS=exfxcxdxbxegedabagacad
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
alias ls="ls -GF"
alias gls="gls --color"
zstyle ':completion:*' list-colors 'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'

# vimの設定
alias vi='vim'
alias v='vim'



