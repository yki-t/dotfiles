# Sub-agent Workflow

## Scope

This workflow is an exception to the "no code edits beyond agreed scope" rule.
Follow this workflow when using sub-agents that edit code.

## Workflow

### 1. Preparation

Before spawning sub-agents, stage the target files with git add.

```bash
git add <file1> <file2> ...
```

**Prohibited**: Do not use `git add .` or `git add -A`. Specify files explicitly.

### 1.5. Provide Context to Sub-agents

Include the following in sub-agent prompts:
- Purpose of the edit
- Project design patterns
- Related utilities

### 2. Execute Sub-agents

Delegate editing tasks to sub-agents. Multiple sub-agents can run in parallel (see Context Management for limits).

### 3. Verify with subagents-checker

After all sub-agents complete, pass the editing requirements to `subagents-checker`.

```
Example prompt for subagents-checker:

## Editing Requirements
- <requirement 1>
- <requirement 2>
```

Note: `subagents-checker` runs `git diff` itself; main agent doesn't need to.

### 4. Check subagents-checker Output

Verification results:

- **PASS**: Requirements fulfilled. Proceed to STEP 5.
- **FAIL**, **PARTIAL**: Requirements not met. Request fixes from sub-agents. Repeat STEP 2-4.

Proceed to STEP 5 when all PASS.

### 5. Review with code-reviewer

Review all changes with `code-reviewer`.

- **Critical**: Must fix
- **Important**: Must fix
- **Suggestion**: Confirm approach with user

**If Critical/Important issues exist, request fixes from sub-agents.**
Repeat STEP 2-5.

### 6. Completion

At this point, the following are guaranteed:
- [ ] User's editing requirements PASS (STEP 3)
- [ ] Review complete (STEP 5)
- [ ] No Critical/Important issues in review (STEP 5)

If Suggestions exist, report to user.
If no Suggestions, request user review.

## Context Management

### Parallel Limit
- Maximum 3 sub-agents concurrently
- If more tasks exist, batch them

### Output Size
Sub-agents MUST return only:
- Changed file paths
- Commit hash (if committed)
- Brief summary (max 5 lines)

Prohibited:
- Returning full file contents
- Returning full diffs
- Returning large read results

## Notes

- This workflow applies only to editing sub-agents (not research/review sub-agents)
