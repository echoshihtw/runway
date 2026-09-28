# Runway brand shapes

Transparent SVG primitives extracted from the marketing page's cut-paper shape language. Every path uses `currentColor`; the root `color` attribute only supplies the original marketing colour as a standalone default.

## Assets

- `star-mint.svg` — canonical seven-point app mark, traced from the app icon.
- `star-coral.svg` — expressive twelve-point marketing star.
- `spark-violet.svg` — quieter four-point accent.
- `leaf-mint.svg` — tall asymmetrical organic form.
- `ribbon-yellow.svg` — wide folded separator or background accent.
- `field-violet.svg` — large framing field for screenshots or copy.
- `blob-mint.svg` — soft organic background field.
- `shard-yellow.svg` — angular corner or edge accent.
- `sprite.svg` — all eight primitives as reusable SVG symbols.

## Palette

| Name | Hex |
| --- | --- |
| Midnight | `#08142B` |
| Cream | `#F2EFE7` |
| Mint | `#8FDDAA` |
| Coral | `#F08B72` |
| Violet | `#6327D4` |
| Soft violet | `#A987FF` |
| Yellow | `#F4D84B` |

## Reuse

Inline an individual SVG and control it with CSS:

```html
<svg class="shape"><use href="assets/brand/shapes/sprite.svg#marketing-star" /></svg>
```

```css
.shape {
  width: 6rem;
  color: #f08b72;
  transform: rotate(-14deg);
}
```

Available symbol IDs: `runway-star`, `marketing-star`, `spark`, `leaf`, `ribbon`, `field`, `blob`, and `shard`.

Keep rotation, cropping, and scale irregular: the system should feel cut from paper, not geometrically centred.
