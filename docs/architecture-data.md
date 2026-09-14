# Architecture — `data` (Drift + SQLCipher Persistence)

**Part ID:** `data` · **Path:** `packages/data` · **Type:** library (Flutter-dependent)
**Generated:** 2026-08-04 · Deep scan

---

## Executive Summary

`data` is the outer persistence layer. It implements the three repository interfaces declared in `domain` on top of **Drift** over an **encrypted SQLCipher** SQLite database. It depends on `domain` and nothing else in the project — it never imports `application` or `presentation`, satisfying the inward-only dependency rule of CONTRACTS §2.1.

The layer is deliberately thin and mechanical: table → generated row class → mapper extension → DAO → repository.

## Technology Stack

| Category | Technology | Version | Purpose |
|---|---|---|---|
| ORM / query layer | `drift` | `^2.26.1` | Type-safe SQL, reactive `watch()` streams |
| Encryption | `sqlcipher_flutter_libs` | `^0.6.0` | At-rest AES encryption of `survival.db` |
| Key storage | `flutter_secure_storage` | `^10.0.0` | iOS Keychain / Android Keystore |
| SQLite engine | `sqlite3` | `^2.7.0` | `open.overrideFor` platform wiring |
| Paths | `path_provider`, `path` | `^2.0.0`, `^1.8.0` | App documents directory |
| Codegen | `drift_dev`, `build_runner` | `^2.26.1`, `^2.10.4` | Generates `*.g.dart` |

**Architecture pattern:** Repository + DAO + explicit mapper. No ORM entity leakage — Drift row classes never cross the layer boundary; `toDomain()` / `toCompanion()` extensions convert at the edge.

## Source Layout

```
packages/data/lib/
├── data.dart                       # barrel: AppDatabase + the 3 repositories
├── database/
│   ├── app_database.dart           # @DriftDatabase, schemaVersion, migrations,
│   │                               # SQLCipher connection + key management
│   └── app_database.g.dart         # generated
├── tables/                         # Drift table definitions
│   ├── transactions_table.dart
│   ├── loans_table.dart
│   └── subscriptions_table.dart
├── daos/                           # @DriftAccessor CRUD + watch (+ .g.dart)
├── mappers/                        # row ↔ domain extension methods
└── repositories/                   # drift_*_repository.dart — implement domain ifaces
```

## Database Connection & Security

`_openConnection()` (in `app_database.dart`) builds a `LazyDatabase`:

1. On Android, `applyWorkaroundToOpenSqlCipherOnOldAndroidVersions()` runs first.
2. The file is `survival.db` inside `getApplicationDocumentsDirectory()`.
3. `_getOrCreateKey()` reads key `awareness_db_key` from `FlutterSecureStorage`. If absent, it generates a **cryptographically secure 256-bit key** (`Random.secure()`, 32 bytes, base64url-encoded) and writes it back. iOS accessibility is `first_unlock_this_device` — the key never leaves the device and is not in an iCloud-backed store.
4. `NativeDatabase.createInBackground` runs the DB on a background isolate; `isolateSetup` overrides the sqlite3 open function to SQLCipher (`openCipherOnAndroid` on Android, `DynamicLibrary.process()` on iOS).
5. Session `setup` executes `PRAGMA key = '<key>'`, `PRAGMA journal_mode=WAL`, then a `SELECT count(*) FROM sqlite_master` probe that fails fast if the key is wrong.

`AppDatabase.forTesting(executor)` is the injection point used by the integration tests to swap in an in-memory, unencrypted executor.

> **Security note:** the key is interpolated into a `PRAGMA key = '…'` string. Because it is base64url-generated locally it contains no quotes, so this is safe as written, but it is not quote-escaped defensively.

## Schema

See [data-models-data.md](./data-models-data.md) for the full column-level schema and migration history.

Current `schemaVersion` is **5**, with a cumulative `onUpgrade` ladder (v2 loans + `loanId`, v3 subscriptions, v4 `originalTermMonths`, v5 `transactions.category` via `customStatement`).

## Repository Implementations

Each `Drift*Repository` holds an `AppDatabase`, delegates to its DAO, and maps rows:

```dart
class DriftTransactionRepository implements domain.TransactionRepository {
  Stream<List<domain.Transaction>> watchAll() =>
      _db.transactionDao.watchAll().map((rows) => rows.map((r) => r.toDomain()).toList());
  ...
}
```

DAOs (`@DriftAccessor`) expose `watchAll()`, `getAll()`, `insertX`, `updateX` (keyed by `id`), `deleteX(String id)`. `update` writes the whole companion, so partial updates are not supported — callers pass a fully-populated entity.

## Mapping Rules

- Enums are persisted as **`.name` strings** and read back with `Values.byName(...)`. Renaming an enum constant is therefore a breaking data change requiring a migration.
- `Money` is stored as a `real` and reconstructed via `domain.Money(amount)` — which throws on negative values, so a corrupted negative row surfaces as an exception at read time.
- `Transaction.month` is not persisted; it is re-derived from `date` by the entity constructor.
- Nullable columns (`note`, `loanId`, `category`) map to nullable domain fields.

## Testing Strategy

Three integration tests under `test/integration/` (`transaction_`, `loan_`, `subscription_repository_test.dart`) plus a shared `db_helper.dart`. They exercise the real Drift stack against an in-memory SQLite database — **no device required**.

```bash
cd packages/data && flutter test test/integration/
```

(`melos run test:integration:data` is declared in `melos.yaml`, but melos loads its scripts from the root `pubspec.yaml` instead — that script is not available. See [development-guide.md](./development-guide.md#testing).)

## Code Generation

`*.g.dart` files (`app_database.g.dart`, three DAO files) are checked in. After changing any table or DAO:

```bash
make gen        # or: melos run gen
```

CONTRACTS §2.4: never commit stale `.g.dart`.

## Known Constraints

- No foreign-key constraint links `transactions.loanId` → `loans.id`; deleting a loan leaves orphaned repayment rows.
- Every table's primary key is a client-generated `TEXT` id (UUID v4 from the presentation layer).
- No indexes are declared beyond the primary keys — table scans are acceptable at the data volumes this app targets.
- There is no export/backup path; losing the Keystore/Keychain entry makes the database unreadable.

## See Also

- [Data Models](./data-models-data.md) · [Domain Architecture](./architecture-domain.md) · [Integration Architecture](./integration-architecture.md)
