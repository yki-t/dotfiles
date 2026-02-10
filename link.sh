#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"&>/dev/null &&pwd)" # SCRIPT_DIR

ln -snf $DIR/.vim ~/
ln -snf $DIR/.gitignore ~/
ln -snf $DIR/.gitmodules ~/
ln -snf $DIR/.private.sh ~/
ln -snf $DIR/.profile ~/
ln -snf $DIR/.vimrc ~/
ln -snf $DIR/.zprofile ~/
ln -snf $DIR/.zshrc ~/
ln -snf $DIR/alacritty/alacritty.arch.toml ~/.alacritty.toml
ln -snf $DIR/claude/settings.json ~/.claude/
ln -snf $DIR/claude/CLAUDE.md ~/.claude/
ln -snf $DIR/claude/commands ~/.claude/
ln -snf $DIR/claude/rules ~/.claude/
ln -snf $DIR/claude/agents ~/.claude/
ln -snf $DIR/zellij ~/.config/zellij
