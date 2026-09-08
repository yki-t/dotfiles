---
name: swarm
description: Coordinated multi-agent parallel implementation workflow with worktrees
disable-model-invocation: true
hooks:
  PreToolUse:
    - matcher: "*"
      hooks:
        - type: command
          command: "~/.cargo/bin/cc-rein hook"
---

# swarm

## Rules
- Complete each step before starting the next; the merge protocol below depends on the order. Sub-agents report the step they are executing, and a sub-agent that departs from the step order is stopped and re-delegated.
- The main agent plans, coordinates, and merges. Research, file reading, implementation, and review are delegated to sub-agents so the main agent's context stays small enough for the whole workflow; the main agent does not edit code or read source files directly.
- This workflow replaces the subagent-workflow rules while it runs.
- Implementation sub-agents run with `isolation: "worktree"`, which keeps their edits out of the main working tree. Inside a worktree a sub-agent may run `git add` and `git commit`, and the main agent runs `git merge` to integrate worktree branches, even while /dev is active.
- Work that has not passed both gates is never merged: discard the worktree and re-delegate, or instruct the sub-agent to fix it.

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
3. Merge worktree branches to the base branch one at a time. For each branch:
    1. Verify mergeability against HEAD with `git merge-tree --write-tree HEAD <worktree-branch>`
    2. Instruct the sub-agent to rebase the worktree branch onto HEAD in their worktree. If step 1 detected conflicts, the sub-agent must resolve them during the rebase.
    3. Merge with `git merge --ff-only <worktree-branch>` to ensure linear history with no merge commits
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
7. Merge worktree branches to the base branch one at a time. For each branch:
    1. Verify mergeability against HEAD with `git merge-tree --write-tree HEAD <worktree-branch>`
    2. Instruct the sub-agent to rebase the worktree branch onto HEAD in their worktree. If step 1 detected conflicts, the sub-agent must resolve them during the rebase.
    3. Merge with `git merge --ff-only <worktree-branch>` to ensure linear history with no merge commits
8. Remove git worktrees, their branches, and their containers if any exist
9. Review merged changes with code-reviewer by comparing against the Plan
10. If there are issues, go to step 6
11. Report to the user for reviewing and testing
