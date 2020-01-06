OSTYPE=$(uname)
#test -r ~/.zshrc && . ~/.zshrc

# 補完
autoload -U compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

setopt magic_equal_subst
setopt list_types

unsetopt no_match
set -o vi

# color
autoload -Uz colors
colors

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
[ -f "$(which fcitx-autostart)" ] && (fcitx-autostart&>/dev/null &)
export PATH="$HOME/.cargo/bin:$PATH"

