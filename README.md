# dotfiles

個人用の設定ファイル群。Arch Linux をメインに macOS, Windows(WSL) でも利用。

## セットアップ

```bash
git clone https://github.com/yki-t/dotfiles ~/dotfiles
cd ~/dotfiles
bash link.sh
```

Codex 用の生成物は `agents/build.sh` で作成する。

```bash
bash agents/build.sh
```

## 構成

```
.
├── alacritty/          # Alacritty (プラットフォーム別設定)
├── agents/             # Claude Code / Codex 共通設定 (rules, skills, agents, hooks)
│   └── llms/           # ツール固有設定 (claude, codex)
├── scripts/            # ユーティリティスクリプト
├── windows/            # Windows 固有設定 (PowerShell, AutoHotkey, Windows Terminal)
├── zellij/             # Zellij
├── .vim/               # Vim/Neovim
├── .vimrc
├── .zprofile
├── .zshrc
└── link.sh             # シンボリックリンク作成スクリプト
```
