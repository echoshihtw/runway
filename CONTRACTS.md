# AWARENESS — Development Contracts

> These contracts define the rules, decisions, and constraints that govern development. Every contributor (human or AI) must read and follow these before making changes.

---

## 1. Product Contract

### 1.1 Purpose
Runway is a **personal financial runway tool**, not a budgeting app, not a portfolio tracker. Every feature must answer: *does this help the user know how long their money can last?*

### 1.2 The One Number
Runway is the hero metric. It is always the largest, most prominent number on screen. Nothing competes with it.

### 1.3 First Principles Rule
Before adding a feature, ask:
1. Does this serve the survival question?
2. Can the user understand it without a tutorial?
3. Does it add data or add noise?

If the answer to (1) is no, don't build it. If (2) is no, redesign it. If (3) is noise, cut it.

### 1.4 Simplicity Contract
> "If it needs a manual, it's not intuitive enough."

UX decisions must favor clarity over completeness. One rough number the user understands beats a precise number they have to think about.

---

## 2. Architecture Contracts

### 2.1 Layer Boundaries
```
presentation → application → domain ← data
```
- `domain` has zero Flutter dependencies
- `data` only knows about `domain` interfaces
- `presentation` never imports `data` directly
- `application` providers are the only bridge

Violations will break compile-time enforcement.

### 2.2 No Business Logic in Presentation
All financial calculations live in `domain/lib/logic/`. Presentation only formats and displays. If you find yourself doing math in a widget, move it to the domain.

### 2.3 Repository Pattern
All data access goes through repository interfaces defined in `domain`. No direct database calls from application or presentation layers.

### 2.4 Codegen
Run `make gen` after any change to:
- Drift table definitions
- Riverpod providers with `@riverpod` annotation

Never commit stale `.g.dart` files.

---

## 3. Domain Contracts

### 3.1 Burn Rate Formula
```dart
monthlyBurn = max(rentBudget, typicalRent)
            + max(livingBudget, typicalLiving)
            + subscriptions + loanPayments
```
- Expenses with the RENT category count as rent. Every other expense, including uncategorized ones, counts as living.
- A logged expense uses up its budget and never adds on top of it. Burn only rises when a bucket goes over budget.
- `typicalRent` and `typicalLiving` = average logged spending per completed month in that bucket, or this month's spending when there is no earlier month.
- Loan repayments count only against their loan's scheduled payment. Income, loans received, investments and opening balances are not burn.
- An expected burn override in Forecast replaces `monthlyBurn`.

### 3.2 Runway Calculation
Runway is measured in months from today.
```dart
dueThisMonth = rentLeft + livingLeft
             + subscriptions * fractionOfMonthLeft
             + loan payments not yet logged this month
runwayMonths = floor(fractionOfMonthLeft + (cash - dueThisMonth) / monthlyBurn)
```
- Cash counts only entries dated today or earlier. An entry dated later is a plan: the log shows it, and it does not move cash or the runway until its date arrives.
- `fractionOfMonthLeft` counts today, so it is 1.0 on the first day of the month.
- If cash does not cover `dueThisMonth`, cash runs out this month.
- `runOutDate` is the month cash reaches zero. It is null only when burn is zero.
- No arbitrary cap. 9999 means unlimited.
- The dashboard and the simulator share this calculation. A simulation starts from the real `dueThisMonth` and applies only the difference over the days left, so a scenario with no changes returns the dashboard's runway.

### 3.3 Cash Reserve — not implemented in 1.0.1

A reserve is cash the user has decided not to count as runway. It is a number
they set, not one the app derives.

```dart
reserve    = user-set amount, default 0
runwayCash = max(currentCash - reserve, 0)   // runway is measured on this
```
- With a reserve set, the runway answers how long the money the user is willing to spend lasts.
- The amount above the reserve is stated as a fact. What to do with it is the user's decision, and the app does not advise.
- A reserve of 0, the default, leaves every number exactly as it is today.

The earlier `investable` formula (`safetyMonths`, `riskCapacity`, `pressureFactor`, and the SAFETY FUND / INVESTABLE pockets) is dropped, not deferred. It sized how much to put at risk from inputs the app does not hold — income stability, dependents, debt rates, insurance, time horizon — and sizing an investment is advice, not measurement. Runway states a position.

### 3.4 Investment Transactions
Investment transactions reduce cash balance but are excluded from burn rate calculation. They are not expenses.

### 3.5 Subscription Normalization
All billing cycles normalize to monthly equivalent:
- Weekly: `amount × 52 / 12`
- Monthly: `amount`
- Quarterly: `amount / 3`
- Yearly: `amount / 12`

