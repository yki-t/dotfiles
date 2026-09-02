# Figma MCP

## Scope

Guidelines for implementing designs using the official Figma MCP server.

## Context Management

Figma MCP tools can return payloads large enough to flood the context window, so fetch in small pieces:

- For large or unknown-size selections, start with `get_metadata` (sparse XML) to identify `nodeId`s, then fetch only specific nodes with `get_design_context`. For small, known nodes, `get_design_context` directly is acceptable.
- Fetch a page in logical chunks (header, sidebar, card, etc.) rather than whole, selecting the smallest node that covers the need.
- Skip `get_screenshot` when token limits are tight; screenshots are expensive.
- When only design tokens are needed, use `get_variable_defs` instead of `get_design_context`.
- Process section by section instead of fetching everything upfront.

## Tool Cost

`get_design_context` and `get_screenshot` are expensive; `get_metadata` and `get_variable_defs` are cheap. Take tool names and parameters from the server's live tool list; it changes between releases.

## Implementation Workflow

1. For large designs: get page structure with `get_metadata`, identify target `nodeId`s
2. Fetch design context for **specific small sections only** via `get_design_context`
3. Read current implementation (existing code, SCSS, templates, variables)
4. Create comparison table per section:
   - padding, gap, margin
   - width, height
   - border-radius
   - colors (background, text, border)
   - font (family, size, weight, lineHeight)
   - element order
5. Fix by section — delegate to sub-agents per section

## Design File Preparation (for Designers)

- Use Auto Layout (maps to CSS flexbox)
- Set Variables / Design Tokens for colors, spacing, typography
- Use semantic layer names (not "Group 5")
- Add annotations for hover states and responsive behavior

## Code Generation Tips

- Use Code Connect to map Figma components to codebase components
- Extract tokens with `get_variable_defs` and map to project CSS variables/tokens
- Avoid hardcoded values; reference Figma variables
- Default output is React+Tailwind — customize via prompt for other stacks
- Always adapt output to the project's existing stack, components, and conventions

## Notes

- For responsive design, check mobile frames separately
- `get_design_context` output is a reference, not final code — always adapt to project patterns
