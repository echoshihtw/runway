# Architecture — `domain` (Pure Dart Core)

**Generated:** 2026-08-04 · **Verified against the code:** 2026-09-23
**Generated:** 2026-08-04 · Deep scan

---

## Executive Summary

`domain` is the innermost layer of Runway's Clean Architecture. It owns the *entire* financial model: entities, value objects, enums, pure calculation engines, and the repository **interfaces** that outer layers must implement. It has exactly one third-party dependency (`fpdart`) and no Flutter dependency — this is what makes the layer boundary compile-time enforceable.

Everything the product promises ("how long can my money last?") is computed here, in `logic/burn_engine.dart` (what a month costs) and `logic/runway_engine.dart` (how long the cash covers it).

## Technology Stack

| Category | Technology | Version | Notes |
|---|---|---|---|
| Test | `test` | `^1.24.0` | 12 test files under `test/` |
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
│                              # runway_status, subscription_category,
│                              # transaction_type
├── failures/domain_failure.dart   # sealed DomainFailure hierarchy
├── logic/                     # pure calculation engines
│   ├── burn_engine.dart       # computeMonthlyBurn() — what a month costs
│   ├── runway_engine.dart     # computeModel() — how long the cash covers it
│   ├── monthly_aggregator.dart
│   ├── opening_balance.dart
│   ├── loan_engine.dart
│   ├── subscription_billing.dart   # the billing schedule
│   ├── subscription_charges.dart   # charges due, and what may be written
│   ├── subscription_engine.dart
│   └── runway_goal_progress.dart
├── repositories/              # abstract interfaces only (no impls)
└── value_objects/             # Money, LedgerMonth
```

## Domain Model

### Value Objects

- **`Money`** — private constructor + factory that rejects NaN, infinite, and **negative** values. Supports `+ - *`, value equality. Sign is carried by `TransactionType`, never by `Money`.
- **`LedgerMonth`** — a date normalized to the 1st of its month. Provides `next()`, `monthsSince()`, ordering operators, and a `YYYY-MM` `toString()` used as the grouping key in the aggregator.

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

- **`TransactionType`** — `expense, income, loan, repayment, openingBalance, subscriptionCharge`. `isInflow` is true for `income`, `loan`, `openingBalance`. A stored name this version does not know reads as `expense`, so a database written before a type was removed still loads.
- **`ExpenseCategory`** — 9 categories grouped into `LIVING / TRANSPORT / HEALTH / TRAVEL`, with `subcategoriesFor(group)` and `groupHasSubcategories(group)` driving the UI's two-level picker.
- **`BillingCycle`** — `weekly/monthly/quarterly/yearly` with `monthlyEquivalent(amount)` (×52/12, ×1, ÷3, ÷12) and `intervalDays`.
- **`SubscriptionCategory`** — `personal | business`.
- **`RunwayStatus`** — `stable | caution | critical`.

### Failures

`sealed class DomainFailure` → `InsufficientDataFailure`, `InvalidTransactionFailure`, `StorageFailure`. Sealed, so exhaustive `switch` handling is compiler-checked.

## Calculation Engines

### `burn_engine.dart` — `computeMonthlyBurn(...)`

What a month costs. Inputs: `transactions`, `budget`, `loans`, `subscriptions`, `now`.

Returns a `MonthlyBurn` holding a `rent` and a `living` `BudgetBucket`, plus subscription cost, loan payments, and the share of the month still ahead. Each bucket carries `budget`, `spentThisMonth` and `typicalSpending`.

`typicalSpending` divides completed-month spending by the months **elapsed** since the app first saw this owner spend, not by the months that happen to hold an entry — a quiet month was still lived through. Only spending sets that window: a backdated balance, salary or loan would widen it without adding anything to divide over.

### `runway_engine.dart` — `computeModel(...)`

The hero calculation. Inputs: `currentCash`, a `MonthlyBurn`, optional `expectedMonthlyInflow` and `expectedMonthlyBurnOverride`, and `cashIsKnown`.

Effective burn is `expectedMonthlyBurnOverride` when it is above zero, otherwise the burn total. The rest of this month costs `dueThisMonth` over the days that are left; every later month costs the full monthly burn.

`runwayMonths` and `runwayDays` cap at the `9999` / `99999` "indefinite" sentinels, and `runOutDate` caps with them — `DateTime` wraps rather than refusing a month offset it cannot hold. `runOutDate` is `null` when burn is zero.
### `ModelState` derived metrics

`totalMonthlyOutflow`, `emergencyMonthlyBurn`, `runwayIsKnown`, and a **sustainable projection** family (`sustainableNetMonthlyFlow`, `hasSustainableProjection`, `isSustainableIndefinitely`, `sustainableMonthlyShortfall`) used when the owner supplies an expected monthly inflow.

### `monthly_aggregator.dart` — `aggregateMonths(transactions)`

Splits out `openingBalance` transactions into a starting balance, buckets the rest by `LedgerMonth`, and produces a running `balance` per month. `grossOutflow` counts only non-inflow transactions.

### `loan_engine.dart`

`computeLoanSummaries` matches `repayment` transactions to loans via `loanId`; `remainingBalance = originalAmount - totalRepaid` clamped at 0. `totalMonthlyPayment` / `totalMonthlyPaymentFromSummaries` sum only active, not-fully-paid loans. `LoanSummary.monthsRemaining` prefers `originalTermMonths - elapsed` over `balance / payment` (CONTRACTS §3.6).

### `subscription_billing.dart`

One schedule for every cycle: `billingDateAt(start, cycle, periods)` counts periods from the start date, so a day clamped into a short month comes back in the next long one. `billingDatesUpTo` / `billingDatesInRange` / `nextBillingDateAfter` / `daysUntilNextBilling` all read from it. `subscriptionChargeId` derives a charge's id from its subscription and date, which is how a confirmed charge is recognised without a column linking the two.

### `subscription_engine.dart`

Total/by-category/yearly cost over active subscriptions, and `sortedByNextBilling`, which orders by the derived date rather than the stored `nextBillingDate`.

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
- §7.1–§7.2 require a test in `packages/domain/test/` for every domain logic change, covering the aggregator (empty / opening-only / mixed), the runway math, and loan months-remaining.
- §10 decision log records the rationale behind several behaviors implemented here: `max(actual, budget)`, mathematical runway with no projection-window cap, adaptive 6–18 month safety buffer, monthly subscription normalization.

## Testing Strategy

12 test files under `packages/domain/test/`. Because every engine is a top-level pure function over plain entities, tests need no mocks, no `flutter_test`, and no device. Run with `dart test` or via `melos run test`.

CI pins `TZ=Europe/Paris` for this suite. A billing date is a calendar day, and arithmetic that gets that wrong by an hour is invisible in UTC.

## Known Constraints

- `DateTime.now()` is still called directly inside `loan_engine`, `monthly_aggregator` and `LoanSummary`, so those are not time-injectable; tests around month boundaries are date-sensitive. The subscription and runway engines take `now` as a parameter.
- `Money`'s `+ - *` operators build through the private constructor, so they bypass the factory's non-negative guard (#92).
- `subscription_billing.dart` carries `legacyBillingDates`, which reconstructs the pre-#244 schedule so a charge confirmed under an old id is still recognised. It comes out when #245 migrates the stored ids.
- `RunwayGoal` is JSON-serialized rather than stored in SQLite (persisted via `shared_preferences` in the application layer).

## See Also

- [Repository Interfaces (API Contracts)](./api-contracts-domain.md)
- [Data Layer Architecture](./architecture-data.md) — implements these interfaces
- [Integration Architecture](./integration-architecture.md)
