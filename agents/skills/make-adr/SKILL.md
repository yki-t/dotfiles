---
name: make-adr
description: Record an architecture decision as one ADR file
argument-hint: <decision topic>
disable-model-invocation: true
---

# make-adr

## Task

Write one ADR file for the given topic. An ADR records a decision and its reasons. It is not a task list and not a specification.

## Steps

1. If the repository has ADRs (`docs/adr/`, `docs/decisions/`, `adr/`), follow their directory, file name, section layout and language. If not, create `docs/adr/NNNN-<kebab-case>.md` from the template below. NNNN is the largest existing number plus one.
2. Confirm each fact in Context with `investigator` against the code and primary sources (configuration, schema, official documentation). Do not write a fact you cannot confirm. Ask the user instead.
3. Apply the rules below to the draft before you show it. Do not report a violation. Fix it.
4. Create the file with status `Proposed` and show it to the user. Change the status to `Accepted` only when the user says so.
5. When the ADR replaces an older ADR, do not edit the body of the older ADR. Set its status to `Superseded by ADR-NNNN`. Update the index file if one exists.

## Template

```
---
id: "NNNN"
status: Proposed
date: "YYYY-MM-DD"
---
# ADR-NNNN: <the decision in one sentence>

## Context

## Decision

## Consequences

## Alternatives Considered

## References

## Related ADRs
```

## Sections

- Context: the problem, the constraints and the facts that made the decision necessary, written as neutral facts. Write the problem of this repository, not a general statement. Each fact has a source in References. The ADR must be readable on its own.
- Decision: active voice (「〜を採用する」「〜とする」). State the scope. State what this ADR does not decide, and name the document or ADR that decides it.
- Consequences: all positive, negative and neutral effects, including technical debt and trade-offs. At least one negative effect.
- Alternatives Considered: each rejected option and the reason for rejection.
- References: all links to tickets, PRs and external documents.
- Related ADRs: related ADRs and replacement relations.

## Rules

Each rule states what the body must contain or must not contain. Fix the draft until all rules hold.

- The body contains no migration plan, no progress and no task list. Write a requirement of the migration period as a constraint (「移行期間中は旧方式と新方式の両方を読み取れる必要がある」).
- The body contains no implementation detail: method names, type structures, environment variable formats, detection algorithms, test methods, permission assignments to individual targets. Test: if a different implementation of the same decision would require a change to the ADR body, that text belongs in a specification. Remove it.
- The body contains no ticket number, no link and no physical line number. Links go in References.
- A reference to another ADR has the form `ADR-NNNN の Decision 項 N (章題)`.
- The body contains no date other than the frontmatter `date`.
- One term for one thing, in the title, the body and the link texts.
- Status `Accepted` requires that the body contains no open question.
