# Architecture — `domain` (Pure Dart Core)

**Part ID:** `domain` · **Path:** `packages/domain` · **Type:** library (pure Dart, zero Flutter deps)
**Generated:** 2026-08-04 · Deep scan

---

## Executive Summary

`domain` is the innermost layer of Runway's Clean Architecture. It owns the *entire* financial model: entities, value objects, enums, pure calculation engines, and the repository **interfaces** that outer layers must implement. It has exactly one third-party dependency (`fpdart`) and no Flutter dependency — this is what makes the layer boundary compile-time enforceable.

Everything the product promises ("how long can my money last?") is computed here, in `logic/survival_engine.dart`.

## Technology Stack

| Category | Technology | Version | Notes |
|---|---|---|---|
| Language | Dart | `^3.11.5` | Pattern matching / sealed classes used heavily |
| FP utilities | `fpdart` | `^1.1.0` | Declared dependency |
| Test | `test` | `^1.24.0` | 6 test files under `test/` |
| Lints | `lints` | `^6.0.0` | |

**Architecture pattern:** Functional core / imperative shell. Engines are top-level pure functions, not classes — no DI, no state, fully unit-testable.

## Source Layout

```
packages/domain/lib/
├── domain.dart                # barrel — re-exports enums, VOs, entities,
│                              # repositories, logic, failures
├── entities/                  # mutable-shape data holders w/ derived getters
│   ├── budget.dart            # rent + living floor
│   ├── financial_assumptions.dart
│   ├── loan.dart / loan_summary.dart
│   ├── model_state.dart       # ← the computed runway result object
│   ├── monthly_state.dart     # per-month netFlow / balance / grossOutflow
│   ├── runway_goal.dart       # JSON-serializable (prefs-backed, not SQL)
│   ├── subscription.dart
│   └── transaction.dart
├── enums/                     # billing_cycle, expense_category,
│                              # subscription_category, survival_status,
│                              # transaction_type
├── failures/domain_failure.dart   # sealed DomainFailure hierarchy
├── logic/                     # pure calculation engines
│   ├── survival_engine.dart   # computeModel() — the hero calculation
│   ├── monthly_aggregator.dart
│   ├── loan_engine.dart
│   ├── subscription_engine.dart
│   └── runway_goal_progress.dart
├── repositories/              # abstract interfaces only (no impls)
└── value_objects/             # Money, SurvivalMonth
```

## Domain Model

### Value Objects

- **`Money`** — private constructor + factory that rejects NaN, infinite, and **negative** values. Supports `+ - *`, value equality. Sign is carried by `TransactionType`, never by `Money`.
- **`SurvivalMonth`** — a date normalized to the 1st of its month. Provides `next()`, ordering operators, and a `YYYY-MM` `toString()` used as the grouping key in the aggregator.

### Entities

| Entity | Key fields | Derived behavior |
|---|---|---|
| `Transaction` | `id, date, type, amount, note?, loanId?, category?, createdAt, updatedAt` | `month` auto-derived from `date`; `signedAmount` uses `type.isInflow` |
| `Loan` | `originalAmount, monthlyPayment, originalTermMonths, startDate, isActive` | — |
| `LoanSummary` | `loan, totalRepaid, remainingBalance, paidThisMonth` | `repaidRatio`, `isFullyPaid`, `monthsRemaining`, `isAheadThisMonth` |
| `Subscription` | `amount, cycle, startDate, nextBillingDate, category, isActive` | `monthlyEquivalent`, `daysUntilNextBilling` |
| `Budget` | `rent, living` | `subtotal`/`total`, `isSet` |
| `FinancialAssumptions` | `expectedMonthlyInflow?, expectedMonthlyBurnOverride?` | presence guards |
| `MonthlyState` | `month, netFlow, balance, grossOutflow` | — |
| `ModelState` | the full computed runway snapshot | see below |
| `RunwayGoal` | `id, name, targetMonths, targetDate?` | `toJson`/`fromJson` (persisted as JSON, not in SQLite) |

### Enums

- **`TransactionType`** — `expense, income, loan, investment, repayment, openingBalance`. `isInflow` is true for `income`, `loan`, `openingBalance`. `investment` is retained **for backward compatibility with stored data** (see Known Constraints).
- **`ExpenseCategory`** — 9 categories grouped into `LIVING / TRANSPORT / HEALTH / TRAVEL`, with `subcategoriesFor(group)` and `groupHasSubcategories(group)` driving the UI's two-level picker.
- **`BillingCycle`** — `weekly/monthly/quarterly/yearly` with `monthlyEquivalent(amount)` (×52/12, ×1, ÷3, ÷12) and `intervalDays`.
- **`SubscriptionCategory`** — `personal | business`.
- **`SurvivalStatus`** — `stable | caution | critical`.

### Failures

`sealed class DomainFailure` → `InsufficientDataFailure`, `InvalidTransactionFailure`, `StorageFailure`. Sealed, so exhaustive `switch` handling is compiler-checked.

## Calculation Engines

### `survival_engine.dart` — `computeModel(...)`

The hero calculation. Inputs: `months`, `monthlyPayment`, `subscriptionMonthlyCost`, optional `budgetBurnRate`, `expectedMonthlyInflow`, `expectedMonthlyBurnOverride`.

Effective burn is chosen by precedence:

