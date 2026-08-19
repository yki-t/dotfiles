# Documentation (README / docs)

## Purpose

README and docs contain only a snapshot of the current spec and usage.
The reader is a future user who does not need the history of changes.

## Prohibited in README / docs

- Work logs and change history ("added X", "fixed Y", Before/After)
- Anything recoverable from the code (line-by-line explanations, per-function or per-file descriptions, restated signatures, type definitions, walkthroughs of internal logic)
- Verification logs and test results
- Issue references, task IDs, background stories, migration history
- Sections that grow with each change (rewrite the README, do not append)

## Where that content belongs instead

- Reason and history of a change → commit message / PR description
- Work logs and verification results → response body
- Implementation details → the code itself (WHY comments if necessary)

## Self-check before writing

Does a person who sees this repository for the first time today need this content?
If not, do not write it. If existing README content violates these rules, do not delete it without instruction.

## Writing Style

- Prioritize brevity over completeness. Slightly under-explained is better than over-explained.
- One sentence per fact. Do not restate the same point in different words.
- No preamble, no hedging, no transitional filler.
- Prefer lists and tables over prose paragraphs.
- If a sentence survives deletion without losing the spec, delete it.

## Language

- Japanese: industrial Japanese (産業日本語)
- English: ASD-STE100 Simplified Technical English
