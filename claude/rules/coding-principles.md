# Coding Principles

## Comments

Write only non-obvious WHY that cannot be recovered from the code.
Play-by-play narration (like `// Get the user ID`) carries zero information
and only clutters the surrounding code — never write it.

### Write

- Why this implementation was chosen (why alternatives were rejected)
- External constraints, past incidents, origins of the spec
- Reasons for workarounds
- Counterintuitive behavior, easy-to-hit traps

### Do Not Write

- WHAT (anything readable from the code: restating function/variable names, "initialize X" narration)
- Change history ("added X", "the old implementation did Y")
- Task ID references (like `(UZU-XXXX)`)

### Handling Uncertainty

Do not pad comments to compensate for low-confidence code.
Communicate uncertainty explicitly in the PR description or response body ("this part is unverified"), not through comment volume.

## docs / README

- Do not write issue references, background stories, or migration history
- Write only a snapshot of the current spec

## Language

- Japanese: industrial Japanese (産業日本語)
- English: ASD-STE100 Simplified Technical English
