---
name: pr
description: Create a Pull Request against a specified base branch
argument-hint: <base-branch>
disable-model-invocation: true
---

# pull request

## Task
Create a Pull Request against the base branch specified in Arguments.
- Fetch the base branch with git fetch
- Draft the PR and get user approval
- After approval, create the PR (use gh command)

## Summary
Use git commands to get diff title and content, understand the changes, then use them for PR title and description.
Ask questions if unclear.
Include not just what changed (What) but also the intent behind changes (Why) in title and description.

## Format
### Title
- Do not include prefixes like feat: in the title.

### Description
Include the following in the PR description:
- Summary
- Changes Made
- Related Commits (list of commit titles and hashes)

Do not include:
- Test Plan
- Deployment Instructions
- Bold emphasis with `**`

## Notes
- Check if project PR conventions exist. If so, follow them. Check:
  - [ ] README.md
  - [ ] CLAUDE.md
  - [ ] docs/
- No "Generated with Claude Code" signature at the end
- Write in plain past tense, objective and neutral (noun phrases acceptable)
- Assume commit and push are already done (even if user doesn't mention it)
- Use `git diff base...HEAD` (3 dots) to get only changes made in this branch, not `git diff base..HEAD` (2 dots)
