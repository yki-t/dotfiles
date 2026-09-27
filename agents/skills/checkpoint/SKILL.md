---
name: checkpoint
description: Process an approved list of findings one at a time, each with a build check, a main-agent diff review gate, and a checkpoint commit, then run a final code-reviewer pass
argument-hint: <approved findings list, or reference to it>
---

# checkpoint

Workflow: Sequential Processing → Final Review → Completion Report.

## Precondition

ARGUMENTS (or the preceding conversation) MUST contain a list of findings the user has already approved, each with an ID, a description, and locations (file:line). If no approved list exists, ask the user for one and STOP; do not start implementation.

The working tree MUST be clean before you record the base commit. If there are uncommitted changes, ask the user how to handle them and STOP.

## Rules

- Precision over time and token efficiency: findings are processed one at a time, because each checkpoint commit keeps the next finding's `git diff` limited to that finding, and the review gate depends on that.
- Main agent coordinates, verifies, and reviews; research and code edits are delegated to sub-agents. **Exception to the delegation principle: the main agent MUST directly read and review each finding's diff** — this per-finding review gate is the core of this workflow.
- git commit is allowed in this workflow even while /dev is active. Each finding is committed as a checkpoint after passing review. Commit messages follow the global rules: one line, conventional commit format, Japanese. push remains prohibited.
- Follows the global subagent-workflow rules for sub-agent context and output limits. The per-finding main-agent review replaces the per-batch subagents-checker; the final code-reviewer pass remains.
- Code quality rules from /dev apply: follow existing patterns, extend existing code, YAGNI/KISS/DRY.

## Phase 1: Sequential Processing

Record the current commit hash as the workflow base before starting.

Process approved findings **one at a time**, in the order given. For each finding:

1. **Delegate implementation.** One finding per step. A single finding may be delegated to one sub-agent or split across multiple (parallel allowed only within the finding; agents in the same step must edit disjoint files). Each prompt MUST include:
   - "Complete the following implementation (no approval needed)"
   - The finding's ID, description, and locations — state that line numbers are approximations and current code must be read
   - Project context: existing patterns to follow, and helpers/components introduced by earlier findings that MUST be used
   - The compile/lint command to run before finishing (include required dummy env vars)
   - Output limits: changed file paths and a summary short enough to read at a glance, including the outcome of any judgment calls; no file dumps or diffs
2. **Verify the build.** Main agent runs the combined compile/lint check for all affected crates/packages.
3. **Review gate.** `git add -N` any new files, then the main agent directly reads `git diff` (which contains only this finding, thanks to the previous checkpoint) and checks: the finding's requirements are met, existing patterns are followed, no unrelated changes leaked in, no behavior regressions beyond what the finding requires.
4. **Fix loop.** On problems, re-delegate the fix and re-run steps 2-3. On justified deviations from the literal finding, record the reasoning instead of forcing a change.
5. **Checkpoint commit.** After the review passes, commit this finding's changes (one line, conventional, Japanese; reference the finding in the message). This keeps the next finding's `git diff` clean.

Then move to the next finding.

## Phase 2: Final Review

- After all findings are processed, spawn `code-reviewer` over the full change set (`git diff <base>..HEAD`). Provide: a summary of what changed grouped by theme, and priority review angles (correctness of rewritten SQL/queries, transaction/external-service ordering, serialization symmetry, reactive-framework dependency mistakes, ordering broken by parallelization, security of new inputs, regressions in response shapes).
- Critical/Important findings: re-delegate fixes, run the Phase 1 review gate on them, commit, and re-review. Suggestions: report to the user, do not act.

## Completion Report

Lead with the outcome (all N findings done, review verdict, committed as N checkpoints, not pushed). Then:

1. What was implemented, grouped by theme
2. **Behavior/spec changes the user must know** (API contract changes, error-response changes, new side effects)
3. Justified exceptions (findings intentionally deviating from the literal description, with reasons)
4. Review Suggestions requiring the user's judgment

Ask the user to review the commits.
