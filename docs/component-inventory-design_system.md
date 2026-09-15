# Component Inventory — `design_system`

**Path:** `packages/design_system/lib/components/` · 15 components
**Generated:** 2026-08-04 · Deep scan

All are exported from the single `design_system.dart` barrel.

---

## Two Generations

The package is mid-transition between two visual languages. `design_system.dart` labels this explicitly:

- **Neo** — the current look: gradient backgrounds, glass surfaces, rounded cards.
- **Terminal (legacy)** — the original CRT/terminal aesthetic, marked *"keep during transition"*.

New UI should use Neo components. Terminal components remain because screens still reference them (notably `BootScreen`'s `ScanlineOverlay`).

**CONTRACTS §4.4 makes this binding:** use `NeoButton` not `TerminalButton`, `NeoInput` not `TerminalInput`, and `NeoCard`/`NeoExpandableCard` for all card containers. Pill-shaped buttons use `borderRadius: 50`; cards use `16` (`AppSpacing.cardRadius`).

## Neo Components (current)

| Component | Type | Purpose |
|---|---|---|
| `NeoCard` | Stateless | Standard rounded surface container — the default card |
| `NeoExpandableCard` | Stateful | Card that animates open/closed; used for collapsible panels |
| `NeoButton` | Stateful | Primary button with press animation |
| `NeoInput` | Stateless | Themed text field |
| `MetricTile` | Stateless | Label + number pair — the workhorse for every dashboard metric |
| `PixelBadge` | Stateless | Small status pill (e.g. `STABLE` / `CAUTION` / `CRITICAL`) |
| `PixelBar` | Stateless | Segmented progress/charge bar (goal progress, heart bar) |
| `GradientScaffold` | Stateless | Scaffold wrapper applying `AppColors.gradientBackground` |
| `LiquidGlassContainer` | Stateless | Frosted/blur surface |
| `AppInputFormatters` | Utility | `TextInputFormatter`s for money entry |

## Terminal Components (legacy)

| Component | Type | Purpose |
|---|---|---|
| `TerminalPanel` | Stateless | Bordered panel with a title bar |
| `TerminalButton` | Stateful | Button with terminal-style press feedback |
| `TerminalInput` | Stateless | Terminal-style text field |
| `TerminalDivider` | Stateless | Horizontal rule |
| `ScanlineOverlay` | Stateless (+ `_ScanlinePainter`) | CRT scanline `CustomPainter` overlay |

## Duplication to Note

`app_input_formatters.dart` exists **twice** — in `lib/components/` (the exported one) and in `lib/utils/`. Only the `components/` copy is exported from the barrel; the `utils/` copy is dead or shadowed. Worth consolidating.

## Conventions

- Components consume `SC.*` semantic colors and `AppSpacing`/`AppTextStyles` tokens — never raw hex.
- Components are presentation-only: no Riverpod, no domain imports. Feature-specific composed widgets live in `packages/presentation/lib/features/**/widgets/` instead.
- No component tests or goldens exist at scan time.

## See Also

- [Design System Architecture](./architecture-design_system.md) · [Presentation Component Inventory](./component-inventory-presentation.md)
