---
name: swarm
description: Coordinated multi-agent parallel implementation workflow with worktrees
disable-model-invocation: true
hooks:
  PreToolUse:
    - matcher: "*"
      hooks:
        - type: command
          command: "~/dotfiles/claude/hook swarm-guard"
---

# swarm

## Rules
- **Step compliance is the highest priority rule.** Each step MUST be completed before proceeding to the next. Skipping or reordering steps is prohibited.
- Sub-agents MUST report which step they are executing.
- If a sub-agent does not follow the step order, main agent MUST stop and re-delegate.
- Main agent MUST NOT edit code directly. All code edits MUST be delegated to sub-agents.
- Main agent's role is planning and coordination. Detailed work (research, file reading, implementation, review) MUST be delegated to sub-agents.
- Main agent should maintain only high-level understanding. Do not read source files directly.
- This workflow takes priority over subagent-workflow.
- Implementation sub-agents MUST be spawned with `isolation: "worktree"` to ensure file isolation. This prevents sub-agents from editing the main working tree.

## Project Checks
- Project checks = build, lint, and test commands defined in the project (e.g., Makefile, package.json scripts, CLAUDE.md).
- Sub-agents MUST discover the project's check commands at the start of each worktree task.
- **ALL checks MUST pass.** Partial pass is treated as failure.

## Task
1. Plan with main agent
    - **Task Splitting Criteria** — A single worktree is acceptable. Splitting is a means, not an end.
      - Split only when **all** of the following conditions are met:
        1. Tasks are independent (different features or responsibilities)
        2. No overlapping files to edit (no conflicts possible)
        3. Splitting improves implementation speed
      - If multiple tasks edit the same file, do not split or serialize them in dependency order
      - Maximum split count is 5, but prefer 1 or 2 when reasonable
2. Implement concurrently with sub-agents (each spawned with `isolation: "worktree"`):
    1. For each task in parallel, spawn a sub-agent with `isolation: "worktree"`:
        1. Implement
        2. Verify with subagents-checker → **Gate A: PASS required**
        3. Run project checks (build, lint, test) → **Gate B: ALL checks PASS required**
        4. If Gate A or Gate B fails → return to substep 1. Repeat until all gates pass.
        5. Stage and commit the changes → **Prohibited unless Gate A and Gate B have passed**
        6. Report worktree branch name and change summary to the main agent
3. Merge all worktree branches (returned from sub-agents) to the base branch; sub-agents resolve conflicts
4. Remove git worktrees and their branches
5. Review changes with sub-agents by comparing against the Plan and list issues
6. Handle issues concurrently with sub-agents (each spawned with `isolation: "worktree"`):
    1. For each issue in parallel, spawn a sub-agent with `isolation: "worktree"`:
        1. Fix
        2. Verify with subagents-checker → **Gate A: PASS required**
        3. Run project checks (build, lint, test) → **Gate B: ALL checks PASS required**
        4. If Gate A or Gate B fails → return to substep 1. Repeat until all gates pass.
        5. Stage and commit the changes → **Prohibited unless Gate A and Gate B have passed**
        6. Report worktree branch name and change summary to the main agent
7. Merge all worktree branches (returned from sub-agents) to the base branch; sub-agents resolve conflicts
8. Remove git worktrees, their branches, and their containers if any exist
9. Review merged changes with code-reviewer by comparing against the Plan
10. If there are issues, go to step 6
11. Report to the user for reviewing and testing
