# Deployment Guide

**Project:** Runway (`survival_optimizer`) · **App version:** `1.0.0+1`
**Generated:** 2026-08-04 · Deep scan

---

## Pipelines

Two GitHub Actions workflows, both pinned to **Flutter 3.41.7 / Java 17**.

### CI — `.github/workflows/ci.yml`

| Trigger | Jobs |
|---|---|
| PR to `staging`/`main` | `quality` only |
| Push to `staging` | `quality` → `build-ios` + `build-android` |
| Called by `release.yml` on `main` | `quality` → `build-ios` + `build-android` |

Concurrency is grouped per workflow+ref with `cancel-in-progress: true`.

**`quality` (ubuntu):** checkout → Flutter setup (cached) → cache `~/.pub-cache` keyed on `**/pubspec.yaml` → `melos bootstrap` → `melos run gen` → `analyze --fatal-infos` for all six packages individually → `dart test` in `domain` → upload `packages/domain/test-results/`.

> `--fatal-infos` is stricter than local `make analyze`. Also note CI's test step covers **domain only** — the data integration tests (`cd packages/data && flutter test test/integration/`) and the application use-case tests are not run in CI, despite needing no device.

**`build-ios` (macos):** pod install → `flutter build ios --release --no-codesign --dart-define=FLUTTER_BUILD_NUMBER=${{ github.run_number }}` → upload `Runner.app` (7-day retention).

**`build-android` (ubuntu):** builds both APK and AAB with the same build-number define → uploads both (7-day retention).

### CD — `.github/workflows/cd.yml`

Called by `release.yml` with the new tag, or run by hand from the Actions tab with an existing tag. Build name comes from `app/pubspec.yaml`, build number from `git rev-list --count HEAD` (#158). Two independent jobs:

**`release-ios` → TestFlight**
1. Bootstrap + codegen + pod install.
2. Import the `.p12` certificate into a temporary keychain (`app-signing.keychain-db`, 6-hour timeout).
3. Install the provisioning profile.
4. `flutter build ipa --release --export-options-plist=ios/ExportOptions.plist`.
5. `xcrun altool --upload-app` with the App Store Connect API key.
6. Upload the IPA artifact (30-day retention).

**`release-android` → Play Store (internal track)**
1. Decode the keystore to `app/android/app/keystore.jks`.
2. `flutter build appbundle --release`.
3. `r0adkll/upload-google-play@v1` → `packageName: com.survival.app`, `track: internal`, `status: completed`.
4. Upload the AAB artifact (30-day retention).

Cutting a release: merge the open `chore(release): …` PR from `staging` into
`main` with a merge commit. `release-pr.yml` keeps that PR open and titled with
the version; `release.yml` verifies the merge, runs semantic-release to cut the
tag and GitHub Release, then calls `cd.yml`. Never squash it: the guard job
refuses a non-merge commit.

## Required GitHub Secrets

Documented in `.github/SECRETS.md`.

**iOS:** `IOS_CERTIFICATE_BASE64`, `IOS_CERTIFICATE_PASSWORD`, `KEYCHAIN_PASSWORD`, `IOS_PROVISIONING_PROFILE_BASE64`, `APP_STORE_CONNECT_API_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`, `APP_STORE_CONNECT_API_KEY_BASE64`

**Android:** `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, `ANDROID_STORE_PASSWORD`, `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`

Encode with `base64 -i your_file.p12 | pbcopy`.

## Local Release Builds

```bash
make testflight-check     # gen-icons + gen-l10n + l10n-check + analyze + test
make build-testflight     # signed IPA (BUILD_NAME / BUILD_NUMBER / IOS_EXPORT_METHOD overridable)
make build-ios            # unsigned iOS release
make build-android        # release APK
make build-android-aab    # release AAB
```

`build-testflight` verifies an `.ipa` newer than the build start actually appeared, and fails with a pointer to the Xcode archive if export/signing broke.

```bash
BUILD_NAME=1.0.2 BUILD_NUMBER=3 make build-testflight
IOS_EXPORT_METHOD=ad-hoc make build-testflight
```

## Platform Identifiers

| Surface | Identifier |
|---|---|
| iOS bundle id (`project.pbxproj`) | `com.silverfern.survivaloptimizer` |
| Android `applicationId` / `namespace` | `com.survival.app` |
| Play Store `packageName` (cd.yml) | `com.survival.app` |
| `Makefile` `APP_ID` | `com.silverfern.survivaloptimizer` |

⚠️ iOS and Android ship under **different identifiers**. Intentional or not, this affects RevenueCat app configuration, Firebase project registration, and deep links — confirm both are registered correctly in each dashboard before release.

## Pre-Release Checklist

- [ ] `make precommit` passes (lint + tests)
- [ ] `cd packages/data && flutter test test/integration/` passes (CI does not run these)
- [ ] `CONTRACTS.md` §5.1 schema-version table updated if the schema changed (it currently says v4; the code is at v5)
- [ ] `make l10n-check` — all 7 `.arb` files valid
- [ ] `make gen-all` run and no stale `.g.dart` committed (CONTRACTS §2.4)
- [ ] **`kRevenueCatGoogleKey` replaced** — while it is a placeholder, `isRevenueCatConfigured` is false and purchases are disabled on *both* platforms
- [ ] Version bumped in `app/pubspec.yaml`
- [ ] Firebase `google-services.json` / `GoogleService-Info.plist` present for the correct bundle ids
- [ ] Icons regenerated from the master (`make gen-icons`) if the brand asset changed

## Runtime Configuration

There is no `.env` mechanism. Configuration is compile-time:

| Setting | Where |
|---|---|
| RevenueCat keys + entitlement id | `app/lib/revenuecat_config.dart` (source-committed constants) |
| Firebase | `app/lib/firebase_options.dart` (flutterfire-generated) |
| Dev Pro unlock | `--dart-define=DEV_PRO_ENTITLEMENT=true` (non-release builds only) |
| Version / build number | The version comes from `app/pubspec.yaml`; CD passes only `--build-number` as the commit count. Local builds can override either with `BUILD_NAME`/`BUILD_NUMBER` via the Makefile |

The RevenueCat keys in `revenuecat_config.dart` are *public SDK keys*, which are designed to be shipped in the client — but they are committed to the repo rather than injected, so rotating one requires a code change and release.

## Infrastructure

**None.** Runway is a fully offline, local-only app: no backend, no API, no hosted database. The only external services are Firebase Analytics (optional — init failure is caught and ignored) and RevenueCat (optional — disabled when keys are placeholders). All user data lives in the on-device encrypted SQLite file.

## See Also

- [Development Guide](./development-guide.md) · [App Architecture](./architecture-app.md) · `.github/SECRETS.md`
