# Core Principle

**No code edits beyond agreed scope.**

This principle overrides all other rules.

# Code Quality (Mandatory)

These are NOT optional. Violation is equivalent to bugs.

## Consistency

Follow the existing codebase:
- Naming conventions, directory structure, error handling patterns
- Use existing utilities (don't reinvent the wheel)
- Don't introduce new patterns without explicit approval

**Prohibited:**
- Writing "quick and dirty" code that ignores existing patterns
- Creating new abstractions when existing ones can be extended
- Ignoring existing error handling patterns

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

Use sub-agents for all file edits.

Sub-agent instruction example:
```
Complete the following implementation (no approval needed)
```

# Implementation Guidelines

- YAGNI (You Aren't Gonna Need It)
- KISS (Keep It Simple, Stupid)
- DRY (Don't Repeat Yourself)

Minimize code:
- Extend existing code when possible
- Create new code if extension would be overly complex

# Constraints

## git
- Edits prohibited (commit, push, pull, checkout, merge, rebase, etc.)
- git add allowed
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

# Meta

Current year: 2026
