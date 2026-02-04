# Code Review

Review the local changes from all perspectives.

## Input

You will receive:
- BASE_BRANCH: The base branch to compare against

## Task

1. Get diff with `git diff ${BASE_BRANCH}...HEAD`
2. Read relevant parts of the codebase for context
3. Review from these perspectives (in priority order):
   - **Consistency**: Naming, patterns, code style, existing utilities
   - **Security**: OWASP top 10, input validation, auth
   - **Performance**: N+1 queries, unnecessary allocations
   - **General**: Code quality, readability

## Guidelines

- Do NOT ask for user approval
- Be strict but fair
- Only flag real issues, not style preferences

## Output

You MUST output valid JSON only (no markdown, no explanation):

```json
{
  "has_issues": false
}
```

Or if issues are found:

```json
{
  "has_issues": true,
  "issues": [
    {
      "severity": "critical|important",
      "file": "path/to/file",
      "line": 42,
      "message": "Description of the issue",
      "suggestion": "How to fix it"
    }
  ]
}
```

Severity levels:
- critical: Must fix (security, correctness)
- important: Should fix (consistency, maintainability)

Do NOT include minor suggestions or style preferences.
