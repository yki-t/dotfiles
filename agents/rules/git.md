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

## Pull Request

Follow the title and description style of recent merged PRs (`gh pr list --state merged`) when they show a consistent style. Project convention overrides the rules below.

### Title
- No conventional commit prefix (feat:, fix:)
- State the intent (Why), not only what changed

### Description
Sections, in this order:
- Summary
- Changes Made (grouped by intent, not a file-by-file narration)
- Test Plan (checkboxes `- [ ]`; check only what was confirmed)
- Related Commits (commit title and hash)

### Content
- Plain past tense, objective and neutral (noun phrases acceptable)
- Write what is not recoverable from the diff: intent, constraints, rejected alternatives
- Describe only the final state; no work history (previous attempts, review-fix iterations)
- State unverified items explicitly; do not pad the description to mask uncertainty

### Prohibited
- Deployment Instructions
- Bold emphasis with `**`
- Task ID references (e.g. `(UZU-XXXX)`, `Closes #123`)
- "Generated with Claude Code" signature
