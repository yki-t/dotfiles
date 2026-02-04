# Fix Review Issues

Fix the issues identified in the code review.

## Input

You will receive:
- REVIEW_RESULT: JSON containing the issues to fix

## Task

1. Parse the REVIEW_RESULT to get the list of issues
2. For each issue:
   - Read the relevant file
   - Implement the fix
   - Create a commit
3. Do NOT push (commits stay local)

## Guidelines

- Do NOT ask for user approval (this is automated)
- Fix ALL issues in REVIEW_RESULT
- One commit per logical fix (can group related fixes)
- Commit message: conventional format, Japanese (English technical terms OK)

## Output

You MUST output valid JSON only (no markdown, no explanation):

```json
{
  "success": true,
  "fixes": [
    {
      "issue": "Original issue description",
      "commit_hash": "<hash>",
      "files_changed": ["file1"]
    }
  ]
}
```

If fixing fails:

```json
{
  "success": false,
  "error": "<error description>",
  "partial_fixes": []
}
```
