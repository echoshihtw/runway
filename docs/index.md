# Runway — Project Documentation Index

> Primary entry point for AI-assisted development on this repository.

**Generated:** 2026-08-04 · Mode: initial scan · Depth: **deep** (critical files read per package)

---

## Project Overview

- **Repository type:** Monorepo (Melos + Dart pub workspace), **6 parts**
- **Primary language:** Dart 3.11.5 / Flutter 3.41.7
- **Architecture:** Clean Architecture + DDD — `presentation → application → domain ← data`, boundaries enforced by package separation
- **Product:** Offline-first personal financial runway app. One question: how long can my money last?
- **App version:** `1.0.1+2`

## Quick Reference by Part

| Part | Root | Type | Stack | Docs |
|---|---|---|---|---|
| **domain** | `packages/domain` | Pure Dart library | `fpdart` only — no Flutter | [architecture](./architecture-domain.md) · [interfaces](./api-contracts-domain.md) |
| **data** | `packages/data` | Flutter library | Drift 2.26, SQLCipher, secure storage | [architecture](./architecture-data.md) · [data models](./data-models-data.md) |
| **application** | `packages/application` | Flutter library | Riverpod 3.0.3 | [architecture](./architecture-application.md) |
| **design_system** | `packages/design_system` | Flutter library | google_fonts, intl, gen-l10n | [architecture](./architecture-design_system.md) · [components](./component-inventory-design_system.md) |
| **presentation** | `packages/presentation` | Flutter library | go_router, fl_chart | [architecture](./architecture-presentation.md) · [components](./component-inventory-presentation.md) |
| **app** | `app/` | Flutter application | Firebase, RevenueCat, native projects | [architecture](./architecture-app.md) |

## Generated Documentation

### Start here
- [Project Overview](./project-overview.md) — purpose, model, stack, current state, known gaps
- [Source Tree Analysis](./source-tree-analysis.md) — annotated tree, entry points, "where do I look for X"
- [Integration Architecture](./integration-architecture.md) — how the six parts communicate

### Per-part architecture
- [Architecture — domain](./architecture-domain.md)
- [Architecture — data](./architecture-data.md)
- [Architecture — application](./architecture-application.md)
- [Architecture — design_system](./architecture-design_system.md)
- [Architecture — presentation](./architecture-presentation.md)
- [Architecture — app](./architecture-app.md)

### Contracts, data, components
- [Repository Interfaces (API Contracts) — domain](./api-contracts-domain.md) — *the app has no network API; these are the closest analogue*
- [Data Models — data](./data-models-data.md) — schema v5, migrations, encryption
- [Component Inventory — design_system](./component-inventory-design_system.md)
- [Component Inventory — presentation](./component-inventory-presentation.md)

### Machine-readable
- [`project-parts.json`](./project-parts.json) — parts, dependency graph, integration points, platform identifiers
- [`project-scan-report.json`](./project-scan-report.json) — scan state, findings, counts, known gaps

### Operations
- [Development Guide](./development-guide.md) — prerequisites, Makefile targets, codegen, testing, conventions
- [Deployment Guide](./deployment-guide.md) — CI/CD, signing, secrets, release checklist

### Not generated
- Contribution Guide _(not applicable — no `CONTRIBUTING.md` exists; `CONTRACTS.md` §8–§9 defines commit format, branch strategy, and the pre-feature checklist, and the [Development Guide](./development-guide.md#conventions) summarizes them)_
- Component Inventory — domain / data / application _(not applicable — these parts contain no UI components)_
- API contracts beyond `domain`'s repository interfaces _(not applicable — the app has no network API)_

## Existing Documentation in the Repo

| Document | Path | What it covers |
|---|---|---|
| **CONTRACTS.md** | `CONTRACTS.md` | ★ **Binding rules** — product principles, layer boundaries, burn/runway formulas, color & typography contracts. Read before changing anything. |
| README | `README.md` | Product philosophy, the runway formula, architecture summary, tech stack |
| CI Secrets | `.github/SECRETS.md` | Required GitHub secrets and how to encode them |
| Design artifacts | `design-artifacts/` | WDS pipeline: `A-Product-Brief`, `B-Trigger-Map`, `C-UX-Scenarios`, `D-Design-System`, `E-Development` |
| Planning artifacts | `_bmad-output/planning-artifacts/` | Market research (`market-runway-financial-runway-app-us-research-2026-08-04.md`) |

## Getting Started

```bash
make install     # fvm + Flutter + melos + cocoapods
make setup       # melos bootstrap
make gen-all     # Drift/Riverpod codegen + localizations
make run         # run on a connected device
make run-pro     # run with Pro entitlement unlocked locally
make precommit   # lint + tests before committing
```

Reading order for a new contributor:
1. `CONTRACTS.md` → 2. [Project Overview](./project-overview.md) → 3. [Source Tree Analysis](./source-tree-analysis.md) → 4. `packages/domain/lib/logic/burn_engine.dart` and `runway_engine.dart`

## Caveats

- Documentation reflects the **working tree** at scan time, which has substantial uncommitted changes (RevenueCat integration, icons, `Info.plist`) on top of commit `ac4738e`.
- Deep scan reads critical directories, not every file. Generated `*.g.dart` files are described but not enumerated.
- Known deviations between `CONTRACTS.md` and the code are called out in the relevant docs and summarized under [Known Gaps](./project-overview.md#known-gaps).

## Using These Docs for a Brownfield PRD

Point the PRD workflow at this file. For scoped work:

| Feature scope | Reference |
|---|---|
| Calculation / financial model | `architecture-domain.md` |
| UI-only | `architecture-presentation.md` + `component-inventory-*.md` |
| New persisted data | `architecture-data.md` + `data-models-data.md` |
| State / providers / entitlements | `architecture-application.md` |
| Full-stack (through all layers) | `integration-architecture.md` + the relevant part docs |
