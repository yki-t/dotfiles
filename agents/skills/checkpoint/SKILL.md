---
name: checkpoint
description: Process an approved list of tasks one at a time, each with a build check, a subagents-checker review gate, and a checkpoint commit, then run a final code-reviewer pass
argument-hint: <approved task list, or reference to it>
---

# checkpoint

Workflow: Sequential Processing → Final Review → Completion Report.

## Precondition

ARGUMENTS (or the preceding conversation) MUST contain a list of tasks the user has already approved, each with an ID, a description, and locations (file:line) where applicable. If no approved list exists, ask the user for one and STOP; do not start implementation.

The working tree MUST be clean before you record the base commit. If there are uncommitted changes, ask the user how to handle them and STOP.

## Rules

- Precision over time and token efficiency: tasks are processed one at a time, because each checkpoint commit keeps the next task's `git diff` limited to that task, and the review gate depends on that.
- Main agent coordinates and verifies; research, code edits, and diff review are delegated to sub-agents. The main agent does not run `git diff`.
- git commit is allowed in this workflow even while /dev is active. Each task is committed as a checkpoint after passing review. Commit messages follow the global rules: one line, conventional commit format, Japanese. push remains prohibited.
- Follows the global subagent-workflow rules for sub-agent context and output limits. subagents-checker runs once per task instead of once per batch; the final code-reviewer pass remains.
- Code quality rules from /dev apply: follow existing patterns, extend existing code, YAGNI/KISS/DRY.

## Phase 1: Sequential Processing

Record the current commit hash as the workflow base before starting.

Process approved tasks **one at a time**, in the order given. For each task:

1. **Delegate implementation.** One task per step. A single task may be delegated to one sub-agent or split across multiple (parallel allowed only within the task; agents in the same step must edit disjoint files). Each prompt MUST include:
   - "Complete the following implementation (no approval needed)"
   - The task's ID, description, and locations if given. If locations are given, state that line numbers are approximations and current code must be read
   - Project context: existing patterns to follow, and helpers/components introduced by earlier tasks that MUST be used
   - The compile/lint command to run before finishing (include required dummy env vars)
   - Output limits: changed file paths and a summary short enough to read at a glance, including the outcome of any judgment calls; no file dumps or diffs
2. **Verify the build.** Main agent runs the combined compile/lint check for all affected crates/packages.
3. **Review gate.** `git add -N` any new files, then spawn `subagents-checker` with the task's requirements. Its `git diff` contains only this task, thanks to the previous checkpoint. Also have it check: existing patterns are followed, no unrelated changes leaked in, no behavior regressions beyond what the task requires. Proceed only on PASS.
4. **Fix loop.** On problems, re-delegate the fix and re-run steps 2-3. On justified deviations from the literal task, record the reasoning instead of forcing a change.
5. **Checkpoint commit.** After the review passes, commit this task's changes (one line, conventional, Japanese; state the task's intent in the message, do not include the task ID). This keeps the next task's `git diff` clean.

Then move to the next task.

## Phase 2: Final Review

- After all tasks are processed, spawn `code-reviewer` over the full change set (`git diff <base>..HEAD`). Provide: a summary of what changed grouped by theme, and priority review angles (correctness of rewritten SQL/queries, transaction/external-service ordering, serialization symmetry, reactive-framework dependency mistakes, ordering broken by parallelization, security of new inputs, regressions in response shapes).
- Critical/Important findings: re-delegate fixes, run the Phase 1 review gate on them, commit, and re-review. Suggestions: report to the user, do not act.

## Completion Report

Lead with the outcome (all N tasks done, review verdict, committed as N checkpoints, not pushed). Then:

1. What was implemented, grouped by theme
2. **Behavior/spec changes the user must know** (API contract changes, error-response changes, new side effects)
3. Justified exceptions (tasks intentionally deviating from the literal description, with reasons)
4. Review Suggestions requiring the user's judgment

Ask the user to review the commits. Fixes the user asks for go through the Phase 1 review gate and checkpoint commit. Run `cc-rein skill end` with Bash after the user accepts the commits.
