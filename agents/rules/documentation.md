# Documentation (README / docs)

## Principle

- The code is the single source of truth. A doc never restates what a file in the repository already says.
- A README is a map. It says where information lives (a file, a command) and states only facts that exist nowhere in the repository (host-side prerequisites, external constraints).
- Docs only shrink. When a fact becomes readable from the code, delete it from the doc. Rewrite, do not append.

## Where that content belongs instead

- Reason and history of a change → commit message / PR description
- Work logs and verification results → response body
- Implementation details → the code itself (WHY comments if necessary)

## Writing Style

- Prioritize brevity over completeness. Slightly under-explained is better than over-explained.
- One sentence per fact. Do not restate the same point in different words.
- No preamble, no hedging, no transitional filler.
- Prefer lists and tables over prose paragraphs.
- If a sentence survives deletion without losing the spec, delete it.

## Language

- Japanese: industrial Japanese (産業日本語)
- English: ASD-STE100 Simplified Technical English
