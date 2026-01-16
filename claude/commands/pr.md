# pull request

## Task
Argumentsで与えられるBaseブランチに対してPull Requestを作成してください。
- git fetchでbaseブランチを最新化する
- PRを仮構成しユーザーに承認を得る
- 承認後、PRを作成する (ghコマンドを使用)

## Summary
gitコマンドを使用して差分タイトルと差分内容を取得し、変更内容を理解してからPRのタイトルと説明に使用してください。
    不明点があれば質問してください。
単なるコードの変更(What)だけでなく、コード変更の意図(Why)もタイトルと内容に含めてください。

## Format
### Title
- タイトルには feat: 等のプレフィックスを含めないでください。

### Description
- Pull Requestの説明には以下の情報を含めてください：
    - Summary
    - Changes Made
    - Related Commits (含まれるコミットタイトルとハッシュのリスト)
- Test PlanやDeployment Instructionsは含めないでください。
- `**`での強調は避けてください。

## Notes
- プロジェクトのPRの規約が存在するか確認してください。規約が存在する場合は必ず従ってください。以下は要確認場所
    - [ ] README.md
    - [ ] CLAUDE.md
    - [ ] docs/
- 末尾の "Generated with Claude Code" のような署名は不要

