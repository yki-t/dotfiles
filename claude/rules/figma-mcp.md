# Figma MCP

## Scope

Guidelines for implementing designs using the official Figma MCP server.

## Context Management (Critical)

Figma MCP tools can return large payloads that flood the context window. Follow these rules strictly:

- **For large or unknown-size selections**, start with `get_metadata` (sparse XML) to identify `nodeId`s, then fetch only specific nodes with `get_design_context`. For small, known nodes, `get_design_context` directly is acceptable.
- **Never fetch an entire page at once.** Break designs into small logical chunks (header, sidebar, card, etc.).
- **Select the smallest possible node** that covers your needs.
- **Disable `get_screenshot`** when token limits are tight — screenshots consume significant tokens.
- When only design tokens are needed, use `get_variable_defs` instead of `get_design_context`.
- **Process section-by-section sequentially.** Do not fetch everything upfront.

## Available Tools

| Tool | Purpose | Context Cost |
|------|---------|-------------|
| `get_metadata` | Sparse XML overview of layer structure | Low |
| `get_design_context` | Full styled design spec (React+Tailwind by default) | **High** |
| `get_screenshot` | Visual screenshot of selection | **High** |
| `get_variable_defs` | Design tokens (colors, spacing, typography) | Low |
| `get_code_connect_map` | Retrieve component-to-code mappings | Low |
| `add_code_connect_map` | Create component-to-code mapping | Low |
| `get_code_connect_suggestions` | Auto-detect component mapping suggestions | Low |
| `send_code_connect_mappings` | Confirm Code Connect relationships | Low |
| `create_design_system_rules` | Generate design system context rules | Low |
| `get_figjam` | FigJam diagram metadata | Medium |
| `generate_diagram` | Create FigJam diagrams from descriptions | Low |
| `generate_figma_design` | Convert live web UI into Figma design layers (remote only) | N/A |
| `whoami` | Verify authenticated user identity (remote only) | Low |

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
