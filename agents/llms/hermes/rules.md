# Hermes

- 回答は敬体の日本語で書く。技術用語と識別子は原文のままにする。
- rules 内の skill 名（`/dev` など）は Hermes でも `/dev` のように `/` 付きで呼び出す。`/refine` は Hermes 組み込みコマンドと重なるため `/skill refine` で呼ぶ。`skill_view` でも読める。
- rules 内の `code-reviewer`、`subagents-checker` は同名の skill を指す。呼び出すときは `skill_view` でその skill の本文を読み、本文全体を `context` に入れて `delegate_task` を実行する。`goal` には対象（レビュー対象の変更、照合する要件）を書く。
- Hermes の `delegate_task` の子エージェントには本 rules は注入されない。子に守らせる rules は `context` に書く。
