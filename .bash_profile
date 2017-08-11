export PATH=/usr/local:/usr/local/lib/python2.7/site-packages:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export PYENV_ROOT=/usr/local/var/pyenv
eval "$(pyenv init -)"

export PATH="$HOME/.linuxbrew/bin:$PATH"
export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"
export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"
export LD_LIBRARY_PATH="$HOME/.linuxbrew/lib:$LD_LIBRARY_PATH"

test -r ~/.bashrc && . ~/.bashrc

