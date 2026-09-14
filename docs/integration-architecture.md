# Integration Architecture — How the Six Parts Fit Together

**Repository type:** Dart/Flutter monorepo (melos + pub workspace), 6 parts
**Generated:** 2026-08-04 · Deep scan

---

## The Layer Rule

```
presentation ──▶ application ──▶ domain ◀── data
       │                             ▲
       └──▶ design_system            │
                                     │
app ──▶ (all five, wires them together)
```

`domain` is the hub. Dependencies point inward only. Because each layer is a **separate pub package**, a violating import fails to resolve at compile time — the architecture is enforced by the build, not by convention (CONTRACTS §2.1).

`design_system` is a leaf beside `domain`: it depends on Flutter only, and only `presentation` and `app` depend on it.

## Declared Dependencies (from each `pubspec.yaml`)

| Part | Depends on (internal) | Key external |
|---|---|---|
| `domain` | — | `fpdart` |
| `data` | `domain` | `drift`, `sqlcipher_flutter_libs`, `flutter_secure_storage`, `sqlite3` |
| `application` | `domain` | `flutter_riverpod`, `riverpod_annotation` |
| `design_system` | — | `google_fonts`, `intl`, `flutter_localizations` |
| `presentation` | `application`, `design_system`, `domain` | `go_router`, `fl_chart`, `intl`, `uuid`, `share_plus` |
| `app` | all five | `firebase_*`, `purchases_flutter`, `path_provider`, `flutter_windowmanager_plus`, `share_plus`, `screenshot` |

Note that `presentation` does **not** depend on `data`, and `application` does **not** depend on `data`. Only `app` sees both.

## Integration Points

| # | From | To | Mechanism | Details |
|---|---|---|---|---|
| 1 | `app` | `application` | Riverpod `ProviderScope(overrides:)` | Injects `DriftTransactionRepository`, `DriftLoanRepository`, `DriftSubscriptionRepository`, `RevenueCatService`, `FirebaseAnalyticsService` into placeholder providers that otherwise throw `UnimplementedError` |
| 2 | `data` | `domain` | Interface implementation | `Drift*Repository implements domain.*Repository`; Drift row classes are converted at the boundary by mapper extensions — no ORM types leak inward |
| 3 | `application` | `domain` | Direct function calls | `modelProvider` composes `aggregateMonths` + `computeModel`; loan/subscription providers call the corresponding engines |
| 4 | `presentation` | `application` | `ref.watch` / `ref.read` | Reads providers for display; writes via `*UseCaseProvider.execute(...)` |
| 5 | `presentation` | `design_system` | Widget + token imports | `context.l10n`, `SC.*`/`AppColors.*`, `AppSpacing`, `AppTextStyles`, Neo/Terminal components |
| 6 | `data` ↔ UI | Reactive streams | Drift `watch()` → `StreamProvider` → `ConsumerWidget` rebuild — the only push path in the app |

## The Reactive Loop

This is the app's central runtime behavior:

```
User submits a form (presentation)
  └─▶ ref.read(addTransactionUseCaseProvider).execute(tx)   [application]
        └─▶ TransactionRepository.add(tx)                    [domain iface]
              └─▶ DriftTransactionRepository → DAO → SQLite  [data]
                    └─▶ Drift watch() stream emits
                          └─▶ transactionsProvider updates   [application]
                                └─▶ modelProvider recomputes ModelState
                                      └─▶ RunwayCard rebuilds with the new number
```

No manual refresh, no cache invalidation — a single write propagates all the way to the hero number through Drift's query-stream invalidation.

## Ports Awaiting Implementations

Four abstractions in `application` are deliberately unimplemented there and bound only in `app/lib/main.dart`:

| Port | Location | Bound to |
|---|---|---|
| `TransactionRepository` / `LoanRepository` / `SubscriptionRepository` | `domain/repositories/` | `data`'s Drift implementations |
| `PurchaseService` | `application/services/purchase_service.dart` | `app`'s `RevenueCatService` |
| `AnalyticsService` | `application/analytics_service.dart` | `app`'s `FirebaseAnalyticsService` (defaults to `NoOpAnalytics`) |

This is what makes the layers independently testable: swapping in `AppDatabase.forTesting` or a `mocktail` double needs no change outside the test.

## Cross-Cutting Concerns

| Concern | Owner | Notes |
|---|---|---|
| Persistence (entities) | `data` | Encrypted SQLite |
| Persistence (settings) | `application` | `shared_preferences`, bypasses repositories entirely |
| Localization | `design_system` | 6 locales, 230 keys; consumed via `context.l10n` |
| Theming | `design_system` | Dark-only |
| Entitlements | `application` (`EntitlementState`) | Enforced ad-hoc at `presentation` call sites |
| Analytics | port in `application`, impl in `app` | Behavior only, no financial values |
| Screen security | `app` | Android `FLAG_SECURE` only |

## Shared State That Crosses Boundaries

`shared_preferences` is used by both `application` (budget, assumptions, goal, currency, locale, `is_pro`) and `presentation` (`onboarding_done`, read directly in `BootScreen`). That last one is the only place presentation touches storage directly — a small deviation from the repository/provider discipline.

## See Also

- [Source Tree Analysis](./source-tree-analysis.md) · [Project Overview](./project-overview.md) · per-part architecture docs in the [index](./index.md)
