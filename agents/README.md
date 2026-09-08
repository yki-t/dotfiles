# agents

Claude Code と Codex CLI の共通設定。

## 構成

| パス | 内容 | Claude Code | Codex |
|---|---|---|---|
| `rules/` | 指示ファイル | `~/.claude/rules` (symlink) | `~/.codex/AGENTS.md` に連結 (build.sh) |
| `skills/` | SKILL.md | `~/.claude/skills` (symlink) | `~/.agents/skills` (symlink) |
| `agents/` | サブエージェント定義 (Markdown) | `~/.claude/agents` (symlink) | `~/.codex/agents/*.toml` に変換 (build.sh) |
| `hooks/hooks.json` | hook 定義 | `llms/claude/settings.json` の `hooks` に反映 (build.sh) | `~/.codex/hooks.json` (symlink) |
| `hooks/cc-rein/` | hook 実装 (git 管理外) | `~/.cargo/bin/cc-rein` | 同左 |
| `llms/claude/` | CLAUDE.md, settings.json, swarm | symlink | - |
| `llms/codex/` | config.toml, AGENTS.md (Codex 固有追記) | - | symlink / 連結 |

## 手順

```bash
bash link.sh          # symlink 作成
bash agents/build.sh  # 生成物の更新
```
