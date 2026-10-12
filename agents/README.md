# agents

Claude Code, Codex CLI, Hermes Agent の共通設定。

## 構成

| パス | 内容 | Claude Code | Codex | Hermes |
|---|---|---|---|---|
| `rules/` | 指示ファイル | `~/.claude/rules` (symlink) | `~/.codex/AGENTS.md` に連結 (build.sh) | skill `rules` に連結し `skills.auto_load` で全セッションに注入 (build.sh) |
| `skills/` | SKILL.md | `~/.claude/skills` (symlink) | `~/.agents/skills` (symlink) | `skills.external_dirs` で `~/.agents/skills` を参照 |
| `agents/` | サブエージェント定義 (Markdown) | `~/.claude/agents` (symlink) | `~/.codex/agents/*.toml` に変換 (build.sh) | 同名の skill に変換し `delegate_task` の `context` に渡す (build.sh) |
| `hooks/hooks.json` | hook 定義 | `llms/claude/settings.json` の `hooks` に反映 (build.sh) | `~/.codex/hooks.json` (symlink) | - |
| `hooks/hermes-date.sh` | 日時注入 hook | - | - | `hooks.pre_llm_call` (build.sh) |
| `hooks/cc-rein/` | hook 実装 (git 管理外) | `~/.cargo/bin/cc-rein` | 同左 | - |
| `llms/claude/` | CLAUDE.md, settings.json, swarm | symlink | - | - |
| `llms/codex/` | config.toml, AGENTS.md (Codex 固有追記) | - | symlink / 連結 | - |
| `llms/hermes/` | rules.md (Hermes 固有追記), config.yaml (`~/.hermes/config.yaml` にマージするキー), skills/ (生成物) | - | - | build.sh |

Hermes の `~/.hermes/config.yaml` は Hermes 自身が書き換えるため symlink せず、`llms/hermes/config.yaml` にあるキーだけを build.sh でマージする。

Hermes は SKILL.md の `disable-model-invocation` を解釈しないため、該当 skill も model から呼ばれ得る。shell hook は初回起動時に承諾を求められる。

## 手順

```bash
bash link.sh          # symlink 作成
bash agents/build.sh  # 生成物の更新
```
