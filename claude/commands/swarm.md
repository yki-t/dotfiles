# swarm

## Rules
- **Step compliance is the highest priority rule.** Each step MUST be completed before proceeding to the next. Skipping or reordering steps is prohibited.
- Sub-agents MUST report which step they are executing.
- If a sub-agent does not follow the step order, main agent MUST stop and re-delegate.
- Main agent MUST NOT edit code directly. All code edits MUST be delegated to sub-agents.
- Main agent's role is planning and coordination. Detailed work (research, file reading, implementation, review) MUST be delegated to sub-agents.
- Main agent should maintain only high-level understanding. Do not read source files directly.
- This workflow takes priority over subagent-workflow.
- Worktrees should be created at /tmp/

## Project Checks
- Project checks = build, lint, and test commands defined in the project (e.g., Makefile, package.json scripts, CLAUDE.md).
- Sub-agents MUST discover the project's check commands at the start of each worktree task.
- **ALL checks MUST pass.** Partial pass is treated as failure.

## Task
1. Plan with main agent
2. Implement concurrently with sub-agents:
    1. Main agent creates a worktree branch from the base branch for each task
    2. For each task in parallel:
        1. Implement with sub-agents
        2. Verify with subagents-checker → **Gate A: PASS required**
        3. Run project checks (build, lint, test) → **Gate B: ALL checks PASS required**
        4. If Gate A or Gate B fails → return to substep 1. Repeat until all gates pass.
        5. Stage and commit the changes → **Prohibited unless Gate A and Gate B have passed**
        6. Report completion status and change summary to the main agent
3. Merge all worktree branches to the base branch; sub-agents resolve conflicts
4. Remove git worktrees
5. Review changes with sub-agents by comparing against the Plan and list issues
6. Handle issues concurrently with sub-agents:
    1. Main agent creates a worktree branch from the base branch for each issue
    2. For each issue in parallel:
        1. Fix with sub-agents
        2. Verify with subagents-checker → **Gate A: PASS required**
        3. Run project checks (build, lint, test) → **Gate B: ALL checks PASS required**
        4. If Gate A or Gate B fails → return to substep 1. Repeat until all gates pass.
        5. Stage and commit the changes → **Prohibited unless Gate A and Gate B have passed**
        6. Report completion status and change summary to the main agent
7. Merge all worktree branches to the base branch; sub-agents resolve conflicts
8. Remove git worktrees and their branches
9. Review merged changes with code-reviewer by comparing against the Plan
10. If there are issues, go to step 6
11. Report to the user for reviewing and testing
