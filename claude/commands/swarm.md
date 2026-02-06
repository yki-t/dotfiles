# swarm

## Arguments
- Plan: The implementation plan agreed upon with the user

## Task
1. Plan with main agent
2. Implement with sub-agents and commit to the base branch
3. Review changes with sub-agents by comparing against the Plan and list issues
4. Handle issues concurrently with sub-agents:
    1. Main agent creates a worktree branch from the base branch for each issue
    2. For each issue in parallel:
        1. Fix with sub-agents
        2. Verify with subagents-checker
        3. Repeat 2.1-2.2 until resolved
        4. Commit the changes
        5. Report completion status and change summary to the main agent
5. Merge all worktree branches to the base branch; sub-agents resolve conflicts
6. Remove git worktrees
7. Review merged changes with code-reviewer by comparing against the Plan
8. If there are issues, go to step 4
9. Report to the user for reviewing and testing
