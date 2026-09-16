# Balance check, and versioned subscription amounts

Date: 2026-09-16
Status: design, awaiting review. Revised the same day after a financial review
of the first draft; the six findings and what changed are recorded at the end.

## The brief

> With my current expense habit, how long is the runway?

"Habit" means observed behaviour, including money spent and never logged.
"Current" means recent, not averaged over all history. The app cannot answer
either half today.

Everything here serves that one sentence. Anything that does not is out of
scope.

## What exists today

Read from the code on 2026-09-16.

- `packages/domain/lib/logic/burn_engine.dart:133-137`: `typicalSpending`
  averages **every** completed month in the ledger, and
  `monthlyEstimate = max(budget, typicalSpending)` (line 33) prefers observed
  spending over the budget. Empirical, but over all time.
- `packages/domain/lib/logic/monthly_aggregator.dart:63-73`: `currentCashAsOf`
  is folded from settled transactions only. Its opening balance is the **sum**
  of every `TransactionType.openingBalance` row, so a second one adds rather
  than replaces.
- `packages/domain/lib/logic/burn_engine.dart:74`: `MonthlyBurn.total` is
  `variableBurn + subscriptions + loanPayments`, where `subscriptions` is
  `totalSubscriptionMonthlyCost` (`subscription_engine.dart:6-10`), the flat
  monthly equivalent of every active subscription.
- `packages/data/lib/tables/transactions_table.dart:3-16` has `loanId`, has
  no `subscriptionId`. No code creates a transaction from a subscription.
- `packages/data/lib/tables/subscriptions_table.dart`: `amount` is a single
  mutable value. There is no end date and no amount history.
- `packages/domain/lib/enums/transaction_type.dart`: `investment` is an
  outflow that is deliberately not burn. Money moved to investments leaves the
  spending balance without being spending.

## The defects

**1. Cash never falls for subscriptions.** Burn includes them; the balance does
not. Every month the cash figure the runway divides into floats further above
reality by the subscription total. The runway reads long, and the error
compounds.

The owner does not log subscription payments, on the reasonable assumption that
entering the subscription is enough. That assumption holds for burn and fails
for cash.

**2. A double count waits behind it.** `countsAsLiving`
(`burn_engine.dart:97-98`) is any expense that is not rent; nothing excludes a
subscription. The moment a subscription payment is logged as a transaction it
counts once in living and again in the `subscriptions` line.

**3. "Typical" is an all-time mean.** It answers "what have you ever spent",
not "what do you spend now". A real change in circumstances is diluted by
however long the app has been in use, and reaches the runway months late.

**4. Two ways to state a balance.** Opening balance exists and sums. Adding a
balance check without resolving this gives one fact two mechanisms, one of
which silently double counts.

Defects 1 and 2 follow from one missing rule, which this design establishes:

> **A subscription charge is either a ledger row or a rule in the burn model.
> Never both, never neither.**

Until subscriptions materialise into the ledger (out of scope here), the rule
resolves as: subscriptions live in the burn model, and anything estimating
unlogged spending must exclude them from what it attributes to the unknown.

## Part 1: versioned subscription amounts

### Why

A balance check computes charges accrued over an arbitrary past window. With a
single mutable `amount` that is unanswerable after any price change: a
subscription that went from 20 to 1000 in April reports 1000 for January.

Versioning also gives price history without materialising ledger rows, so
whether subscriptions should generate transactions stays an open choice rather
than being forced by this work.

### Schema 7

On `Subscriptions`:

- **add** `endDate`: nullable `DateTimeColumn`. Null means the current version.
- **add** `seriesId`: a `TextColumn`, stable across the versions of one
  subscription.
- **drop** `isActive`. Active means the current version has no end date.
- **drop** `nextBillingDate`, derived from the current version's start and
  cycle.

Migration for existing rows: `seriesId = id`, `endDate = null` where
`isActive` is true, `endDate = updatedAt` where it is false.

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
  runway should not be charged for months when the subscription did not exist.
- **List**: grouped by `seriesId`, rendered as one subscription. History is
  available, not the default view.

### Consequences elsewhere

- `daysUntilNextBilling` and `computeNextBillingDate` derive from the current
  version. The stored field is gone, so the value can no longer go stale, as it
  does today: nothing advances it after create.
- `totalSubscriptionMonthlyCost` sums versions current *as of a given date*
  rather than those flagged active, so historical burn stops being recomputed
  at today's prices.

## Part 2: the balance check

### What is being reconciled

**The spending account only.** One account, the one day-to-day money moves
through. Named explicitly in the UI, not left to inference.

This matters more than it looks. If savings, a second bank, or cash are folded
into the number, every transfer between them reads as spending: moving 50,000
into savings would appear as 50,000 of unlogged expense and collapse the runway
on paper. Logged investments are already handled, because they are transactions
and therefore part of the expected balance. Unlogged transfers are not, and
cannot be.

Multi-account support is out of scope. The constraint is stated in the UI so
the number is not quietly wrong.

### One balance concept

The balance check **supersedes** opening balance. There is one way to tell the
app what you have.

- `TransactionType.openingBalance` rows become the first balance check.
- The aggregator stops summing opening balances and takes the most recent
  check as the basis, applying transactions after it.
- The UI stops offering "opening balance" as a thing to add.

Migration: existing opening balance rows, summed as today, become a single
check dated to the earliest of them, preserving current behaviour exactly.

### Expected balance

```
expected = the last balance check
         + settled transactions since it
         + subscription charges accrued since it
```

