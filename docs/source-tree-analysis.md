# Source Tree Analysis

**Repository:** `survival_optimizer` (product name: **Runway**)
**Generated:** 2026-08-04 · Deep scan

---

## Annotated Tree

```
survival_optimizer/
├── melos.yaml                  # Melos scripts: test, test:integration:*, analyze, gen
├── pubspec.yaml                # Pub workspace root — lists all 6 packages
├── Makefile                    # ★ The real developer entry point (40+ targets)
├── CONTRACTS.md                # ★ Binding rules: product, architecture, domain, UI
├── README.md                   # Product philosophy, formula, tech stack
├── docs/                       # ← this documentation
├── design-artifacts/           # WDS pipeline outputs (brief → trigger map → UX → DS → dev)
│   ├── A-Product-Brief/  B-Trigger-Map/  C-UX-Scenarios/
│   └── D-Design-System/  E-Development/
├── _bmad/ · _bmad-output/      # BMad module config + planning/research artifacts
├── .github/
│   ├── workflows/ci.yml        # analyze + test + build iOS/Android on push
│   ├── workflows/cd.yml        # tag v*.*.* → TestFlight + Play Store internal
│   └── SECRETS.md              # required GitHub secrets
│
├── packages/
│   ├── domain/                 # ★ PURE DART CORE — no Flutter
│   │   └── lib/
│   │       ├── entities/       # Transaction, Loan, Subscription, ModelState, ...
│   │       ├── enums/          # TransactionType, ExpenseCategory, BillingCycle, ...
│   │       ├── logic/          # ★ survival_engine.dart — computeModel()
│   │       ├── repositories/   # abstract interfaces (implemented by data/)
│   │       ├── value_objects/  # Money, SurvivalMonth
│   │       └── failures/       # sealed DomainFailure
│   │
│   ├── data/                   # Drift + SQLCipher — implements domain interfaces
│   │   └── lib/
│   │       ├── database/       # ★ app_database.dart — schema v5, encryption key mgmt
│   │       ├── tables/         # transactions, loans, subscriptions
│   │       ├── daos/           # Drift accessors (+ generated .g.dart)
│   │       ├── mappers/        # row ↔ domain conversion
│   │       └── repositories/   # Drift*Repository
│   │
│   ├── application/            # Riverpod providers + use cases (depends: domain only)
│   │   └── lib/
│   │       ├── providers/      # ★ model_provider.dart — composes the runway
│   │       ├── use_cases/      # 9 CRUD use cases with validation
│   │       ├── services/       # PurchaseService port
│   │       ├── state/          # ScenarioState, TransactionState
│   │       ├── analytics_service.dart   # AnalyticsService port + NoOp
│   │       └── feature_flags.dart
│   │
│   ├── design_system/          # Tokens, theme, components, localizations
│   │   ├── l10n.yaml
│   │   └── lib/
│   │       ├── tokens/         # ★ app_semantic_colors.dart (SC.*) — CONTRACTS §4.1
│   │       ├── theme/          # AppTheme.dark (dark-only)
│   │       ├── components/     # 15 widgets: Neo (current) + Terminal (legacy)
│   │       ├── l10n/*.arb      # 7 files × 230 keys → en, es, fr, it, ja, zh, zh_TW
│   │       └── generated/      # AppLocalizations (gen-l10n output)
│   │
│   └── presentation/           # Screens + widgets (never imports data/)
│       └── lib/
│           ├── router/app_router.dart   # ★ GoRouter + shell + swipe-up action sheet
│           ├── features/
│           │   ├── boot/ onboarding/    # first-run flow
│           │   ├── dashboard/           # ★ the hero surface + 8 widgets
│           │   ├── transactions/        # log + forms + loan wizard
│           │   ├── scenarios/           # what-if simulator
│           │   ├── subscriptions/ loans/ config/ paywall/
│           └── shared/
│
└── app/                        # ★ COMPOSITION ROOT (the Flutter application)
    ├── lib/
    │   ├── main.dart           # ★ ProviderScope overrides — wires everything
    │   ├── firebase_options.dart · firebase_analytics_service.dart
    │   └── revenuecat_config.dart · revenuecat_service.dart
    ├── test/ · integration_test/
    ├── ios/ · android/         # native projects, icons, signing
    └── assets/brand/
```

★ = highest-value files for orienting in this codebase.

## Entry Points

| Purpose | File |
|---|---|
| Application `main()` | `app/lib/main.dart` |
| First screen | `packages/presentation/lib/features/boot/boot_screen.dart` (route `/boot`) |
| Routing table | `packages/presentation/lib/router/app_router.dart` |
| The core calculation | `packages/domain/lib/logic/survival_engine.dart` → `computeModel()` |
| The composition of that calculation | `packages/application/lib/providers/model_provider.dart` → `modelProvider` |
| Database + schema | `packages/data/lib/database/app_database.dart` |
| Color/typography rules | `packages/design_system/lib/tokens/app_semantic_colors.dart` |
| Developer commands | `Makefile` |
| The rules | `CONTRACTS.md` |

## Critical Directories by Question

| If you want to… | Look in |
|---|---|
| Change how runway is calculated | `packages/domain/lib/logic/` |
| Change what feeds the calculation | `packages/application/lib/providers/model_provider.dart` |
| Add a persisted field | `packages/data/lib/tables/` + migration in `app_database.dart` + entity + mapper |
| Add a screen | `packages/presentation/lib/features/` + `router/app_router.dart` |
| Change colors/spacing/type | `packages/design_system/lib/tokens/` |
| Add or translate a string | `packages/design_system/lib/l10n/*.arb`, then `make gen-l10n` |
| Change what's free vs Pro | `packages/application/lib/providers/entitlement_provider.dart` (policy) + presentation call sites (enforcement) |
| Change build/release | `Makefile`, `.github/workflows/` |

## Excluded from This Analysis

`build/`, `.dart_tool/`, `.git/`, `app/ios/Pods/`, generated `*.g.dart` (described but not enumerated), and binary assets.

## See Also

- [Integration Architecture](./integration-architecture.md) · [Project Overview](./project-overview.md)
