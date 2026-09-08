---
name: personal
description: 個人データアーカイブ (Slack・メール・Google Drive) を横断検索して質問に答える
argument-hint: <検索したい内容>
---

# personal

## タスク

`/home/yuki/di/ext/Archive` に蓄積された個人データアーカイブから、指定された内容を検索して回答する。

## データ構成

全体像は `/home/yuki/di/ext/Archive/README.md` を参照。詳細仕様が必要な場合のみ各ディレクトリの `dump-spec.md` を読む。

| ディレクトリ | 内容 | パス構造 |
|-------------|------|---------|
| `slack/` | Slackメッセージ (7ワークスペース) | `<TeamID>-<TeamName>/<ChannelID>-<ChannelName>/<YYYY-MM-DD_HH-MM-SS>.md` |
| `email/` | メール (7アカウント混在) | `<YYYY-MM>/<YYYY-MM-DD_HH-MM-SS>.md` |
| `google-drive/` | Google Driveのミラー | `my-drive/` `shared-drives/<Drive名>/` `shared-with-me/<ID8>_<名前>/` |

- slack/email は 1ファイル = 1メッセージ/1メール の Markdown。添付は同階層の `data/`
- メールはファイル先頭が `# <From> → <To> — 日時`、次行以降に `Subject:` ヘッダ
- Slackのユーザーは表示名で記載される (メールアドレスではない)
- google-drive はバイナリ含む生ファイル。Googleドキュメント類は docx/xlsx/pptx

## 検索戦略

複数の角度から検索し、初回ヒットで打ち切らない:

```bash
# 本文検索 (slack/email)。日本語もそのまま検索可能
rg -li "キーワード" /home/yuki/di/ext/Archive/slack /home/yuki/di/ext/Archive/email

# 期間で絞り込み (ファイル名 = JSTの日時)
rg -li "キーワード" --glob '2025-09-*' /home/yuki/di/ext/Archive/email
ls /home/yuki/di/ext/Archive/email/2025-09/

# チャンネル・ワークスペースで絞り込み
ls /home/yuki/di/ext/Archive/slack/                 # ワークスペース一覧
rg -li "キーワード" "/home/yuki/di/ext/Archive/slack/T01G5HFUV8A-合同会社LOCAL"

# google-drive はまずファイル名・ディレクトリ名で探す
fd "キーワード" /home/yuki/di/ext/Archive/google-drive
# テキスト系ファイルなら本文検索も可能
rg -li "キーワード" /home/yuki/di/ext/Archive/google-drive
```

- 人名・案件名は表記ゆれ (漢字/かな/ローマ字、敬称) を考慮して複数パターン試す
- ヒットが多い場合は `rg -c` で件数を見てから絞り込む
- 添付ファイルは Markdown 内の `- file: [...](data/...)` リンクから辿る
- docx/xlsx などバイナリの中身が必要な場合は python (zipfile + XML) 等で抽出する

## 出力

- 回答には必ず出典 (ファイルパス) を添える
- 日時・発言者・宛先など文脈情報も引用する
- 見つからなかった場合は、試した検索条件を列挙して報告する