### 3.6 Loan Months Remaining
Uses `originalTermMonths - elapsed` — not `remainingBalance / monthlyPayment`. This ensures interest-bearing loans show accurate remaining term.

---

## 4. UI/UX Contracts

### 4.1 Color System
**Never use raw `AppColors.*` in presentation layer. Always use `SC.*` (semantic colors).**

| Semantic | Color | Used For |
|---|---|---|
| `SC.life` / Mint | `#8FDDAA` | Cash, runway, stable status, survival charge |
| `SC.cost` / Pink | `#E8829E` | Total outflow, burn, critical status |
| `SC.subscr` / Purple | `#BB6DFF` | Subscriptions ONLY |
| `SC.chrome` / Gold | `#CB9A3E` | Debt, loan obligations |
| Amber | `#FFC978` | Caution runway status only |
| Turkish Blue | `#5B9DC4` | UI structure, neutral |
| Smoke | `#CDD5E0` | All other numbers — neutral facts |

**Rule:** Color = semantic meaning, not decoration. Color a number only when it represents a distinct mental category.

Status follows months of cover: under 3 critical, 3 to 6 caution, above 6 stable. Three to six months is the widely used adequacy range, so the app does not call a long runway an emergency.

The runway number carries its status colour: mint when stable, amber when caution, pink when critical. Caution is amber, not gold, because the runway card sits directly above the gold liabilities card.

### 4.2 Typography Hierarchy
- **Numbers/values** → JetBrains Mono (gaming soul)
- **Labels/titles** → Inter (clean, modern)
- **Hero number** (runway) → 72px, bold
- **Metric numbers** → 20px
- **Labels** → 11px, ALL CAPS, 1.0 letter spacing

### 4.3 Layout Rules
- Runway is always the hero — largest, most prominent, center-top
- Cards are expandable — key metrics always visible, details collapsed
- Section accent bar color = section identity (thin left bar)
- No more than 3 accent colors visible at once on screen

### 4.4 Component Rules
- Use `NeoButton` not `TerminalButton` for new UI
- Use `NeoInput` not `TerminalInput` for new UI
- Use `NeoCard` / `NeoExpandableCard` for all card containers
- Use `SC.*` for all colors in presentation layer
- Pill-shaped buttons (borderRadius: 50) for actions
- Round-corner cards (borderRadius: 16) for containers

### 4.5 Navigation
Three tabs only:
- **HUD** — main dashboard, survival overview
- **LOG** — transaction history and entry
- **SIM** — scenario simulator

No new top-level tabs without strong justification.

---

## 5. Data Contracts

### 5.1 Schema Versioning
Current schema version: **6**

| Version | Change |
|---|---|
| 1 | Initial: transactions table |
| 2 | Added: loanId to transactions, loans table |
| 3 | Added: subscriptions table |
| 4 | Added: originalTermMonths to loans |
| 5 | Added: category to transactions |
| 6 | Added: financial_settings table (single row: budget, forecast assumptions, runway goal) |

Every schema change requires a migration in `MigrationStrategy`.

All financial values live in the encrypted database. `SharedPreferences` may hold only non-financial state: onboarding and dismissal flags, locale, currency code, display settings and the cached Pro flag.

### 5.2 Opening Balance
Opening balance transactions are handled specially:
- Excluded from monthly aggregation loop
- Summed as starting cash before regular transactions
- If only opening balance exists → return synthetic MonthlyState

### 5.3 Transaction Types
```dart
enum TransactionType {
  expense,        // reduces cash, counts in burn rate
  income,         // increases cash
  loan,           // increases cash (loan proceeds)
  investment,     // reduces cash, EXCLUDED from burn rate
  repayment,      // reduces cash, counts in burn rate
  openingBalance, // sets starting cash
}
```

---

## 6. Localization Contracts

### 6.1 Supported Languages
EN, 繁中 (zh_TW), FR, JA, ES, IT

### 6.2 ARB Files Location
`packages/design_system/lib/l10n/`

### 6.3 Adding New Strings
1. Add to all 7 ARB files
2. Run `make gen-l10n`
3. Never hardcode user-facing strings in Dart files

### 6.4 No `//` Prefixes in Strings
ARB values must not contain `//` prefixes. They are for display only.

---

## 7. Testing Contracts

### 7.1 Domain Tests Required
All domain logic changes require corresponding tests in `packages/domain/test/`.

### 7.2 Test Coverage Areas
- `MonthlyAggregator` — always test edge cases (empty, opening only, mixed)
- `SurvivalEngine` — always test status thresholds and runway math
- `LoanEngine` — always test months remaining calculation
- New domain logic → new test file

