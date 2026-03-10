# dotfiles

個人用の設定ファイル群。Arch Linux をメインに macOS, Windows(WSL) でも利用。

## セットアップ

```bash
git clone https://github.com/yki-t/dotfiles ~/dotfiles
cd ~/dotfiles
bash link.sh
```

Claude Code の hook を使用する場合は別途ビルドが必要。

```bash
cd ~/dotfiles/claude/hook-src
cargo build --release
```

## 構成

```
.
├── alacritty/          # Alacritty (プラットフォーム別設定)
├── claude/             # Claude Code (hooks, skills, rules, agents)
│   └── hook-src/       # hook (Rust)
├── scripts/            # ユーティリティスクリプト
├── windows/            # Windows 固有設定 (PowerShell, AutoHotkey, Windows Terminal)
├── zellij/             # Zellij
├── .vim/               # Vim/Neovim
├── .vimrc
├── .zprofile
├── .zshrc
└── link.sh             # シンボリックリンク作成スクリプト
```
