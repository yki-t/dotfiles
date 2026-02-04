# Implementation

Implement the feature/fix based on the agreed design.

## Input

You will receive:
- ISSUE_URL: The issue URL
- DESIGN: The agreed design from clarification phase

## Task

1. Read project documentation:
   - CLAUDE.md
   - README.md
   - Relevant docs/

2. Read the DESIGN content carefully

3. Fetch issue details using `gh issue view` or `gh api` for reference

4. Implement the changes:
   - Follow existing codebase patterns
   - Use existing utilities
   - Keep changes minimal and focused
   - Implement exactly what was agreed in DESIGN

5. Create a commit with the changes

## Guidelines

- Do NOT ask for user approval (this is automated)
- Do NOT push to remote
- Commit message: conventional format, Japanese (English technical terms OK)

## Output

You MUST output valid JSON only (no markdown, no explanation):

```json
{
  "success": true,
  "commit_hash": "<hash>",
  "files_changed": ["file1", "file2"],
  "summary": "<brief description of changes>"
}
```

If implementation fails:

```json
{
  "success": false,
  "error": "<error description>"
}
```
