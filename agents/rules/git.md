# Git

## Commit Message

### Format
- One line only
- Conventional commit format (e.g., feat:, fix:, docs:, refactor:)
- In Japanese (English technical terms allowed)
- Concise summary of key points
- Follow the style of the recent commits (`git log --oneline -10`) when they show a consistent style

### Content
- State the intent of the change, not a narration of the diff (no file lists, no mechanical restatement)
- If the reason for the change is not recoverable from the diff, include it briefly (e.g. 「〜のため」)

### Prohibited
- "Co-Authored-By: Claude" signature
- `#` prefix on commit hashes
- Task ID references (e.g. `(UZU-XXXX)`, `Closes #123`)
