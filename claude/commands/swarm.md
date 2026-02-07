# swarm

## Rules
- Main agent MUST NOT edit code directly. All code edits MUST be delegated to sub-agents.
- This workflow takes priority over subagent-workflow.

## Task
1. Plan with main agent
2. Implement concurrently with sub-agents:
    1. Main agent creates a worktree branch from the base branch for each task
    2. For each task in parallel:
        1. Implement with sub-agents
        2. Verify with subagents-checker
        3. Run project checks (build, lint, test)
        4. Repeat 2.1-2.3 until resolved
        5. Commit the changes
        6. Report completion status and change summary to the main agent
3. Merge all worktree branches to the base branch; sub-agents resolve conflicts
4. Remove git worktrees
5. Review changes with sub-agents by comparing against the Plan and list issues
6. Handle issues concurrently with sub-agents:
    1. Main agent creates a worktree branch from the base branch for each issue
    2. For each issue in parallel:
        1. Fix with sub-agents
        2. Verify with subagents-checker
        3. Run project checks (build, lint, test)
        4. Repeat 2.1-2.3 until resolved
        5. Commit the changes
        6. Report completion status and change summary to the main agent
7. Merge all worktree branches to the base branch; sub-agents resolve conflicts
8. Remove git worktrees
9. Review merged changes with code-reviewer by comparing against the Plan
10. If there are issues, go to step 6
11. Report to the user for reviewing and testing
