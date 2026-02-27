---
name: rfix
description: Implement fixes for PR review comments and post responses
argument-hint: <PR number or URL>
disable-model-invocation: true
---

# review-fix

## Task
Implement fixes for review comments and post responses.

## Arguments
- PR number or URL (required)

## Workflow

1. **Identify Target Comments**
   - Get review comments with `gh pr view {number} --comments` or `gh api`
   - List unresolved review comments
   - Address all comments by default (user can specify to skip)

2. **Implement Fixes** (loop for each comment)
   - Implement the fix for the selected comment
   - Create a commit for the fix
   - Draft a response (do NOT post yet)

3. **Request Approval**
   - Present all commits and draft responses together
   - Allow modification of commit messages if user requests
   - Wait for explicit user approval

4. **Post Responses**
   - User pushes commits
   - Post all replies using `gh api`

## API Call Format

```bash
# Reply to a review comment
gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies \
  -X POST -f body="こちらで対応しました
{commit_hash}"
```

## Notes
- This command is allowed to create commits (exception to CLAUDE.md git restrictions)

## Examples
- `/rfix 157` - Respond to review comments on PR #157
- `/rfix https://github.com/org/repo/pull/157` - Respond from URL
