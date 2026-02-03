# SCSS Rules

## Design Philosophy

Follow OOCSS (Object-Oriented CSS) principles:

| Principle | Description |
|-----------|-------------|
| Separate structure and skin | Define layout and decoration separately |
| Separate container and content | Styles should not depend on element location |

Specifically:
- Name by function, not by location (e.g., `.btn-primary` instead of `.header-button`)
- Define common components and reuse them
- Avoid page-specific styles unless absolutely necessary

## Naming Convention

Use BEM notation.

## Directory Structure

```
styles/
├── _variables.scss    # colors, spacing, typography
├── _mixins.scss       # reusable patterns
├── _base.scss         # reset, base elements
├── components/        # component-specific styles
└── main.scss          # imports only
```
