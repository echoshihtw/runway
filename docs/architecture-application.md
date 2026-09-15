# Architecture — `application` (Riverpod Providers & Use Cases)

**Part ID:** `application` · **Path:** `packages/application` · **Type:** library (Flutter-dependent)
**Generated:** 2026-08-04 · Deep scan

---

## Executive Summary

`application` is the bridge layer. It composes domain engines with persisted state and exposes everything to the UI as Riverpod providers. Per CONTRACTS §2.1 it depends **only on `domain`** — it never imports `data`. The concrete Drift repositories are injected at runtime by overriding placeholder providers in `app/lib/main.dart`.

It also owns the two abstract service ports the app shell implements: `AnalyticsService` and `PurchaseService`.

## Technology Stack

| Category | Technology | Version |
|---|---|---|
| State management | `flutter_riverpod` | `^3.0.3` |
| Codegen annotations | `riverpod_annotation` / `riverpod_generator` | `^3.0.3` |
| Local preferences | `shared_preferences` (dev dep; used at runtime via app) | `^2.2.0` |
| Test | `flutter_test`, `mocktail` | `^1.0.0` |

**Architecture pattern:** Ports-and-adapters. Placeholder `Provider`s that `throw UnimplementedError` are the ports; `main.dart` supplies the adapters via `ProviderScope(overrides: ...)`.

## Source Layout

```
packages/application/lib/
├── application.dart              # barrel
├── feature_flags.dart
├── analytics_service.dart        # port + NoOpAnalytics + analyticsProvider
├── providers/                    # 14 provider files
├── services/purchase_service.dart # port + ProOffering/ProPackage/PurchaseException
├── state/                        # ScenarioState, TransactionState
└── use_cases/                    # 9 CRUD use cases
```

## Dependency Injection Ports

Three providers deliberately throw until overridden in `main.dart`:

| Provider | File | Overridden with |
|---|---|---|
| `transactionRepositoryProvider` | `providers/repository_provider.dart` | `DriftTransactionRepository` |
| `loanRepositoryProvider` | `providers/loan_provider.dart` | `DriftLoanRepository` |
| `subscriptionRepositoryProvider` | `providers/subscription_provider.dart` | `DriftSubscriptionRepository` |
| `purchaseServiceProvider` | `providers/purchase_provider.dart` | `RevenueCatService` |

`analyticsProvider` differs — it *defaults* to `const NoOpAnalytics()` and is overridden with `FirebaseAnalyticsService`, so the app still runs without Firebase.

## Provider Graph

```
transactionsProvider (Stream) ─┐
loansProvider (Stream) ────────┤
  └─ loanSummariesProvider ────┤
  └─ totalMonthlyLoanPaymentProvider ─┐
subscriptionsProvider (Stream) ───────┤
  └─ subscriptionMonthlyTotalProvider ┤
budgetProvider (prefs) ───────────────┼──▶ modelProvider ──▶ ModelState (the runway)
financialAssumptionsProvider (prefs) ─┘         │
                                                ├──▶ projectedMonthsProvider (chart data)
scenarioProvider ──────────────────────────────▶ scenarioModelProvider (what-if)
transactionsProvider + subscriptionsProvider ──▶ thisMonthFlowProvider
```

### `modelProvider` — the core composition

Watches transactions, loan payments, subscription cost, budget, and assumptions, then:

1. `aggregateMonths(transactions)` → monthly balances.
2. `actualBurn` = mean `grossOutflow` over months with outflow.
3. `effectiveVarBurn = max(actualBurn, budget.subtotal)` — **this is CONTRACTS §3.1's "budget is a floor, reality wins"** rule, implemented here rather than in the engine.
4. `totalBurn = effectiveVarBurn + subscriptionCost + monthlyPayment`, passed to `computeModel` as `budgetBurnRate`.

It handles `loading` and `error` states by falling back to a budget-only model rather than an empty one, so the hero number never flickers to zero while the DB stream warms up.

> **Note:** `_computeBurnRate` is duplicated here and in `domain/lib/logic/survival_engine.dart`. The two implementations are currently identical; they can drift.

### `projectedMonthsProvider`