The third term is why Part 1 comes first. Without it the difference would
include subscription spending the app already knows about, attributing known
money to unknown behaviour. The adjustment must capture only spending the app
has no other record of.

"Accrued" means billing dates that have fallen due, priced from the version
covering each date, not the flat monthly equivalent.

### The adjustment, allocated across periods

The difference is written as expense transactions in a reserved `unlogged`
category, **spread across the months since the previous check, pro rata by
days**, not dropped on the day of the check.

This is the correction that matters most. An accrual belongs to the periods it
relates to. Dropping three months of unlogged spending into one month spikes
that month, and since burn averages completed months, the runway would fall
sharply for a reason unrelated to any change in behaviour. Checking quarterly
would produce a sawtooth: two ordinary months and one alarming one.

Pro rata by days is a deliberate simplification: the app cannot know when the
money actually went, and an even spread is the least wrong assumption. It is
stated in the UI so the rows are not mistaken for observations.

A negative difference, meaning more money than expected, is allocated the same
way as income in the same category. Unexplained inflows are as real as
unexplained outflows.

### Rules

- Each check measures the delta since the previous check.
- A difference of zero writes nothing.
- Adjustments are editable and deletable like any transaction. They are a
  measurement, not a verdict.
- No back-dating a check before the most recent one; it would invalidate every
  adjustment since.

### Prompting

Nothing is scheduled. The check is owner-initiated, with a passive dashboard
prompt once more than 30 days have passed since the last one. The value of a
check rises with elapsed time, and iOS background execution cannot be relied
on. The 30 days is a starting number, not a researched one.

## Part 3: a trailing window for typical spending

`typicalSpending` changes from an all-time mean to a **trailing three completed
months**, falling back to however many exist when there are fewer.

Without this, Part 2 makes things worse rather than better: allocated
adjustments would be diluted by every month ever recorded, so the newly
measured truth about spending would take a year to show up. With it, the runway
tracks the last quarter of real behaviour, which is what "current habit" means.

Three months is chosen to smooth a single unusual month without blurring a real
change of circumstances. It is the one number here worth revisiting once there
is real usage.

## Risks, accepted for now

**Lumpy annual charges are a liquidity blind spot.** Amortising a 12,000 annual
renewal at 1,000 a month is right for solvency and wrong for liquidity. Runway
is a liquidity question, and a month carrying a large one-off charge can be
fatal while the smoothed average reports comfort. Landing yearly charges on
their anniversary is deferred, and recorded here as a risk rather than as
tidiness, because it is the failure mode that actually hurts.

**Income has no equivalent discipline.** Everything here tightens the
measurement of spending. Runway is `cash ÷ (burn − inflow)`, and if income is
logged inconsistently every check shows a positive difference that the model
credits but never learns from. A later change should let repeated positive
differences inform `expectedMonthlyInflow` the way adjustments inform burn.
Not in this change, but the asymmetry is deliberate rather than overlooked.

## Out of scope

- **Subscriptions generating ledger rows.** Left open deliberately. Part 1
  makes it a choice rather than a prerequisite.
- **Yearly charges landing on their anniversary.** See risks.
- **Multi-account reconciliation and transfers.** See scope.
- **Categorising the adjustment.** "Unlogged" is the honest label; asking for a
  breakdown invites a guess.
- **Bank connectivity.** The owner reads the number and types it in.

## Testing

Domain logic is pure and takes `now` as a parameter, so all of this is unit
testable without a clock.

- Version lookup: inside a version, on a boundary, inside a gap, after the last
  version.
- Accrued charges across a price change: 20 for three months then 1000, over a
  window spanning the change.
- Expected balance equals last check plus transactions plus accrued charges.
- Allocation: a difference over three months produces one adjustment per month,
  pro rata by days, summing exactly to the difference with no rounding drift.
- A difference over a single day produces one adjustment in that month.
- Negative difference allocates as income, not negative expense.
- Trailing window: four or more completed months use the last three; fewer use
  what exists; no completed months falls back to this month's spending.
- Migration: existing subscriptions land with the right `endDate` and
  `seriesId`; summed opening balances become one check with the balance
  unchanged.
- Regression: a subscription payment logged manually is counted once, not
  twice. This fails today.

## Open questions

1. How often will a check realistically happen? 30 days is assumed and
   unvalidated. If it is closer to "whenever I remember", the prompt matters
   more than the cadence.
2. Is three months the right window, or does one month track the habit better
   at the cost of noise?

## What the financial review changed

The first draft was reviewed against six findings the same day. All are now
folded in:

1. **Period allocation.** The adjustment was dated to the check day, which
   would have spiked one month and distorted an average built from completed
   months. Now spread pro rata across the months it covers.
2. **Trailing window.** `typicalSpending` was left as an all-time mean, which
   contradicts "current habit" and would have diluted the adjustments this
   design exists to produce. Now Part 3.
3. **One balance concept.** Opening balance already existed and already summed.
   The draft added a second mechanism without saying how they relate. The check
   now supersedes it.
4. **Reconciliation scope.** "What the bank says" was unspecified. Now the
   spending account only, stated in the UI, with transfers named as the failure
   mode.
5. **Lumpy annual charges** reclassified from a tidiness improvement to an
   accepted liquidity risk.
6. **Income asymmetry** named, with a direction for later.

Findings 1 and 2 together meant the first draft could have produced a worse
number than doing nothing: a lump-sum adjustment dropped into an all-time mean.
