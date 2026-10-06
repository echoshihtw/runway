# Project Overview — Runway

**Repository:** `survival_optimizer` · **Product name:** Runway · **Version:** `1.0.1+2`
**Generated:** 2026-08-04 · Deep scan · 6 parts

---

## Purpose

> One number matters: your runway.

Runway is a personal financial runway app for people in a defined financial chapter — studying abroad, between jobs, bootstrapping, or living off savings. It answers exactly one question, continuously: **how long can my money last?**

It is explicitly *not* a budgeting app, portfolio tracker, or accounting system. `CONTRACTS.md` §1.3 gates every feature on three questions: does it serve the survival question, is it understandable without a tutorial, and does it add data rather than noise?

## The Core Model

```
RUNWAY = currentCash / totalMonthlyBurn

totalMonthlyBurn = budgetBurnRate + subscriptions + debtPayments
budgetBurnRate   = max(actualSpending, budgetEstimate)
```

Budget is a **floor**, never a ceiling — when actual spending exceeds the budget, reality wins. Implemented in `application/lib/providers/model_provider.dart` (the `max`) and `domain/lib/logic/burn_engine.dart`.

Status thresholds: `≥24 months → STABLE`, `≥12 → CAUTION`, else `CRITICAL`.

## Architecture

Clean Architecture + DDD across a Flutter monorepo, with each layer as a **separate pub package** so boundaries fail at compile time rather than review time.

```
presentation → application → domain ← data
       ↓
 design_system                app (wires it all)
```

| Part | Path | Type | Role |
|---|---|---|---|
| `domain` | `packages/domain` | Pure Dart library | Entities, value objects, engines, repository interfaces |
| `data` | `packages/data` | Flutter library | Drift + SQLCipher persistence |
| `application` | `packages/application` | Flutter library | Riverpod providers, use cases, service ports |
| `design_system` | `packages/design_system` | Flutter library | Tokens, theme, 15 components, 6-locale l10n |
| `presentation` | `packages/presentation` | Flutter library | 8 screens + feature widgets, GoRouter |
| `app` | `app/` | Flutter application | Composition root, native projects, integrations |

## Tech Stack

| Layer | Technology |
|---|---|
| Framework / language | Flutter 3.41.7 · Dart 3.11.5 |
| Monorepo | Melos 7.5.1 + Dart pub workspaces |
| State | Riverpod 3.0.3 |
| Persistence | Drift 2.26 over SQLCipher-encrypted SQLite |
| Key storage | `flutter_secure_storage` (Keychain / Keystore) |
| Routing | go_router 14.6 |
| Charts | fl_chart 0.68 |
| Fonts | JetBrains Mono (numbers) + Inter (labels) via `google_fonts` |
| Analytics | Firebase Analytics (optional, behavior-only) |
| Purchases | RevenueCat `purchases_flutter` 10 (in flight) |
| CI/CD | GitHub Actions → TestFlight + Play Store internal |

## Privacy & Security Posture

- **Fully offline.** No backend, no API, no sync. All financial data stays on the device.
- Database encrypted at rest with a 256-bit key generated on-device and stored in the Keychain/Keystore, never in preferences.
- Android sets `FLAG_SECURE` (no screenshots, no app-switcher preview). No iOS equivalent is applied.
- Analytics events carry **behavior only** — no amounts, balances, or runway values.
- Consequence of the above: losing the Keychain entry (e.g. uninstall) makes the database unrecoverable, and there is no export/backup path.

## Monetization