Produces the forward projection used by the dashboard cash chart. Unlike `modelProvider`, when an `expectedMonthlyBurnOverride` is set it uses that value *directly* as the total outflow rather than adding subscriptions and debt on top.

### `scenarioModelProvider`

Active only when `ScenarioState.isActive`. Uses its own local `_computeScenarioModel` — a simplified straight-line `cash / burn` calculation that does **not** call the domain `computeModel` and does not use the 120-month projection. `netBurn = variableBurn + payments + subs − simulatedIncome`.

## Preference-Backed Notifiers

All use `AsyncNotifier` + `SharedPreferences`:

| Provider | Keys | State |
|---|---|---|
| `budgetProvider` | `budget_rent`, `budget_living` | `Budget` |
| `financialAssumptionsProvider` | expected inflow / burn override | `FinancialAssumptions` |
| `runwayGoalProvider` | JSON blob | `RunwayGoal?` |
| `currencyProvider` | `selected_currency` | `CurrencyConfig` |
| `localeProvider` | saved locale | `Locale?` |
| `displayProvider` | display toggle | `bool` |
| `entitlementProvider` | `is_pro` | `EntitlementState` |

**Currency:** six supported (`JPY, TWD, USD, EUR, GBP, CNY`), each carrying symbol/code/intl locale. With no saved preference, `_defaultForLocale` maps the device locale (ja→JPY, zh-TW→TWD, zh→CNY, en→USD, fr/it/es→EUR, else USD).

## Monetization & Entitlements

`EntitlementState` is the single source of truth for feature gating:

| Free | Pro |
|---|---|
| `canAddTransactions`, `canUseBasicRunway`, `canShare`, `canUseBudget`, `canAddFirstLoan`, `canUseOneSim` | `canUseSubscriptions`, `canAddMultipleLoans`, `canUseTimeline`, `canUseUnlimitedSims` |

`EntitlementNotifier.build()` is **offline-first**: read the cached `is_pro` bool, return immediately if true, otherwise try `PurchaseService.checkProEntitlement()` and cache a positive result. Any exception falls back to the cached value — a network failure never revokes Pro.

`FeatureFlags.devProEntitlement` force-enables Pro in non-product builds only, via `--dart-define=DEV_PRO_ENTITLEMENT=true`. It is compiled out of release builds by the `dart.vm.product` guard.

`PurchaseService` is an abstract port with `fetchOffering`, `purchasePackage`, `restorePurchases`, `checkProEntitlement`, plus provider-agnostic `ProOffering` / `ProPackage` / `ProPackageType` / `PurchaseException` types. `ProPackage.nativePackage` is an `Object` — the RevenueCat SDK type is deliberately not leaked into this layer.

> **In flight:** the RevenueCat implementation (`app/lib/revenuecat_service.dart`, `purchases_flutter` v10) is present in the working tree but not yet committed. See [architecture-app.md](./architecture-app.md).

## Use Cases

Nine thin classes, one per mutation, each holding a repository and exposing `execute(...)`:

`Add/Edit/DeleteTransactionUseCase`, `Add/Edit/DeleteLoanUseCase`, `Add/Edit/DeleteSubscriptionUseCase` — each wired to a `*UseCaseProvider`.

Validation lives here. `AddTransactionUseCase.execute` rejects zero amounts and amounts over `1e12`, throwing `InvalidTransactionFailure` (from `domain/failures`). Note these are **thrown**, not returned as an `Either`.

## Analytics

`AnalyticsService` is a 12-method behavioral port (`logScreen`, `logAddTransaction`, `logRunSimulation({hasBurnOverride, hasIncome})`, `logShare`, `logChangeCurrency`, …). Only behavior is tracked — no financial values are passed to any method. `NoOpAnalytics` is the default, used in tests and when Firebase is unavailable.

## Testing Strategy

Tests live in `packages/application/test/use_cases/` and use `mocktail` against the domain repository interfaces. Provider-level tests are sparse — `modelProvider`'s composition logic (the `max(actual, budget)` rule especially) is the highest-value untested surface in this package.

## See Also

- [Domain Architecture](./architecture-domain.md) · [App Shell](./architecture-app.md) · [Integration Architecture](./integration-architecture.md)
