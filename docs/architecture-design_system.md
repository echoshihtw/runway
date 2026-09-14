# Architecture — `design_system` (Tokens, Theme, Components, l10n)

**Part ID:** `design_system` · **Path:** `packages/design_system` · **Type:** library (Flutter UI)
**Generated:** 2026-08-04 · Deep scan

---

## Executive Summary

`design_system` owns everything visual that is not feature-specific: color/spacing/typography tokens, the semantic color layer (`SC`), the dark `ThemeData`, 15 reusable components, and all app localizations for 6 locales. It depends on Flutter, `google_fonts`, and `intl` — and on **no other project package**, so it sits beside `domain` as a leaf.

Unusually for a design system, it also hosts the generated `AppLocalizations`, which makes it the single import for both look and copy.

## Technology Stack

| Category | Technology | Version |
|---|---|---|
| Fonts | `google_fonts` (JetBrains Mono + Inter) | `^6.2.1` |
| Formatting / l10n | `intl`, `flutter_localizations` | `^0.20.2` |
| Codegen | Flutter `gen-l10n` (`flutter: generate: true`) | — |

## Source Layout

```
packages/design_system/
├── l10n.yaml                     # arb-dir lib/l10n → output lib/generated
├── lib/
│   ├── design_system.dart        # single barrel export
│   ├── tokens/                   # app_colors, app_semantic_colors,
│   │                             # app_spacing, app_text_styles
│   ├── theme/app_theme.dart      # AppTheme.dark
│   ├── components/               # 15 widgets (Neo + legacy Terminal)
│   ├── l10n/*.arb                # 7 arb files, 230 keys each
│   ├── generated/                # AppLocalizations + 6 locale classes
│   └── l10n_extension.dart       # context.l10n
```

## Token System

### Raw palette — `AppColors`

Dark-only. Backgrounds `#040D1A` → `#071229`, surfaces `#060F1E`/`#08172E`, card border `#0D1F3A`.

Brand trio: **Turkish Blue `#5B9DC4`**, **Mint `#8FDDAA`** (`neonGreen`), **Rose Pink `#E8829E`** (`hotPink`), plus **Gold `#CB9A3E`** and **Purple `#BB6DFF`**. Text: `#CDD5E0` primary, `#6B7F96` secondary, `#2A3D5A` dim. Five `LinearGradient`s (green/blue/pink/gold/background).

> The gradient definitions still use the *original, more saturated* neon palette (`#39FF14`, `#FF2D78`) rather than the muted brand trio — a leftover from the earlier "terminal" look.

### Semantic layer — `SC`

**CONTRACTS §4.1: presentation must never use `AppColors.*` directly — always `SC.*`.** `SC` maps meaning → color:

| Group | Members |
|---|---|
| Primary meanings | `life` (mint), `cost` (pink), `subscr` (purple), `chrome` (blue) |
| Numbers | `numberPrimary/Life/Cost/Subscr` |
| Status | `statusStable` (mint), `statusCaution` (gold), `statusCritical` (pink) |
| Section accents | `accentLife`, `accentCost` (gold), `accentSubscription`, `accentNeutral` |
| Transaction icons | `txExpense/Income/Loan/Investment/Repayment/OpeningBalance` |
| Buttons | `btnPrimary`, `btnDestructive`, `btnLoan` |
| Metrics | `metricCash/Runway/Total/BurnRate/Budget/Debt/Subscr/Investable/Safety/RunOut` |
| UI | `labelColor`, `captionColor`, `dividerColor` |

The rule encoded here: color a number only when it belongs to a distinct mental category; everything else stays neutral smoke.

### Spacing — `AppSpacing`

`xxs 2 · xs 4 · sm 8 · md 12 · lg 16 · xl 24 · xxl 32 · xxxl 48`, plus `cardPadding = lg`, `cardRadius = 16`, `cardGap = 12`.

### Typography — `AppTextStyles`

CONTRACTS §4.2 split: **numbers → JetBrains Mono**, **labels/titles → Inter**.

15 styles are declared: `heroLarge`, `hero`, `metric`, `metricSmall`, `label`, `sectionTitle`, `title`, `body`, `bodySmall`, `caption`, `button`, `value`, `small`, `mono`, `danger`.

Key sizes: `heroLarge` 42/w700/-1.0 · `hero` 32/w600 · `metric` 20/w500 · `metricSmall` 15/w400 (mono); `label` 11/w500/+1.0 · `sectionTitle` 12/w600/+1.2 · `title` 17/w600 (Inter). The 11px ALL-CAPS label with 1.0 letter spacing matches CONTRACTS §4.2 exactly.

> **No 72px token exists.** CONTRACTS §4.2 specifies the hero runway number at 72px/bold, but the largest declared style is `heroLarge` at 42 — no style in the file declares a font size above 42. The dashboard's runway number therefore sets its size at the call site rather than from a token.

## Theme

`AppTheme.dark` — `Brightness.dark`, scaffold `AppColors.background`, `ColorScheme.dark(surface, primary: green, secondary: blue, error: red)`, Inter text theme, borderless cards with a 16px radius and `cardBorder` outline, filled inputs on `surfaceHigh` with a 10px radius. There is no light theme; the app is dark-only by design.

## Components

See [component-inventory-design_system.md](./component-inventory-design_system.md).

## Localization

- **Locales (CONTRACTS §6.1):** EN, 繁中 (zh_TW), FR, JA, ES, IT — 7 `.arb` files, since Chinese has both `app_zh.arb` and `app_zh_TW.arb`.
- **230 message keys in every file** — verified: all 7 `.arb` files carry exactly 230 keys, so no locale is missing a string.
- `app_en.arb` is the template.
- Generated into `lib/generated/app_localizations*.dart` by `flutter gen-l10n` (`nullable-getter: false`).
- Access is via `context.l10n` (`l10n_extension.dart`), so screens never import the generated classes directly.

Adding a string (CONTRACTS §6.3–§6.4): add the key to **all 7** `.arb` files, run `make gen-l10n`, never hardcode user-facing strings in Dart, and never put `//` prefixes in ARB values — they are display text.

`make l10n-check` validates that every `.arb` parses as JSON. It does **not** check key-set parity across locales; that check would be a cheap addition.

**Verification note:** all 7 files currently have 230 keys each, so parity holds today.

## Testing Strategy

**No tests exist in this package.** Golden tests for the components and a check that all 7 `.arb` files carry the same key set are the obvious gaps.

## See Also

- [Component Inventory](./component-inventory-design_system.md) · [Presentation Architecture](./architecture-presentation.md) · `CONTRACTS.md` §4
