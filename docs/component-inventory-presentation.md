# Component Inventory — `presentation`

**Path:** `packages/presentation/lib/features/` · 8 screens + ~20 public feature widgets
**Generated:** 2026-08-04 · Deep scan

Private widgets (`_Foo`) are implementation details of their file and are listed only where they carry meaningful behavior.

---

## Screens

| Screen | File | Kind | Role |
|---|---|---|---|
| `BootScreen` | `boot/boot_screen.dart` | Stateful | Animated terminal boot sequence; reads `onboarding_done` from prefs, then routes to `/dashboard` or `OnboardingScreen` |
| `OnboardingScreen` | `onboarding/onboarding_screen.dart` | ConsumerStateful | 5 pages: Welcome, Privacy, How It Works, Protect, First Action |
| `DashboardScreen` | `dashboard/dashboard_screen.dart` | Consumer | The hero surface — runway number and all metric cards |
| `TransactionsScreen` | `transactions/transactions_screen.dart` | ConsumerStateful | Month-grouped transaction log with section headers |
| `ScenariosScreen` | `scenarios/scenarios_screen.dart` | Consumer | What-if simulator (burn override + simulated income) |
| `ConfigScreen` | `config/config_screen.dart` | ConsumerStateful | Budget, assumptions, goal, currency, locale — opened as a modal |
| `PaywallScreen` | `paywall/paywall_screen.dart` | ConsumerStateful | Pro upsell; entry point is the top-level `showPaywall(context, trigger:)` |

## Dashboard Widgets

| Widget | File | Notes |
|---|---|---|
| `RunwayCard` | `widgets/runway_card.dart` | The one number. Contains a private `_LiquidGlassCard` with two `CustomPainter`s (`_GlassBodyPainter`, `_GlassRimPainter`) |
| `CashChart` | `widgets/cash_chart.dart` | `fl_chart` line chart over `projectedMonthsProvider` |
| `ThisMonthCard` | `widgets/this_month_card.dart` | Income vs expenses from `thisMonthFlowProvider` |
| `GoalCard` | `widgets/goal_card.dart` | Runway goal progress |
| `HeartBar` | `widgets/heart_bar.dart` | Survival "charge" bar |
| `StatusBadge` | `widgets/status_badge.dart` | STABLE / CAUTION / CRITICAL |
| `SettingsPanel` | `widgets/settings_panel.dart` | Entry to config, share, language |
| `GettingStartedCard` | `widgets/getting_started_card.dart` | Stateful checklist of first-run steps; opens `ConfigScreen` |
| `_DashboardHeader`, `_RunwayBadge` | `dashboard_screen.dart` | Private; `_RunwayBadge` is animated |

## Transactions

| Widget | File | Notes |
|---|---|---|
| `TransactionForm` | `widgets/transaction_form.dart` | Add/edit; private `_InOutToggle`, `_ToggleTile`, `_TypeBadge`, `_LoanLinkRow`, `_DateChip` |
| `TransactionRow` | `widgets/transaction_row.dart` | Single log row |
| `LoanWizard` | `widgets/loan_wizard.dart` | Multi-step loan entry; emits amount, payment, term, date, note |
| `_MonthSectionHeader`, `_MonthItem`, `_TxItem` | `transactions_screen.dart` | Private list-item sealed-ish hierarchy for month grouping |

## Subscriptions & Loans

| Widget | File | Notes |
|---|---|---|
| `SubscriptionsPanel` | `subscriptions/subscriptions_panel.dart` | Totals, next-billing strip, rows; private `_EmptySummary`, `_MetricCell`, `_NextBillingStrip`, `_CountBadge`, `_SubRow` |
| `SubscriptionForm` | `subscriptions/subscription_form.dart` | Name, category, amount, cycle, start date |
| `LiabilitiesPanel` | `loans/liabilities_panel.dart` | Active loan list |
| `LoanCard` | `loans/loan_card.dart` | Per-loan summary: repaid ratio, months remaining |

## Paywall & Shared

| Widget | File | Notes |
|---|---|---|
| `showPaywall(context, {trigger})` | `paywall/paywall_screen.dart` | Top-level function — the single paywall entry point; `trigger` is one of `entry_limit`, `simulation` |
| `ProLockedCard` | `paywall/pro_locked_card.dart` | Locked-feature affordance; taps through to `showPaywall` |
| `allowsNewEntry(context, ref)` | `shared/entry_gate.dart` | The one entry gate; shows the paywall and returns false when a free owner has used five entries |
| `_ActionRow` | `router/app_router.dart` | Rows of the swipe-up blurred action sheet |

## Conventions

- Screens are `ConsumerWidget` / `ConsumerStatefulWidget`; they read providers and never touch repositories.
- Feature-specific widgets stay in `features/<name>/widgets/`. Generic ones belong in `design_system` — see [component-inventory-design_system.md](./component-inventory-design_system.md).
- Strings come from `context.l10n` (`design_system`'s `L10nExtension`).
- **Color usage does not follow CONTRACTS §4.1** — most of these files import `AppColors` directly rather than `SC`. See [architecture-presentation.md](./architecture-presentation.md#contract-compliance).
- No widget tests exist for any component listed here.

## See Also

- [Presentation Architecture](./architecture-presentation.md) · [Design System Components](./component-inventory-design_system.md)
