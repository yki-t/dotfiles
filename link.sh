#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"&>/dev/null &&pwd)" # SCRIPT_DIR

ln -snf $DIR/services/fcitx.service ~/.config/systemd/user/
ln -snf $DIR/services/kwin_x11.service ~/.config/systemd/user/

ln -snf $DIR/.vim ~/
ln -snf $DIR/.gitconfig ~/
ln -snf $DIR/.gitignore ~/
ln -snf $DIR/.gitmodules ~/
ln -snf $DIR/.private.sh ~/
ln -snf $DIR/.profile ~/
ln -snf $DIR/.sshrc ~/
ln -snf $DIR/.vimrc ~/
ln -snf $DIR/.xinitrc ~/
ln -snf $DIR/.Xmodmap ~/
ln -snf $DIR/.zprofile ~/
ln -snf $DIR/.zshrc ~/
ln -snf $DIR/claude/settings.json ~/.claude/
ln -snf $DIR/claude/CLAUDE.md ~/.claude/
