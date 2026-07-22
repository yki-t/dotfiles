---
name: refine
description: Audit target areas for consistency, performance, error-handling, security, and fault-tolerance issues, then fix approved findings one at a time with a main-agent review gate and a commit checkpoint per finding
disable-model-invocation: true
---

# refine

Workflow: Audit → Report & Approval → Sequential Processing → Final Review.

ARGUMENTS specify the target areas (e.g., "API, CMS"). The perspectives are fixed: **consistency, performance, error handling, security, fault tolerance**.

## Rules

- Precision over time and token efficiency. Findings are processed strictly one at a time; bundling multiple findings into one implementation step is prohibited, no matter how many findings there are.
- Main agent coordinates, verifies, and reviews; research and code edits are delegated to sub-agents. **Exception to the delegation principle: the main agent MUST directly read and review each finding's diff** — this per-finding review gate is the core of this workflow.
- **git commit is allowed in this workflow** (overrides the global git constraint). Each finding is committed as a checkpoint after passing review. Commit messages follow the global rules: one line, conventional commit format, Japanese. push remains prohibited.
- Follows the global subagent-workflow rules for sub-agent context and output limits. The per-finding main-agent review replaces the per-batch subagents-checker; the final code-reviewer pass remains.
- Code quality rules from /dev apply: follow existing patterns, extend existing code, YAGNI/KISS/DRY.

## Phase 1: Audit (research — no approval needed)

1. Identify the repo structure (one quick `ls`/find is enough; do not read source files in the main agent).
2. Spawn read-only research sub-agents in parallel: **one per target area**, plus **one holistic agent** that evaluates the system as a whole. Each prompt MUST include:
   - Area agents: the area's file list or directory scope. Holistic agent: all areas, with instructions to look *between* them, not into each file
   - The perspectives, broken into concrete sub-perspectives:
     - Consistency: pattern divergence between sibling files, DRY violations, unused/dead code, naming
     - Performance: N+1, sequential awaits that can be parallelized, unnecessary clones/allocations, missing indexes, payload size
     - Error handling: swallowed errors (`.ok()`, warn-and-continue), inconsistent propagation policy between similar code paths, error message quality, missing failure branches
     - Security: per-endpoint authorization, injection (SQL/command/pattern escaping), secrets exposure, scope and lifetime of presigned URLs/tokens, input validation at trust boundaries
     - Fault tolerance: partial-failure consistency (transaction boundaries around external services — KVS, S3, external APIs), rollback ordering, idempotency, retries/timeouts
   - Holistic-agent sub-perspectives (in addition to the above, applied across areas): model/contract drift between areas (e.g., server and client redefining the same types), cross-area duplication and shared-crate opportunities, layering/dependency-direction violations, end-to-end call chains a single user operation triggers, build/CI/tooling inconsistencies between areas
   - Required output format per finding: title (1 line) / location as file:line / category / severity High-Medium-Low / 2-4 line description (what is wrong, how to fix)
   - "Report only facts confirmed in code; no low-confidence speculation"
   - "Return only the findings list; no file dumps or diffs"

## Phase 2: Report & Approval (STOP here)

- Assign each finding a stable ID (e.g., A1..An per area, X1..Xn for holistic findings) — later phases reference these IDs. Deduplicate overlaps between area and holistic findings before reporting.
- Report to the user: lead with the few most important findings in prose, then per-area tables (ID / item / location / severity), then a recommended processing order.
- Do NOT start any implementation until the user approves. Approval of "fix all" or a subset defines the agreed scope.

## Phase 3: Sequential Processing

Record the current commit hash as the workflow base before starting.

Process approved findings **one at a time**, in severity order (High → Medium → Low; structural refactors that absorb other findings go first among equals). For each finding:

1. **Delegate implementation.** One finding per step — never combine findings. A single finding may be delegated to one sub-agent or split across multiple (parallel allowed only within the finding; agents in the same step must edit disjoint files). Each prompt MUST include:
   - "Complete the following implementation (no approval needed)"
   - The finding's ID, description, and locations — state that line numbers are approximations and current code must be read
   - Project context: existing patterns to follow, and helpers/components introduced by earlier findings that MUST be used
   - The compile/lint command to run before finishing (include required dummy env vars)
   - Output limits: changed file paths + summary of max 5 lines, including the outcome of any judgment calls; no file dumps or diffs
2. **Verify the build.** Main agent runs the combined compile/lint check for all affected crates/packages.
3. **Review gate.** `git add -N` any new files, then the main agent directly reads `git diff` (which contains only this finding, thanks to the previous checkpoint) and checks: the finding's requirements are met, existing patterns are followed, no unrelated changes leaked in, no behavior regressions beyond what the finding requires.
4. **Fix loop.** On problems, re-delegate the fix and re-run steps 2-3. On justified deviations from the literal finding, record the reasoning instead of forcing a change.
5. **Checkpoint commit.** After the review passes, commit this finding's changes (one line, conventional, Japanese; reference the finding in the message). This keeps the next finding's `git diff` clean.

Then move to the next finding. Do not skip, reorder without reason, or batch to save time.

## Phase 4: Final Review

- After all findings are processed, spawn `code-reviewer` over the full change set (`git diff <base>..HEAD`). Provide: a summary of what changed grouped by theme, and priority review angles (correctness of rewritten SQL/queries, transaction/external-service ordering, serialization symmetry, reactive-framework dependency mistakes, ordering broken by parallelization, security of new inputs, regressions in response shapes).
- Critical/Important findings: re-delegate fixes, run the Phase 3 review gate on them, commit, and re-review. Suggestions: report to the user, do not act.

## Completion Report

Lead with the outcome (all N findings done, review verdict, committed as N checkpoints, not pushed). Then:

1. What was implemented, grouped by theme
2. **Behavior/spec changes the user must know** (API contract changes, error-response changes, new side effects)
3. Justified exceptions (findings intentionally deviating from the literal description, with reasons)
4. Review Suggestions requiring the user's judgment

Ask the user to review the commits.
