---
name: issue
description: Clarify and organize GitHub issue requirements, or create new issues
argument-hint: <number or title>
disable-model-invocation: true
---

# issue

## Task
Clarify and organize GitHub issue requirements.

## Arguments
- Number: Fetch and update existing issue
- Non-number: Create new issue using argument as title

## Workflow

### Update existing issue (argument is number)
1. Fetch issue with `gh issue view {number}`
2. Research codebase to understand current behavior and constraints
3. Organize requirements
   - Functional requirements
   - Items requiring decision (present options)
   - Potential issues / Edge cases
4. Confirm decisions with user
5. Draft updated issue body and present to user
6. After approval, update with `gh issue edit`

### Create new issue (argument is non-number)
1. Use argument as title, ask user for necessary information
2. Research codebase to understand current behavior and constraints
3. Organize requirements (same as above)
4. Confirm decisions with user
5. Draft issue body and present to user
6. After approval, create with `gh issue create`

## Output Format
Issue body should include:
- Summary
- Requirements (functional requirements, specifications)
- Acceptance criteria
- Non-functional requirements (if applicable)
- Out of scope (if clarification needed)

## Examples
- `/issue 149` - Fetch and update Issue #149
- `/issue User profile edit feature` - Create new issue
