---
name: dev-lite
description: Development mode rules and constraints without sub-agent delegation, for models with a small context window
disable-model-invocation: true
---

# Core Principle

**No code edits beyond agreed scope.**

This principle overrides all other rules.

# Code Quality

## Consistency

Follow the existing codebase:
- Naming conventions, directory structure, error handling patterns
- Use existing utilities (don't reinvent the wheel)
- Don't introduce new patterns without explicit approval

# Task Classification

| Task Type | Definition | Approval |
|-----------|------------|----------|
| Research | No code edits | Not required |
| Implementation | Code edits | Required |

Implementation workflow:
1. Understand the task (ask questions if unclear)
2. Propose implementation plan
3. Get approval
4. Implement

Do not write code until approval is obtained.

# Request Interpretation

User requests assume the current state of the environment.
Even if a previous attempt failed, re-investigate before concluding.

# Question Guidelines

| Level | When to ask |
|-------|-------------|
| Design-level | Always ask by default |
| Code-level | Only when user requests |

# Work Method

Do all research and file edits yourself.
Do not start sub-agents, including `code-reviewer` and `subagents-checker`. This overrides subagent-workflow.md and delegation.md.

# Exit

When the user ends dev-lite mode, run `cc-rein skill end dev-lite` with Bash.

# Implementation Guidelines

Minimize code:
- Extend existing code when possible
- Create new code if extension would be overly complex

# Constraints

## git
- commit and push allowed
- Branch creation and switching with git switch allowed
- Other edits prohibited (pull, checkout, merge, rebase, etc.)
- Read operations allowed
- gh allowed

## Cache
Cache is not the issue. User always has Disable Cache enabled.

## Backward Compatibility
Only consider backward compatibility when explicitly instructed.
- No fallback implementations
- No maintaining old interfaces

Note: This is separate from consistency (following existing patterns/styles).

# User Values

- Conservative code design over quick fixes
- Codebase consistency over feature velocity
- Extending existing code over creating new code
