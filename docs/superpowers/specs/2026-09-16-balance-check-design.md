# Balance check, and versioned subscription amounts

Date: 2026-09-16
Status: design, awaiting review

## The brief

> With my current expense habit, how long is the runway?

"Habit" means observed behaviour, including money spent and never logged. The
app cannot answer this today, for two reasons set out below.

Everything here serves that one sentence. Anything that does not is out of
scope.

## What exists today

Read from the code on 2026-09-16.

- `packages/domain/lib/logic/burn_engine.dart:133-137`: `typicalSpending`
  averages completed months from real transactions, and
  `monthlyEstimate = max(budget, typicalSpending)` (line 33) prefers observed
  spending over the budget. The app is already empirical about what it has
  been told.
- `packages/domain/lib/logic/monthly_aggregator.dart:63-73`: `currentCashAsOf`
  is folded from settled transactions only.
- `packages/domain/lib/logic/burn_engine.dart:74`: `MonthlyBurn.total` is
  `variableBurn + subscriptions + loanPayments`, where `subscriptions` is
  `totalSubscriptionMonthlyCost` (`subscription_engine.dart:6-10`), the flat
  monthly equivalent of every active subscription.
- `packages/data/lib/tables/transactions_table.dart:3-16` has `loanId`, has
  no `subscriptionId`. No code creates a transaction from a subscription.
- `packages/data/lib/tables/subscriptions_table.dart`: `amount` is a single
  mutable value. There is no end date and no amount history.

## The two defects

**1. Cash never falls for subscriptions.** Burn includes them; the balance does
not. Every month, the cash figure the runway is divided into floats further
above reality by the subscription total. The runway reads long, and the error
compounds.

The owner does not log subscription payments, on the reasonable assumption that
entering the subscription is enough. That assumption holds for burn and fails
for cash.

**2. A double count waits behind it.** `countsAsLiving`
(`burn_engine.dart:97-98`) is any expense that is not rent; nothing excludes a
subscription. The moment a subscription payment is logged as a transaction, it
counts once in living and again in the `subscriptions` line. Burn inflates,
runway shortens, for no real change in spending.

Both follow from one missing rule, which this design establishes:

> **A subscription charge is either a ledger row or a rule in the burn model.
> Never both, never neither.**

Until subscriptions materialise into the ledger (out of scope here), the rule
resolves as: subscriptions live in the burn model, and anything that estimates
spending must exclude them from what it attributes to unlogged behaviour.

## Part 1: versioned subscription amounts

### Why

A balance check computes charges accrued over an arbitrary past window. With a
single mutable `amount`, that is unanswerable after any price change: a
subscription that went from 20 to 1000 in April reports 1000 for January.

Versioning also gives price history without materialising any ledger rows, so
the separate question of whether subscriptions should generate transactions
stays open rather than being forced by this work.

### Schema 7

On `Subscriptions`:

- **add** `endDate`: nullable `DateTimeColumn`. Null means the current version.
- **add** `seriesId`: a `TextColumn`, stable across the versions of one
  subscription.
- **drop** `isActive`. Active now means the current version has no end date.
- **drop** `nextBillingDate`, which is derived from the current version's start and
  cycle.

Migration for existing rows: `seriesId = id`, `endDate = null` where
`isActive` is true, and `endDate = updatedAt` where it is false.

### Invariants

- Periods are half-open, `[startDate, endDate)`. A new version's `startDate`
  equals the previous version's `endDate`, so exactly one version covers any
  instant, and none covers a cancelled stretch.
- At most one version per `seriesId` has a null `endDate`.
- Versions are appended, never mutated. Correcting a mistyped amount is the one
  exception and edits in place; changing a price appends.

### Operations

- **Change the price**: close the current version at the effective date, append
  a new one. The UI asks for the effective date, defaulting to today.
