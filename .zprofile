OSTYPE=$(uname)
#test -r ~/.zshrc && . ~/.zshrc

# 補完
autoload -U compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

setopt magic_equal_subst # =以降も補完する(--prefix=/usrなど)
setopt list_types              # 補完候補にファイルの種類も表示する

unsetopt no_match # wildcard など使えるように
set -o vi # binding

# color
autoload -Uz colors
colors

# Ctrl+Dでログアウトしてしまうことを防ぐ
setopt IGNOREEOF


# Prevent prompt from showing ^[[2004h
unset zle_bracketed_paste
setopt AUTO_CD
alias c='cd'

export GIT_EDITOR=vim
export EDITOR=vim

export XIM_PROGRAM=fcitx
export XIM=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
export PATH="$HOME/.cargo/bin:$PATH"
