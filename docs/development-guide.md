# Development Guide

**Project:** Runway (`survival_optimizer`) · **Generated:** 2026-08-04 · Deep scan

The `Makefile` is the canonical entry point — `make help` lists every target. Prefer it over raw `flutter`/`melos` commands, since it handles the FVM prefix and per-package sequencing.

---

## Prerequisites

| Tool | Version | Notes |
|---|---|---|
| Flutter | **3.41.7** | Pinned in CI; managed locally via FVM |
| Dart | `^3.11.5` | Ships with Flutter |
| Melos | `^7.5.1` | `dart pub global activate melos` |
| FVM | latest | `brew tap leoafarias/fvm && brew install fvm` |
| CocoaPods | latest | iOS builds |
| Java | 17 (temurin) | Android builds |
| Python 3 | any | Used by `make l10n-check` |

One-shot install:

```bash
make install     # fvm + Flutter stable + melos + cocoapods
make setup       # melos bootstrap
make doctor      # flutter doctor
```

> `make install` runs `fvm global stable`, not `fvm install 3.41.7`. If stable has moved past 3.41.7 you may drift from the CI-pinned version — pin explicitly if builds diverge.

## Daily Commands

```bash
make run              # run on the connected device
make run-pro          # run with --dart-define=DEV_PRO_ENTITLEMENT=true (unlocks Pro locally)
make run-fresh        # uninstall (wipes the DB) then run
make run-ios          # iPhone simulator
make run-android      # Android emulator
make devices          # list devices
```

`make run-macos` / `make run-chrome` exist but the app targets mobile — SQLCipher and `flutter_windowmanager_plus` are mobile-oriented, so desktop/web runs are not a supported path.

## Code Generation

**CONTRACTS §2.4: never commit stale `.g.dart`.** Regenerate after touching Drift tables/DAOs or `@riverpod` providers:

```bash
make gen         # melos run gen → build_runner across all packages
make gen-l10n    # flutter gen-l10n in design_system
make gen-all     # both
```

## Testing

```bash
make test            # domain unit tests (dart test) — fast, no device
melos run test       # flutter test in every package
make test-coverage   # domain coverage → packages/domain/coverage

# data-layer integration tests (in-memory SQLite, no device):
cd packages/data && flutter test test/integration/

# E2E on a connected device:
cd app && flutter test integration_test/ -d <DEVICE_ID>
```

⚠️ **`melos.yaml` is dead config.** Melos resolves its scripts from the `melos:` block in the **root `pubspec.yaml`**, which declares only `test`, `analyze`, and `gen`. The richer script set in `melos.yaml` (`test:integration:data`, `test:integration:e2e`, `test:all`, plus a `test/`-scoped `test`) is **not loaded** — `melos run test:all` fails with "unknown script". Either fold those scripts into the root `pubspec.yaml` or run the underlying commands directly as shown above.

**Current coverage reality:**

| Package | Tests |
|---|---|
| `domain` | 6 unit test files |
| `data` | 3 integration tests (real Drift, in-memory) |
| `application` | 2 use-case tests (mocktail) |
| `app` | 1 widget test + 2 E2E files |
| `design_system` | **none** |
| `presentation` | **none** |

Note `make test` runs **domain only** — it does not cover the data integration tests, the application use-case tests, or the app widget test.

**CONTRACTS §7** requires: every domain logic change ships with a test in `packages/domain/test/`; `MonthlyAggregator`, `SurvivalEngine`, and `LoanEngine` edge cases are always covered; and "all 39+ tests must pass before any commit" (`cd packages/domain && dart test`).

## Quality

```bash
make format      # dart format across all packages
make analyze     # flutter/dart analyze across all packages
make lint        # format + analyze
make precommit   # lint + test
make l10n-check  # validate every .arb parses as JSON
```

CI runs `analyze --fatal-infos`, which is stricter than local `make analyze`. Run `make lint` before pushing.

## Adding a Feature — the usual path

1. **Domain** — add/extend an entity, enum, or engine function in `packages/domain/lib/`. Write a unit test.
2. **Data** (if persisted) — add the column to the table, bump `schemaVersion`, add an `if (from < n)` migration block, update the mapper, run `make gen`.
3. **Application** — add a use case (with validation) and/or a provider; wire it into `application.dart`'s barrel.
4. **Design system** (if a new generic widget or string) — add tokens/components, add the key to all 7 `.arb` files, `make gen-l10n`.
5. **Presentation** — build the screen/widget, read providers, call use cases; use `SC.*` colors and `context.l10n` strings.
6. `make precommit`.

Before starting, read `CONTRACTS.md` — it is binding on both humans and AI agents working in this repo.

## Database Reset

```bash
make db-reset            # xcrun simctl uninstall (iOS simulator)
make db-reset-android    # adb uninstall
```

⚠️ Both use `APP_ID = com.silverfern.survivaloptimizer`, but the Android `applicationId` is `com.survival.app` — so `make db-reset-android` currently targets a package that isn't installed. Use `adb uninstall com.survival.app` until this is reconciled.

## Brand Assets

```bash
make gen-icons   # regenerate iOS (19 sizes) + Android (5 densities) from
                 # assets/brand/runway-icon-1024.png
```

Uses macOS `sips` — **macOS only**.

## Clean / Reset

```bash
make clean       # flutter clean in every package
make clean-gen   # delete *.g.dart (preserves design_system/lib/generated)
make reset       # clean + clean-gen + setup + gen-all
```

## Conventions

- **Layer boundaries** are enforced by package separation — if an import doesn't resolve, you're crossing a boundary you shouldn't (CONTRACTS §2.1).
- **No math in widgets** — move it to `domain/lib/logic/` (§2.2).
- **All data access through repository interfaces** (§2.3).
- **Semantic colors only** in presentation: `SC.*`, never `AppColors.*` (§4.1). *This is currently widely violated — see [architecture-presentation.md](./architecture-presentation.md#contract-compliance).*
- **Typography**: numbers → JetBrains Mono, labels → Inter (§4.2).
- **Component choice** (§4.4): `NeoButton`/`NeoInput`/`NeoCard` for new UI, not the `Terminal*` predecessors.
- **Navigation** (§4.5): three tabs only — HUD, LOG, SIM. No new top-level tabs without strong justification.
- **Strings** (§6.3): add every key to all 7 `.arb` files; never hardcode user-facing text.
- **Commit style** (§8.1): Conventional Commits — `feat:`, `fix:`, `refactor:`, `style:`, `test:`, `chore:`.
- **Branching** (§8.2): `main` production-ready, `develop` integration; feature branches PR into `develop`, releases PR `develop → main`.
- **Pre-commit** (§8.3): `make precommit`. Never commit with failing tests or errors; warnings are OK.

Before proposing a feature, work §9.1's five questions (survival relevance, layer placement, entity impact, edge cases, tests) and check §9.3's "never build" list — complex category budgeting, social/sharing, portfolio tracking, and automatic bank sync are already decided against.

No `CONTRIBUTING.md` exists; `CONTRACTS.md` fills that role and is the authority for everything above.

## See Also

- [Deployment Guide](./deployment-guide.md) · [Source Tree Analysis](./source-tree-analysis.md) · `CONTRACTS.md`
