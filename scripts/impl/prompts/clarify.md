# Design Clarification

You are starting an automated implementation workflow.
Your goal is to create a complete design specification that enables autonomous implementation.

## Task

### 1. Research Phase

1. Fetch the issue details using `gh issue view` or `gh api`
2. Thoroughly analyze the codebase:
   - Identify affected components and files
   - Understand existing patterns and conventions
   - Find related implementations for reference
3. Identify all ambiguities and gaps in the issue

### 2. Clarification Phase

Ask the user about ALL of the following (do not skip):

**Functional Requirements**
- Expected inputs and outputs
- User interactions and workflows
- Success criteria

**Boundary Conditions**
- Scope boundaries (what is explicitly included/excluded)
- Edge cases and error scenarios
- Input validation rules

**Design Decisions**
- Integration points with existing code
- Data flow and state management
- Error handling strategy

**Constraints**
- Performance requirements (if any)
- Backward compatibility concerns
- Dependencies on external systems

### 3. Design Specification

After all questions are answered, create a detailed design document:

```markdown
# Design Specification

## Summary
[One paragraph describing the feature/fix]

## Functional Requirements
- [Requirement 1]
- [Requirement 2]
...

## Affected Components
- [File/Module 1]: [What changes]
- [File/Module 2]: [What changes]
...

## Design Decisions
- [Decision 1]: [Rationale]
- [Decision 2]: [Rationale]
...

## Edge Cases & Error Handling
- [Case 1]: [How to handle]
- [Case 2]: [How to handle]
...

## Out of Scope
- [Item 1]
- [Item 2]
...

## Acceptance Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]
...
```

## Guidelines

- Do NOT rush through clarification
- Do NOT assume anything that is not explicitly stated
- Do NOT ask about implementation details (code structure, variable names, etc.)
- Ask questions in batches, not all at once
- Probe deeper if answers are vague

## Output

1. Present the complete design specification to user
2. Get explicit approval: "Is this design complete and correct?"
3. After approval, write to OUTPUT_FILE
4. Confirm: "Design saved. Proceeding with implementation."

## Note

Use Japanese for all communications with the user.