### 7.3 Test Command
```bash
cd packages/domain && dart test
```
All 39+ tests must pass before any commit.

---

## 8. Git Contracts

### 8.1 Commit Message Format
```
feat: description of new feature
fix: description of bug fix
refactor: code change without behavior change
style: visual/UI changes
test: adding or updating tests
chore: build, deps, config changes
```

### 8.2 Branch Strategy
- `main` — production ready
- `develop` — integration branch
- Feature branches → PR to `develop`
- Releases → `develop` to `main` via PR

### 8.3 Pre-commit Checklist
```bash
make precommit  # runs lint + tests
```
Never commit with failing tests or errors (warnings OK).

---

## 9. Future Development Guidelines

### 9.1 Before Adding a Feature
Answer these questions:
1. Does it serve the survival question?
2. Where does it live in Clean Architecture?
3. Does it need a new domain entity or extend an existing one?
4. What are the edge cases?
5. What tests are needed?

### 9.2 Planned Features (Prioritized)
1. **Onboarding** — 3-screen intro + guided first action (opening balance)
2. **Planned expenses** — future-dated transactions already work; just add PLANNED visual tag
3. **Cloud sync** — Supabase backend, same Flutter codebase
4. **Web support** — replace sqlite3 with drift web backend
5. **Notifications** — subscription renewal alerts, runway warnings

### 9.3 Never Build
- Complex category budgeting (defeats simplicity)
- Social/sharing features (personal survival data)
- Investment portfolio tracking (out of scope)
- Automatic bank sync (privacy, complexity)

---

## 10. Decision Log

| Date | Decision | Reason |
|---|---|---|
| 2026-04 | No investment in burn rate | Investment ≠ expense, would inflate burn |
| 2026-04 | Adaptive safety buffer (6-18mo) | Balance conservative vs aggressive |
| 2026-04 | max(actual, budget) formula | Reality wins, budget is floor not ceiling |
| 2026-09 | Rent and living budget buckets | Logged spending uses up its budget instead of being compared with the whole budget, so nothing is counted twice or missed |
| 2026-09 | Runway measured in months from today | The rest of the current month costs its unused budget, not a full month that was already partly paid |
| 2026-09 | Dropped the investable split; kept a user-set cash reserve | The formula recommended how much to put at risk, from inputs the app does not hold. Stating a position is measurement; sizing an investment is advice |
| 2026-09 | Status bands are 3 and 6 months, not 12 and 24 | Three to six months of cover is the recognised adequacy range. The old bands called an 11-month runway critical, which the facts do not support |
| 2026-09 | Cash excludes entries dated in the future | The log already marks them planned. Counting them let a future bonus lengthen the runway today |
| 2026-09 | Caution runway status is amber `#FFC978`, not gold | Gold means debt. A gold runway number above the gold liabilities card read as one category |
| 2026-04 | Mathematical runway (no 120mo cap) | Artificial caps mislead users |
| 2026-04 | Two pockets (safety + investable) | Mental model clarity |
| 2026-04 | JetBrains Mono for numbers | Gaming soul, readability |
| 2026-04 | Color = semantic meaning only | Reduce visual noise |
| 2026-04 | Runway as hero metric | App purpose = survival timer |
| 2026-04 | No portfolio tracking | Out of scope, different mental model |
| 2026-04 | Subscription normalized to monthly | Apples-to-apples comparison |
| 2026-06 | SQLite DB encrypted with AES-256 via SQLCipher (`PRAGMA key`) | User financial data is sensitive; key generated with `Random.secure()` and stored in iOS Keychain / Android Keystore via `flutter_secure_storage`. Wiring requires `sqlcipher_flutter_libs: ^0.6.0` (NOT `^0.7.0+eol` which is a no-op stub) and `open.overrideFor(...)` calls in `app_database.dart` — without both, `PRAGMA key` silently no-ops on plain sqlite3 |
| 2026-06 | App Store export compliance: standard encryption (EAR 740.17(b)(1)) | SQLCipher counts as standard encryption — select "Standard algorithms" in App Store Connect compliance prompt, then claim exemption as local data protection only |
| 2026-09 | Budget, forecast assumptions and runway goal moved from `SharedPreferences` into the encrypted database (schema 6) | They are financial values and `NSUserDefaults` is a plaintext plist. Existing values move on first launch, then the old keys are removed |
| 2026-09 | `PRAGMA cipher_version` checked every time the database opens | If plain SQLite is loaded instead of SQLCipher, `PRAGMA key` silently does nothing. The check throws in debug builds and reports the error in release builds |
| 2026-09 | "Delete all data" keeps only the cached Pro flag | It holds no financial data, and keeping it avoids locking a paying user out while offline |