1. `expectedMonthlyBurnOverride` (if > 0), else
2. `budgetBurnRate` (if > 0), else
3. `txBurnRate + subscriptionMonthlyCost + monthlyPayment`

`txBurnRate` is the **mean `grossOutflow` across months that had any outflow** (`_computeBurnRate`).

Projection: `_projectForward` (from known months) or `_projectFromCash` (no history), capped at `_maxProjection = 120` months. If the projection window ends with a positive balance, the remaining runway is extrapolated mathematically — `runwayMonths = knownRunway + (lastBalance / burn).floor()` — so there is no artificial 120-month cap. `runOutDate` is `null` only when burn is zero (in which case `runwayMonths = 9999`, `runwayDays = 99999`).

`pressureRatio = (monthlyPayment + subscriptionMonthlyCost) / txBurnRate` (0 when `txBurnRate` is 0).

### `ModelState` derived metrics

`totalMonthlyOutflow`, `historicalMonthlyBurn`, `emergencyMonthlyBurn`, `fixedObligations`, `fixedPressureRatio`, `flexibilityRatio`, `isOverBudget`, and a **sustainable projection** family (`sustainableNetMonthlyFlow`, `isSustainableIndefinitely`, `sustainableRunwayMonths/Days`) used when the user supplies an expected monthly inflow. `survivalStatus` thresholds: `>= 24 → stable`, `>= 12 → caution`, else `critical`.

### `monthly_aggregator.dart` — `aggregateMonths(transactions)`

Splits out `openingBalance` transactions into a starting balance, buckets the rest by `SurvivalMonth`, and produces a running `balance` per month. `grossOutflow` counts only non-inflow transactions — this is what feeds the burn rate.

### `loan_engine.dart`

`computeLoanSummaries` matches `repayment` transactions to loans via `loanId`; `remainingBalance = originalAmount - totalRepaid` clamped at 0. `totalMonthlyPayment` / `totalMonthlyPaymentFromSummaries` sum only active, not-fully-paid loans. `LoanSummary.monthsRemaining` prefers `originalTermMonths - elapsed` over `balance / payment` (CONTRACTS §3.6).

### `subscription_engine.dart`

Total/by-category/yearly cost over active subscriptions, `sortedByNextBilling`, and `computeNextBillingDate` which rolls a start date forward by cycle until it is in the future.

### `runway_goal_progress.dart`

`runwayMonths / targetMonths` clamped to `[0,1]`; returns `1.0` for the `9999` "indefinite" sentinel. Percent variant rounds.

## Contracts Enforced Here

From `CONTRACTS.md`:

- §2.1 `domain` has **zero Flutter dependencies** — verified: `pubspec.yaml` declares only `fpdart`.
- §2.2 All financial math lives in `domain/lib/logic/`.
- §2.3 All data access is via the interfaces in `repositories/`.
- §3.1–§3.6 burn rate, runway, subscription normalization, and loan term rules are implemented in the engines above.

Also relevant:

- §5.2 opening-balance handling → `monthly_aggregator.dart`.
- §7.1–§7.2 require a test in `packages/domain/test/` for every domain logic change, with `MonthlyAggregator` (empty / opening-only / mixed), `SurvivalEngine` (status thresholds, runway math), and `LoanEngine` (months remaining) edge cases always covered. §7.3: "all 39+ tests must pass before any commit."
- §10 decision log records the rationale behind several behaviors implemented here: no investment in burn rate, `max(actual, budget)`, mathematical runway with no 120-month cap, adaptive 6–18 month safety buffer, monthly subscription normalization.

### Divergences from CONTRACTS

- **§3.3 (Investable / safety fund) is unimplemented.** The contract specifies `safetyMonths = clamp(runwayMonths/2, 6, 18)`, `riskCapacity`, and `investable = max(0, surplus × riskCapacity × pressureFactor)`, with two strictly separated pockets. No corresponding engine exists in `logic/` at scan time — the concept survives only as the retained `TransactionType.investment`, `SC.metricInvestable`/`metricSafety` color tokens, and contract text.
- **§5.3 `investment` treatment diverges.** The contract says investment transactions reduce cash but are *excluded* from the burn rate (§3.4 repeats this). In code, `TransactionType.investment` is simply not an inflow, so `aggregateMonths` folds it into `grossOutflow` — which is exactly what feeds the burn rate. Either the exclusion was never implemented or it was dropped when the type was demoted to backward-compatibility-only.

## Testing Strategy

6 test files under `packages/domain/test/`. Because every engine is a top-level pure function over plain entities, tests need no mocks, no `flutter_test`, and no device. Run with `dart test` or via `melos run test`.

## Known Constraints

- `TransactionType.investment` cannot be removed without a data migration — stored rows reference it.
- `DateTime.now()` is called directly inside `loan_engine`, `subscription_engine`, and `survival_engine` (`_projectFromCash`), so those functions are not time-injectable; tests around month boundaries are inherently date-sensitive.
- `RunwayGoal` is JSON-serialized rather than stored in SQLite (persisted via `shared_preferences` in the application layer).

## See Also

- [Repository Interfaces (API Contracts)](./api-contracts-domain.md)
- [Data Layer Architecture](./architecture-data.md) — implements these interfaces
- [Integration Architecture](./integration-architecture.md)
