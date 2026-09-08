#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"&>/dev/null &&pwd)" # SCRIPT_DIR

ln -snf $DIR/.vim ~/
ln -snf $DIR/.gitconfig ~/
ln -snf $DIR/.gitignore ~/
ln -snf $DIR/.gitmodules ~/
ln -snf $DIR/.private.sh ~/
ln -snf $DIR/.profile ~/
ln -snf $DIR/.vimrc ~/
ln -snf $DIR/.zprofile ~/
ln -snf $DIR/.zshrc ~/
ln -snf $DIR/alacritty/alacritty.arch.toml ~/.alacritty.toml
mkdir -p ~/.claude ~/.codex ~/.agents
ln -snf $DIR/agents/llms/claude/settings.json ~/.claude/
ln -snf $DIR/agents/llms/claude/CLAUDE.md ~/.claude/
ln -snf $DIR/agents/skills ~/.claude/
ln -snf $DIR/agents/rules ~/.claude/
ln -snf $DIR/agents/agents ~/.claude/
ln -snf $DIR/agents/skills ~/.agents/
ln -snf $DIR/agents/hooks/hooks.json ~/.codex/
ln -snf $DIR/agents/llms/codex/config.toml ~/.codex/
ln -snf $DIR/zellij ~/.config/zellij
