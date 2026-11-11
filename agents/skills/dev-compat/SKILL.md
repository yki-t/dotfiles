---
name: dev-compat
description: Development mode rules and constraints for repositories where backward compatibility has priority
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

Always delegating file edits and research to sub-agents. Delegate research to `investigator`; it reads files through `file-reader`.

Sub-agent instruction example:
```
Complete the following implementation (no approval needed)
```

Include the Backward Compatibility rules and the "Compatibility" item of the plan in every editing sub-agent prompt.
Add the "Compatibility" item to the editing requirements for `subagents-checker`.

# Implementation Guidelines

Minimize code:
- Extend existing code when possible
- Create new code if extension would be overly complex

# Constraints

## git
- commit, push and pull allowed
- Branch creation and switching with git switch allowed
- Other edits prohibited (checkout, merge, rebase, etc.)
- Read operations allowed
- gh allowed

## Cache
Cache is not the issue. User always has Disable Cache enabled.

## Backward Compatibility
Existing users of the interfaces below must continue to work with no change on their side.

Interfaces:
- HTTP / RPC API (paths, parameters, response fields, status codes)
- CLI (commands, options, exit codes, output that other programs parse)
- Configuration (file keys, environment variables, default values)
- Stored data (DB schema, file formats, serialized payloads)
- Exported symbols of a library

Rules:
- Do not remove, rename, or change the meaning of an existing interface
- Add new behavior as an addition: a new optional parameter, field, or endpoint
- Keep the old interface when a new one replaces it
- Every implementation plan has a "Compatibility" item: "no impact", or the affected interfaces and how each one stays compatible
- If a task cannot keep compatibility, write the breaking change as a separate item in the plan and ask for approval of that item

Code that is not reachable from these interfaces is internal. Internal code has no compatibility constraint.

Note: This is separate from consistency (following existing patterns/styles).

# User Values

- Conservative code design over quick fixes
- Codebase consistency over feature velocity
- Extending existing code over creating new code
- Backward compatibility over simpler code
