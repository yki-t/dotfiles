# Figma MCP

## Scope

Guidelines for implementing designs using Figma MCP.

## Data Retrieval

### 1. Get Page Structure

```
get_figma_data(fileKey, depth=1)
```

Identify the target page/frame `nodeId`.

### 2. Get Detailed Data

```
get_figma_data(fileKey, nodeId="1:305")
```

Omit `depth` to retrieve all hierarchy levels.

### 3. Download Images (Optional)

```
download_figma_images(fileKey, nodes, localPath, pngScale)
```

## Data Structure Reference

### Layout (`globalVars.styles.layout_XXXXX`)

| Property | CSS Equivalent |
|----------|----------------|
| `padding` | `padding` |
| `gap` | `gap` |
| `dimensions.width/height` | `width`, `height` |
| `locationRelativeToParent.x/y` | `margin`, `position` |
| `mode` (`row`, `column`, `none`) | `flex-direction` |
| `alignItems`, `justifyContent` | same |
| `sizing` (`fixed`, `hug`, `fill`) | `width`, `flex` |

### Fills

- Solid: `['#FF7300']`
- Gradient: `[{type: 'GRADIENT_LINEAR', gradient: '...'}]`
- Image: `[{type: 'IMAGE', imageRef: '...'}]`

### Text Style

```yaml
fontFamily: Lexend Deca
fontWeight: 400
fontSize: 40
lineHeight: 1.2em
```

### Strokes

```yaml
colors: ['#FF7300']
strokeWeight: 0px 0px 2px  # top right bottom left
```

## Implementation Workflow

### 1. Extract Figma Data

1. Get page structure with `depth=1`
2. Identify target `nodeId`
3. Retrieve detailed data

### 2. Read Current Implementation

1. SCSS files
2. HTML templates
3. Variable files

### 3. Create Comparison Table

Compare by section:

- padding, gap, margin
- width, height
- border-radius
- colors (background, text, border)
- font (family, size, weight, lineHeight)
- element order (calculate from y-coordinates)

### 4. Calculate Element Order

Derive order from `locationRelativeToParent.y`:

```
y=0   → 1st
y=93  → 2nd
y=215 → 3rd
```

### 5. Fix by Section

Delegate fixes to sub-agents per section.

## Notes

- For responsive design, check mobile frames separately