- **Cancel**: set `endDate` on the current version. No new version.
- **Resume later**: append a version in the same series, with a real gap. The
  gap is truthful: the runway should not be charged for months when the
  subscription did not exist.
- **List**: grouped by `seriesId`, rendered as one subscription. Its history is
  available but not the default view.

### Consequences elsewhere

- `Subscription.daysUntilNextBilling` and `computeNextBillingDate` derive from
  the current version; the stored field is gone, so the value can no longer go
  stale (it is stale today: nothing advances it after create).
- `totalSubscriptionMonthlyCost` sums versions current *as of a given date*
  rather than those flagged active, so historical burn stops being recomputed
  at today's prices.
- A yearly subscription still amortises at `/12`. Landing it on its anniversary
  is a real improvement and is deliberately not in this change.

## Part 2: the balance check

### The flow

1. The owner enters what the bank actually says, with a date.
2. The app computes what it expected on that date.
3. The difference becomes a transaction.

### Expected balance

```
expected = settled transactions up to the date
         + subscription charges accrued up to the date
```

The second term is why Part 1 comes first. Without it, the difference would
include subscription spending the app already knows about, and would attribute
known money to unknown behaviour. The adjustment must capture only spending the
app has no other record of.

"Accrued" means billing dates that have fallen due, priced from the version
covering each date, not the flat monthly equivalent.

### The adjustment

The difference is written as an ordinary expense transaction, dated to the
balance check, in a dedicated category (`unlogged`).

Ordinary, deliberately. `monthly_aggregator.dart` folds it into the balance
with no change, and `burn_engine.dart` folds it into `typicalSpending` with no
change. After two or three checks, the burn rate includes the money that is
never logged, which is the part of the brief nothing else can reach.

A negative difference, meaning more money than expected, is income in the same
category. Unexplained inflows are as real as unexplained outflows, and
silently discarding them would push the runway the wrong way.

### Rules

- Each check measures the delta since the previous check, not since the
  beginning. Two checks in one month produce two adjustments; the second
  measures only what happened after the first.
- An adjustment of zero writes no transaction.
- Adjustments are editable and deletable like any transaction. They are a
  measurement, not a verdict.
- No back-dating before the most recent check. Reconciling an earlier date
  would invalidate every adjustment since.

### Prompting

Version one does not schedule anything. The check is owner-initiated, with a
passive prompt on the dashboard once more than 30 days have passed since the
last one.

Chosen because the value of a check rises with elapsed time, and because
background scheduling on iOS cannot be relied upon. The 30 days is a starting
number, not a researched one.

## Out of scope

- **Subscriptions generating ledger rows.** Left open deliberately. Part 1
  makes it a choice rather than a prerequisite, and until it happens,
  subscriptions stay in the burn model and out of the ledger.
- **Yearly charges landing on their anniversary** instead of amortising.
- **Categorising the adjustment** into real categories. "Unlogged" is the
  honest label; asking for a breakdown invites a guess.
- **Bank connectivity.** The owner reads the number and types it in.

## Testing

Domain logic is pure and takes `now` as a parameter, so all of this is unit
testable without a clock.

- Version lookup: a date inside a version, on a boundary, inside a gap, after
  the last version.
- Accrued charges across a price change: 20 for three months then 1000, over a
  window spanning the change.
- Expected balance excludes nothing it should include, and the adjustment
  equals observed minus expected.
- Negative difference produces income, not a negative expense.
- Second check in the same month measures only the delta.
- Migration: existing active and cancelled subscriptions land with the right
  `endDate` and a `seriesId`.
- Regression: a subscription payment logged manually as a transaction is
  counted once, not twice. This fails today.

## Open questions

1. How often will a balance check realistically happen? 30 days is assumed and
   unvalidated. If it is closer to "whenever I remember", the prompt matters
   more than the cadence.
2. Should the adjustment category be visible in the normal category picker, or
   reserved for the app to write? Reserved is tidier and stops it becoming a
   dumping ground.
