# review

## Task
Review a Pull Request from all perspectives and post line comments.

## Arguments
- PR number or URL (required)

## Workflow

1. **Fetch PR**
   - Get PR diff with `gh pr diff {number}`
   - If diff is large, read in chunks

2. **Research**
   - Understand changes
   - Compare with existing codebase patterns
   - Identify issues from all perspectives

3. **Draft Review**
   - Review from all perspectives (in priority order):
     1. **Consistency** (most important): Naming, patterns, code style, existing utilities
     2. **Security**: OWASP top 10, input validation, auth
     3. **Performance**: N+1 queries, unnecessary allocations
     4. **General**: Overall code quality, readability
   - Categorize findings:
     - Critical: Must fix
     - Important: Should fix
     - Question: Ask coder about intent
   - Comment tone (Critical/Important only):
     - Use assertive language (e.g., "should", "must")
     - Avoid vague expressions (e.g., "consider", "検討してください")
   - Include specific file paths and line numbers
   - Present draft to user

4. **User Approval**
   - Wait for explicit user approval before posting
   - User reviews as themselves, so approval is mandatory
   - Even partial modifications require full approval of final draft
   - Ask if user wants to add a review summary (body)
   - Do NOT post without approval

5. **Post Review**
   - After approval, post review using `gh api`
   - Include review body only if user provided one

## Output Format (Draft)

```
## PR #{number} Review

### Consistency
1. **File:** `path/to/file.rs` **Line:** 42
   - Issue description

### Security
...

### Performance
...

### General
...
```

## API Call Format

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  -X POST --input - <<EOF
{
  "commit_id": "{commit_id}",
  "event": "COMMENT",
  "body": "Review summary (optional)",
  "comments": [
    {"path": "file.rs", "line": 42, "body": "Comment"}
  ]
}
EOF
```

## Examples
- `/review 157` - Review PR #157
- `/review https://github.com/org/repo/pull/157` - Review from URL
