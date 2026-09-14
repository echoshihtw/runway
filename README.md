# Runway
### Financial clarity for what matters

> One number matters: your runway.

Runway is a personal financial runway app built for people navigating a defined financial chapter — studying abroad, between jobs, bootstrapping a project, or living off savings. It answers one question at all times: **how long can your money last?**

## Screens

<p align="center">
  <img src="docs/screenshots/dashboard.png" width="30%" alt="Runway dashboard — months remaining, cash, run-out date">
  <img src="docs/screenshots/ledger.png" width="30%" alt="Ledger — income, expenses and opening balance by month">
  <img src="docs/screenshots/subscriptions.png" width="30%" alt="Subscriptions — monthly and yearly totals, per-item cadence">
</p>

Demo data. The runway reads 12 months because 718,760 in cash divided by a
61,289 monthly burn is 11.7 — the number is computed, not mocked.

## Status

**In development.** Runs on Android. iOS distribution is in progress — the
TestFlight path is not working end to end yet.

The release workflows in `.github/workflows/cd.yml` build signed iOS and Android
artefacts on a `v*.*.*` tag, but no tag has been cut, so nothing has been
published to TestFlight or Play. RevenueCat is scaffolded, not wired end to end.

Not yet true, and not claimed anywhere: app-store availability, in-app purchases.

---

## Philosophy

**First principles, not feature bloat.**

The app is not a budgeting tool. It is not a portfolio tracker. It is not an accounting system. It is a survival timer with financial intelligence — designed to give you clarity, not complexity.

Every feature exists to serve one truth: **you have X months**.

---

## Core Concept

```
RUNWAY = currentCash / totalMonthlyBurn

where:
  totalMonthlyBurn = budgetBurnRate + subscriptions + debtPayments
  budgetBurnRate   = max(actualSpending, budgetEstimate)
```

The model uses `max(actual, budget)` — reality always wins when over budget, budget is the floor when under.

---

## Architecture

Clean Architecture + DDD across a Flutter monorepo.

```
packages/
  domain/          Pure Dart — entities, logic, repositories (interfaces)
  data/            Drift + SQLite — repository implementations
  application/     Riverpod providers + use cases
  design_system/   Tokens, theme, components, localizations
  presentation/    Screens + widgets
app/               Entry point, DI wiring
```

**Layer dependency:** `presentation → application → domain ← data`

Separate Dart packages enforce boundaries at compile time.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.41.7 |
| Language | Dart 3.11.5 |
| Monorepo | Melos 7.5.1 |
| Local DB | Drift v2 (SQLite) |
| State | Riverpod 3.x |
| Navigation | go_router 14.x |
| Charts | fl_chart |
| Fonts | Inter (labels) + JetBrains Mono (numbers) |
| Persistence | shared_preferences (settings) |

---

## Domain Models

| Entity | Purpose |
|---|---|
| `Transaction` | Income, expense, loan, investment, repayment, opening balance |
| `Loan` | Loan entity with term, rate, installment tracking |
| `Subscription` | Recurring costs normalized to monthly equivalent |
| `Budget` | Rent + living estimate (floor for burn rate) |
| `ModelState` | Computed survival state — runway, investable, pressure |
| `MonthlyState` | Aggregated per-month cash flow |

---

## Survival Model Logic

```
1. Aggregate transactions by month → MonthlyState[]
2. Compute burn rate from grossOutflow (excludes income + investments)
3. Effective burn = max(actual, budget) + subscriptions + debt
4. Runway = currentCash / effectiveBurn  (mathematical, no cap)
5. Safety buffer = adaptive (runwayMonths/2, clamped 6-18 months)
6. Surplus = currentCash - safetyCash
7. Risk capacity = (runwayMonths - safetyMonths) / safetyMonths
8. Investable = surplus × riskCapacity × pressureFactor
```

**Two pockets:**
- `SAFETY FUND` — locked, never deploy
- `INVESTABLE` — separate pocket, safe to deploy

---

## Color System

Semantic colors defined in `SC` (AppSemanticColors). Never use raw `AppColors` in presentation layer.

| Color | Hex | Meaning |
|---|---|---|
| Mint | `#8FDDAA` | Life / survival — cash, runway, stable |
| Pink | `#E8829E` | Cost / drain — outflow, burn, critical |
| Purple | `#BB6DFF` | Subscriptions only |
| Gold | `#CB9A3E` | Debt / obligation |
| Turkish Blue | `#5B9DC4` | Structure / neutral — UI chrome |
| Smoke | `#CDD5E0` | All other numbers — neutral facts |

**Rule:** Color a number when it represents a distinct mental category, not just positive/negative.

---

## Features

- **Runway dashboard** — hero number, survival charge bar, status
- **Budget engine** — rent + living estimate, max(actual, budget)
- **Loan wizard** — 3-step wizard with amortization calculation
- **Subscription tracker** — weekly/monthly/quarterly/yearly, personal/business
- **Investable calculator** — adaptive safety buffer, two-pocket display
- **Scenario simulator** — what-if burn rate and income overrides
- **Cash timeline** — projected balance chart
- **Multi-language** — EN, 繁中, 简中, FR, JA, ES, IT
- **Multi-currency** — JPY, TWD, USD, EUR, GBP, CNY
- **Planned transactions** — future-dated entries shown as PLANNED

---

## Commands

```bash
make run          # run on connected device
make run-fresh    # db-reset + run
make db-reset     # uninstall app (clears DB)
make gen          # melos run gen (Drift + Riverpod codegen)
make gen-l10n     # flutter gen-l10n in design_system
make test         # dart test in domain
make analyze      # analyze all packages
make precommit    # lint + test
```

---

## CI/CD

| Trigger | Pipeline |
|---|---|
| Push to `main`/`develop` | Quality (analyze + test) + Build iOS + Build Android |
| PR to `main`/`develop` | Quality only |
| Tag `v*.*.*` | Release to TestFlight + Play Store internal track |

---

## Database Schema

SQLite via Drift. Schema version 4.

| Table | Purpose |
|---|---|
| `transactions` | All financial events |
| `loans` | Loan entities with term tracking |
| `subscriptions` | Recurring cost entities |

---

## Tests

39 domain tests covering:
- `MonthlyAggregator` — transaction grouping, balance accumulation
- `SurvivalEngine` — runway calculation, status, investable
- `LoanEngine` — repayment tracking, months remaining
- `Money` value object
- `SurvivalMonth` value object

```bash
cd packages/domain && dart test
```

---

## Bundle ID

`com.silverfern.survivaloptimizer`
