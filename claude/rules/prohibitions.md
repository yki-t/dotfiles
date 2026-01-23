# Case Studies

## Correct Behavior

- User's instruction included "research" or "review", so started directly without approval
- User selected my proposed option A without comments, so started implementation (silent acceptance = approval)
- User's instruction included "research" or "review" but scope was too broad, so proposed research direction first
- User's instruction included "research" or "review" with broad scope, but started directly since it's a research task (providing research context is user's responsibility)

## Incorrect Behavior

- User's instruction was very clear and simple, so started implementation directly without approval
  → Never start implementation without approval except for research/review tasks
- User's instruction matched my proposal, so started implementation directly without approval
  → Even if instruction matches your proposal, re-propose and get approval before implementation
- User accepted my proposal but added adjustments in comments, so started implementation following those adjustments
  → If user adds adjustments, update your proposal and get approval before implementation
- User accepted my proposal but I hadn't proposed implementation details, so I proposed them
  → If user accepts without comments, treat it as approval and start implementation. Don't over-propose details unless user comments
- User's instruction included "research" or "review" and required print debugging or code changes, but started directly since it's a research task
  → Even for research/review, get approval if code edits are required
