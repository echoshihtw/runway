# Architecture — `presentation` (Screens & Widgets)

**Part ID:** `presentation` · **Path:** `packages/presentation` · **Type:** library (Flutter UI)
**Generated:** 2026-08-04 · Deep scan

---

## Executive Summary

`presentation` is the outermost UI layer: feature screens, their widgets, and the GoRouter configuration. It depends on `application`, `design_system`, and `domain` — and **never on `data`** (CONTRACTS §2.1). All reads come from Riverpod providers; all writes go through use-case providers. It contains no financial math (CONTRACTS §2.2) except for display formatting.

## Technology Stack

| Category | Technology | Version | Purpose |
|---|---|---|---|
| Routing | `go_router` | `^14.6.1` | `StatefulShellRoute` 3-branch nav |
| Charts | `fl_chart` | `^0.68.0` | Cash projection chart |
| Formatting | `intl` | `^0.20.2` | Currency / date formatting |
| IDs | `uuid` | `^4.0.0` | Client-side entity ids |
| Sharing | `share_plus` | `^12.0.2` | Share runway card |
| State | `flutter_riverpod` | `^3.0.3` | `ConsumerWidget` / `ConsumerStatefulWidget` |

**Architecture pattern:** Feature-first folders, each screen a `Consumer*` widget reading providers. Composed feature widgets live beside their screen; only generic widgets are promoted to `design_system`.

## Source Layout

```
packages/presentation/lib/
├── router/app_router.dart          # GoRouter + shell scaffold + global action sheet
├── shared/speed_dial_fab.dart
└── features/
    ├── boot/boot_screen.dart
    ├── onboarding/onboarding_screen.dart
    ├── dashboard/dashboard_screen.dart
    │   └── widgets/  runway_card, cash_chart, this_month_card, goal_card,
    │                 heart_bar, status_badge, settings_panel, getting_started_card
    ├── transactions/transactions_screen.dart
    │   └── widgets/  transaction_form, transaction_row, loan_wizard
    ├── scenarios/scenarios_screen.dart
    ├── subscriptions/  subscriptions_panel, subscription_form
    ├── loans/  liabilities_panel, loan_card
    ├── config/config_screen.dart
    └── paywall/  paywall_screen (+ showPaywall), pro_locked_card
```

## Navigation

`appRouter` (`router/app_router.dart`) — `initialLocation: '/boot'`.

```
/boot  ──▶ (onboarding_done?) ──▶ /dashboard
              └── no ──▶ OnboardingScreen (imperative MaterialPageRoute)

StatefulShellRoute.indexedStack
 ├── /dashboard
 ├── /transactions
 └── /scenarios
```

Only four routes are declared. `ConfigScreen`, `OnboardingScreen`, and `PaywallScreen` are pushed imperatively (modal sheets / `MaterialPageRoute` / `showPaywall`) rather than being addressable routes — so they have no deep links.

### Shell interactions (`_ScaffoldWithNav`)

- **Horizontal swipe** switches branches. Threshold is platform-aware: **800 px/s on Android** (to avoid colliding with the system back gesture) vs 500 on iOS.
- **Upward swipe** in a 64px zone above the safe area opens a blurred action sheet with three entries: `ENTRY` (transaction), `LOAN` (wizard), `SUBSCRIPTIONS`.
- **Page indicator dots** animate the active branch (18px wide when active).
- `hudNavKey` / `logNavKey` / `simNavKey` are `GlobalKey`s reserved for a coach-mark tour.

## Data Flow

```
Provider (application) ──▶ ConsumerWidget rebuilds ──▶ format & display
User action ──▶ ref.read(xUseCaseProvider).execute(entity) ──▶ repository ──▶ Drift
             └─ Drift watch() stream emits ──▶ providers recompute ──▶ UI updates
```

Entity construction (including `Uuid().v4()` ids and `createdAt/updatedAt`) happens at the call site in the router/forms, not in the use cases.

**Loan creation is a two-write operation:** `LoanWizard` submits create a `Loan` *and* a paired `TransactionType.loan` transaction sharing the same `loanId`. These are two separate `execute` calls with no transaction wrapper — a failure between them leaves a loan with no corresponding cash inflow.

## Entitlement Gating

Gating is checked inline in the UI, not centrally:

| Trigger | Where | Rule |
|---|---|---|
| `loan_limit` | `app_router.dart`, `transactions_screen.dart` | Free users may add one loan; a second opens the paywall |
| `subscriptions` | `app_router.dart`, `transactions_screen.dart` | Subscriptions are Pro-only |
| `simulation` | `scenarios_screen.dart` | Repeat simulations are Pro-only |

Each site reads `FeatureFlags.devProEntitlement || entitlementProvider.value?.isPro` and calls `showPaywall(context, trigger: ...)`. `ProLockedCard` is the reusable "locked" affordance.

> The `EntitlementState` getters (`canUseSubscriptions`, `canAddMultipleLoans`, …) exist in the application layer but the UI mostly checks raw `isPro` instead. Routing all gates through those getters would put the policy in one place.

## Contract Compliance

**CONTRACTS §4.1 says presentation must never use raw `AppColors.*` — only semantic `SC.*`.** At scan time this is widely violated: **287 `AppColors.` references vs 38 `SC.` references**, spanning 20 of the feature files including `app_router.dart` itself. This is the largest single deviation from the stated contracts and a good candidate for a mechanical cleanup pass.

CONTRACTS §2.2 (no math in presentation) holds — screens read `ModelState` and `LoanSummary` and only format them.

**§4.4 component rules** — new UI must use `NeoButton`/`NeoInput`/`NeoCard`/`NeoExpandableCard` rather than their `Terminal*` predecessors; pill buttons at `borderRadius: 50`, cards at `16`. `BootScreen` still uses `ScanlineOverlay`, which is expected — it is the deliberate retro boot sequence.

**§4.3 layout rules** — runway is always the largest element, center-top; cards expandable with key metrics visible and details collapsed; a thin left accent bar carries section identity; **no more than 3 accent colors visible at once**.

**§4.5 navigation** — three tabs only: **HUD** (dashboard), **LOG** (transactions), **SIM** (scenarios). The router's three `StatefulShellBranch`es match this exactly; adding a fourth top-level tab requires explicit justification.

**§6.3 localization** — never hardcode user-facing strings in Dart. Note that `app_router.dart`'s action sheet uses literal `'ENTRY'` / `'LOAN'` / `'SUBSCRIPTIONS'` labels rather than `context.l10n` keys.

## Testing Strategy

**No tests exist in this package.** Widget tests for `RunwayCard`, `TransactionForm` validation, and the entitlement gates are the highest-value additions. End-to-end coverage currently lives in `app/integration_test/`.

## See Also

- [Component Inventory](./component-inventory-presentation.md) · [Application Architecture](./architecture-application.md) · [Design System](./architecture-design_system.md)