Free tier: five entries and three simulations, then Pro; loans, subscriptions, budget and sharing are free without limit. Pro: unlimited entries and simulations (#80, decided 2026-09-16; the entry limit added 2026-09-18).

The numbers live in `presentation/lib/product_config.dart` (`ProductConfig.freeEntries`, `freeSimulations`), beside the daily-spend presets — one place for every product decision. The rule is one function, `needsPro` (`application`); enforcement is one helper, `shared/pro_gate.dart` (`allowsNewEntry`, `allowsSimulation`), asked at every door. Both counts live in one Keychain-backed `UsageCountStore` and survive reinstall; the Plan screen and the add sheet show the count once the first is spent. Entitlement resolution is offline-first — a cached `is_pro` flag wins, and a network failure never revokes Pro.

## Current State (as of this scan)

The working tree carries **substantial uncommitted changes** on top of `ac4738e`:

- RevenueCat integration (`purchases_flutter` v10, `revenuecat_service.dart`, config) — scaffolded across `b87943b`/`ac4738e` with further uncommitted work on top.
- Regenerated app icons (iOS 19 sizes + Android 5 densities) and `Info.plist` changes.
- `CONTRACTS.md`, `main.dart`, `app_database.dart`, and several `pubspec.yaml` edits.

Docs describe the **working tree**, not the last commit. Treat the RevenueCat/monetization surface as in-flight.

**RevenueCat is not yet live:** `kRevenueCatGoogleKey` is still a placeholder, and `isRevenueCatConfigured` requires both keys — so purchases are disabled on iOS and Android alike.

## Known Gaps

Measured against `CONTRACTS.md`, which is binding on both humans and AI agents in this repo.

| Gap | Detail |
|---|---|
| Color contract drift | 287 raw `AppColors.*` references vs 38 `SC.*` in `presentation`, against CONTRACTS §4.1 / §4.4 |
| Contract out of date | §5.1 declares schema version **4**; the code is at **5** (`transactions.category`) |
| Dead melos config | `melos.yaml` scripts (`test:all`, `test:integration:*`) are not loaded — melos reads the `melos:` block in the root `pubspec.yaml`, which has only `test`/`analyze`/`gen` |
| Test coverage | `design_system` and `presentation` have zero tests; CI runs only the domain suite, so the data and application tests never run in CI |
| Missing token | §4.2 specifies a 72px hero; no style above 42px exists in `app_text_styles.dart` |
| Identifier mismatch | iOS `com.silverfern.survivaloptimizer` vs Android `com.survival.app`; `make db-reset-android` targets the wrong one |
| Hardcoded strings | §6.3 forbids hardcoded user-facing strings; `app_router.dart`'s action sheet uses literal `'ENTRY'`/`'LOAN'`/`'SUBSCRIPTIONS'` |
| Duplicated file | `app_input_formatters.dart` in both `components/` and `utils/` |
| No migration tests | Drift schema snapshots / migration verification are absent |

## Roadmap & Boundaries (CONTRACTS §9)

**Planned, prioritized:** onboarding (shipped — `OnboardingScreen` exists), planned expenses (a PLANNED visual tag on future-dated transactions), cloud sync via Supabase, web support (swap `sqlite3` for the Drift web backend), notifications (renewal alerts, runway warnings).

**Explicitly never to be built:** complex category budgeting, social/sharing features, investment portfolio tracking, automatic bank sync. §9.3 rules these out on simplicity, privacy, and scope grounds — treat proposals in these areas as already decided.

`CONTRACTS.md` §10 is a dated decision log (2026-04 through 2026-06) recording *why* each of the core behaviors was chosen, including the SQLCipher wiring gotcha (`sqlcipher_flutter_libs: ^0.6.0`, **not** `^0.7.0+eol`, which is a no-op stub — without it plus the `open.overrideFor(...)` calls, `PRAGMA key` silently no-ops on plain sqlite3) and the App Store export-compliance position (standard encryption under EAR 740.17(b)(1), exempt as local data protection).

## Git Workflow (CONTRACTS §8)

Conventional Commits (`feat/fix/refactor/style/test/chore`). Branches: `main` = production-ready, `develop` = integration, feature branches PR into `develop`, releases PR `develop → main`. `make precommit` before every commit; never commit with failing tests or errors (warnings are acceptable).

## Where to Start

1. `CONTRACTS.md` — the binding rules.
2. [Source Tree Analysis](./source-tree-analysis.md) — the annotated map.
3. [Integration Architecture](./integration-architecture.md) — how the parts talk.
4. `packages/domain/lib/logic/burn_engine.dart` and `runway_engine.dart` — the product, in two functions.

## See Also

- [Documentation Index](./index.md)
