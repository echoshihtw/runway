# API Contracts — `domain` Repository Interfaces

Runway has **no network API**. It is an offline-first, local-only app. The closest analogue to an API contract is the set of abstract repository interfaces in `packages/domain/lib/repositories/`, which are the only sanctioned way any outer layer reaches data (CONTRACTS §2.3).

**Generated:** 2026-08-04 · Deep scan

---

## Interface Shape

All three repositories share an identical CRUD + stream contract:

```dart
abstract interface class XRepository {
  Stream<List<X>> watchAll();   // reactive, drives Riverpod StreamProviders
  Future<List<X>> getAll();
  Future<void> add(X item);
  Future<void> update(X item);
  Future<void> delete(String id);
}
```

| Interface | File | Entity | Implementation |
|---|---|---|---|
| `TransactionRepository` | `repositories/transaction_repository.dart` | `Transaction` | `data/lib/repositories/drift_transaction_repository.dart` |
| `LoanRepository` | `repositories/loan_repository.dart` | `Loan` | `data/lib/repositories/drift_loan_repository.dart` |
| `SubscriptionRepository` | `repositories/subscription_repository.dart` | `Subscription` | `data/lib/repositories/drift_subscription_repository.dart` |

## Contract Notes

- **`watchAll()` is the primary read path.** The application layer binds it to Riverpod stream providers so the dashboard recomputes the runway whenever the underlying table changes. `getAll()` exists for one-shot reads (export, migration, tests).
- **`delete(String id)`** takes the entity id, not the entity.
- **No `Either`/failure type in the signature.** Despite `fpdart` being a dependency and a sealed `DomainFailure` hierarchy existing in `domain/lib/failures/`, these methods return bare `Future`/`Stream` — errors surface as thrown exceptions or as `AsyncError` on the Riverpod side. `DomainFailure` is currently declared but not wired into the repository contract.
- **Referential integrity is a convention, not a constraint here.** `Transaction.loanId` links a `repayment` to a `Loan`; nothing in the interface enforces that the loan exists.

## Data That Bypasses These Interfaces

Not everything goes through a repository — these are persisted directly by the application layer via `shared_preferences`:

- `Budget` (rent / living)
- `FinancialAssumptions` (expected inflow, burn override)
- `RunwayGoal` (JSON-serialized)
- Locale, currency, and display preferences
- Entitlement / purchase state (RevenueCat-backed, see [architecture-app.md](./architecture-app.md))

## See Also

- [Domain Architecture](./architecture-domain.md)
- [Data Models](./data-models-data.md)
