# Data Models — `data`

**Database:** `survival.db` (SQLite via Drift, encrypted with SQLCipher)
**Location:** app documents directory · **Schema version:** 5
**Generated:** 2026-08-04 · Deep scan

---

## Tables

### `transactions`

Source: `packages/data/lib/tables/transactions_table.dart`

| Column | Type | Null | Default | Notes |
|---|---|---|---|---|
| `id` | TEXT | no | — | **PK**, client-generated UUID |
| `date` | DATETIME | no | — | Drives the derived `SurvivalMonth` |
| `type` | TEXT | no | — | `TransactionType.name`: `expense`, `income`, `loan`, `investment`, `repayment`, `openingBalance` |
| `amount` | REAL | no | — | Always non-negative; sign derived from `type.isInflow` |
| `note` | TEXT | yes | — | |
| `loanId` | TEXT | yes | — | Links a `repayment` to `loans.id` (no FK constraint) |
| `category` | TEXT | yes | — | `ExpenseCategory.name`; set only when `type == expense`. Added in v5 |
| `createdAt` | DATETIME | no | — | |
| `updatedAt` | DATETIME | no | — | |

### `loans`

Source: `packages/data/lib/tables/loans_table.dart`

| Column | Type | Null | Default | Notes |
|---|---|---|---|---|
| `id` | TEXT | no | — | **PK** |
| `name` | TEXT | no | — | |
| `source` | TEXT | no | — | Lender / origin label |
| `originalAmount` | REAL | no | — | Principal borrowed |
| `monthlyPayment` | REAL | no | — | Feeds `totalMonthlyPayment` in the burn rate |
| `originalTermMonths` | INTEGER | no | `0` | Added in v4; `0` means "unknown", which makes `monthsRemaining` fall back to `balance / payment` |
| `startDate` | DATETIME | no | — | Baseline for elapsed-term math |
| `note` | TEXT | yes | — | |
| `isActive` | BOOLEAN | no | `true` | Inactive loans are excluded from burn |
| `createdAt` | DATETIME | no | — | |
| `updatedAt` | DATETIME | no | — | |

### `subscriptions`

Source: `packages/data/lib/tables/subscriptions_table.dart`

| Column | Type | Null | Default | Notes |
|---|---|---|---|---|
| `id` | TEXT | no | — | **PK** |
| `name` | TEXT | no | — | |
| `category` | TEXT | no | — | `SubscriptionCategory.name`: `personal` \| `business` |
| `amount` | REAL | no | — | In the billing cycle's own units, not monthly |
| `cycle` | TEXT | no | — | `BillingCycle.name`: `weekly` \| `monthly` \| `quarterly` \| `yearly` |
| `startDate` | DATETIME | no | — | |
| `nextBillingDate` | DATETIME | no | — | Rolled forward by `computeNextBillingDate` |
| `note` | TEXT | yes | — | |
| `isActive` | BOOLEAN | no | `true` | |
| `createdAt` | DATETIME | no | — | |
| `updatedAt` | DATETIME | no | — | |

## Relationships

```
loans (1) ─────< (n) transactions          via transactions.loanId
                                            only for type == 'repayment'
                                            NOT enforced by a FK constraint

subscriptions                               standalone — no relations
```

`LoanSummary` (domain-side, not persisted) is computed by joining loans to their repayment transactions in `loan_engine.dart`.

## Migration History

Defined in `AppDatabase.migration` (`packages/data/lib/database/app_database.dart`). `onUpgrade` is cumulative — each `if (from < n)` block runs for any older version.

| To version | Change |
|---|---|
| 2 | Add `transactions.loanId`; create `loans` table |
| 3 | Create `subscriptions` table |
| 4 | Add `loans.originalTermMonths` (default `0`) |
| 5 | Add `transactions.category` (raw `customStatement`: `ALTER TABLE "transactions" ADD COLUMN "category" TEXT;`) |

`onCreate` simply runs `m.createAll()` for fresh installs.

**When adding a migration:** bump `schemaVersion`, append a new `if (from < n)` block, run `make gen`, **and update the table in `CONTRACTS.md` §5.1** — the contract is the declared source of truth for schema history. There are no generated schema snapshots / `drift_dev schema` verification tests in the repo, so migrations are not automatically regression-tested.

> ⚠️ **CONTRACTS §5.1 is out of date.** It declares "Current schema version: **4**" and lists only migrations 1–4. The code is at **v5** (the `transactions.category` column). Reconcile the contract.

## Other Data Contracts (CONTRACTS §5)

- **§5.2 Opening balance** — excluded from the monthly aggregation loop, summed as starting cash before regular transactions; if *only* an opening balance exists, a synthetic `MonthlyState` is returned. Implemented in `domain/lib/logic/monthly_aggregator.dart`.
- **§5.3 Transaction types** — `expense` (counts in burn), `income`, `loan` (proceeds, inflow), `investment` (reduces cash, **excluded from burn rate**), `repayment` (counts in burn), `openingBalance` (sets starting cash).
  > Note: the contract's stated treatment of `investment` — reduces cash but excluded from burn — is not separately implemented. `TransactionType.investment` is not in `isInflow`, so `aggregateMonths` counts it in `grossOutflow` like any other outflow, which *does* feed the burn rate. The code comment marks the value as retained only for backward compatibility with stored data.

## Persisted Outside SQLite

These are stored in `shared_preferences` by the application layer, not in the database:

| Data | Shape |
|---|---|
| `Budget` (rent, living) | doubles |
| `FinancialAssumptions` (expected inflow, burn override) | nullable doubles |
| `RunwayGoal` | JSON (`toJson`/`fromJson` on the entity) |
| Locale, currency, display prefs | strings/bools |
| Entitlement / pro purchase state | RevenueCat-backed cache |

## Encryption & Key Lifecycle

- Key name: `awareness_db_key` in `FlutterSecureStorage`.
- Generated once on first launch: 32 bytes from `Random.secure()`, base64url-encoded.
- iOS accessibility: `first_unlock_this_device` — not synced to iCloud, not readable before first unlock.
- Applied per connection via `PRAGMA key`, with a `sqlite_master` probe to fail fast on a wrong key.
- **Consequence:** the database is unrecoverable if the Keychain/Keystore entry is lost (e.g. app uninstall). There is no backup or export path at scan time.

## See Also

- [Data Layer Architecture](./architecture-data.md) · [Repository Interfaces](./api-contracts-domain.md)
