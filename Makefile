# ============================================================================
# SURVIVAL OPTIMIZER — Makefile
# ============================================================================

.DEFAULT_GOAL := help
SHELL         := /bin/bash
APP_DIR       := app
APP_ID        := com.silverfern.survivaloptimizer
FVM           := fvm flutter
ICON_SRC      := assets/brand/runway-icon-1024.png
APP_ICON_ASSET := $(APP_DIR)/assets/brand/runway-icon-1024.png
IOS_ICON_DIR  := $(APP_DIR)/ios/Runner/Assets.xcassets/AppIcon.appiconset
ANDROID_RES   := $(APP_DIR)/android/app/src/main/res
IOS_EXPORT_METHOD ?= app-store
IPA_FLAGS     := --release --export-method $(IOS_EXPORT_METHOD)
ifneq ($(BUILD_NAME),)
IPA_FLAGS     += --build-name $(BUILD_NAME)
endif
ifneq ($(BUILD_NUMBER),)
IPA_FLAGS     += --build-number $(BUILD_NUMBER)
endif

# ============================================================================
# HELP
# ============================================================================

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' \
		| sort

# ============================================================================
# SETUP
# ============================================================================

.PHONY: install
install: ## Install all tools (fvm, melos, cocoapods)
	@echo "→ Installing FVM..."
	brew tap leoafarias/fvm && brew install fvm
	@echo "→ Installing Flutter stable..."
	fvm install stable && fvm global stable
	@echo "→ Installing Melos..."
	dart pub global activate melos
	@echo "→ Installing CocoaPods..."
	gem install cocoapods
	@echo "✓ All tools installed"

.PHONY: setup
setup: ## Bootstrap monorepo (install all dependencies)
	melos bootstrap
	@echo "✓ Workspace bootstrapped"

.PHONY: doctor
doctor: ## Run Flutter doctor
	$(FVM) doctor

# ============================================================================
# DEVELOPMENT
# ============================================================================

.PHONY: run
run: ## Run app on connected device/simulator
	cd $(APP_DIR) && $(FVM) run

.PHONY: run-pro
run-pro: ## Run app with local Pro entitlement enabled
	cd $(APP_DIR) && $(FVM) run --dart-define=DEV_PRO_ENTITLEMENT=true

.PHONY: run-fresh
run-fresh: db-reset ## Uninstall app (clear DB) then run
	cd $(APP_DIR) && $(FVM) run

.PHONY: run-ios
run-ios: ## Run app on iOS simulator
	cd $(APP_DIR) && $(FVM) run -d iPhone

.PHONY: run-android
run-android: ## Run app on Android emulator
	cd $(APP_DIR) && $(FVM) run -d android

.PHONY: run-macos
run-macos: ## Run app on macOS
	cd $(APP_DIR) && $(FVM) run -d macos

.PHONY: run-chrome
run-chrome: ## Run app in Chrome
	cd $(APP_DIR) && $(FVM) run -d chrome

# ============================================================================
# CODE GENERATION
# ============================================================================

.PHONY: gen
gen: ## Run code generation (Drift, Riverpod, localizations)
	melos run gen

.PHONY: gen-l10n
gen-l10n: ## Generate localizations from ARB files
	cd packages/design_system && $(FVM) gen-l10n
	@echo "✓ Localizations generated"

.PHONY: gen-all
gen-all: gen ## Deprecated alias for gen, which now includes localizations

# ============================================================================
# BRAND ASSETS
# ============================================================================

.PHONY: gen-icons
gen-icons: gen-icons-app gen-icons-ios gen-icons-android ## Generate app + native launcher icons from master icon
	@echo "✓ Launcher icons generated from $(ICON_SRC)"

.PHONY: gen-icons-app
gen-icons-app: ## Sync master icon into Flutter app assets
	@test -f "$(ICON_SRC)" || (echo "✗ Missing $(ICON_SRC)" && exit 1)
	@mkdir -p "$(dir $(APP_ICON_ASSET))"
	@cp "$(ICON_SRC)" "$(APP_ICON_ASSET)"
	@echo "✓ Flutter app icon asset synced"

.PHONY: gen-icons-ios
gen-icons-ios: ## Generate iOS AppIcon assets from master icon
	@test -f "$(ICON_SRC)" || (echo "✗ Missing $(ICON_SRC)" && exit 1)
	@echo "→ Generating iOS launcher icons..."
	@sips --resampleHeightWidth 40 40 "$(ICON_SRC)" --out "$(IOS_ICON_DIR)/Icon-40 1.png" >/dev/null
	@sips --resampleHeightWidth 60 60 "$(ICON_SRC)" --out "$(IOS_ICON_DIR)/Icon-60.png" >/dev/null
	@sips --resampleHeightWidth 29 29 "$(ICON_SRC)" --out "$(IOS_ICON_DIR)/Icon-29.png" >/dev/null
	@sips --resampleHeightWidth 58 58 "$(ICON_SRC)" --out "$(IOS_ICON_DIR)/Icon-58.png" >/dev/null
	@sips --resampleHeightWidth 87 87 "$(ICON_SRC)" --out "$(IOS_ICON_DIR)/Icon-87.png" >/dev/null
	@sips --resampleHeightWidth 80 80 "$(ICON_SRC)" --out "$(IOS_ICON_DIR)/Icon-80 1.png" >/dev/null
	@sips --resampleHeightWidth 120 120 "$(ICON_SRC)" --out "$(IOS_ICON_DIR)/Icon-120.png" >/dev/null
	@sips --resampleHeightWidth 120 120 "$(ICON_SRC)" --out "$(IOS_ICON_DIR)/Icon-120 1.png" >/dev/null
	@sips --resampleHeightWidth 180 180 "$(ICON_SRC)" --out "$(IOS_ICON_DIR)/Icon-180.png" >/dev/null
	@sips --resampleHeightWidth 20 20 "$(ICON_SRC)" --out "$(IOS_ICON_DIR)/Icon-20.png" >/dev/null
	@sips --resampleHeightWidth 40 40 "$(ICON_SRC)" --out "$(IOS_ICON_DIR)/Icon-40 2.png" >/dev/null
	@sips --resampleHeightWidth 29 29 "$(ICON_SRC)" --out "$(IOS_ICON_DIR)/Icon-29 1.png" >/dev/null
	@sips --resampleHeightWidth 58 58 "$(ICON_SRC)" --out "$(IOS_ICON_DIR)/Icon-58 1.png" >/dev/null
	@sips --resampleHeightWidth 40 40 "$(ICON_SRC)" --out "$(IOS_ICON_DIR)/Icon-40.png" >/dev/null
	@sips --resampleHeightWidth 80 80 "$(ICON_SRC)" --out "$(IOS_ICON_DIR)/Icon-80.png" >/dev/null
	@sips --resampleHeightWidth 76 76 "$(ICON_SRC)" --out "$(IOS_ICON_DIR)/Icon-76.png" >/dev/null
	@sips --resampleHeightWidth 152 152 "$(ICON_SRC)" --out "$(IOS_ICON_DIR)/Icon-152.png" >/dev/null
	@sips --resampleHeightWidth 167 167 "$(ICON_SRC)" --out "$(IOS_ICON_DIR)/Icon-167.png" >/dev/null
	@sips --resampleHeightWidth 1024 1024 "$(ICON_SRC)" --out "$(IOS_ICON_DIR)/Icon-1024-simple.png" >/dev/null
	@echo "✓ iOS launcher icons generated"

.PHONY: gen-icons-android
gen-icons-android: ## Generate Android mipmap launcher icons from master icon
	@test -f "$(ICON_SRC)" || (echo "✗ Missing $(ICON_SRC)" && exit 1)
	@echo "→ Generating Android launcher icons..."
	@sips --resampleHeightWidth 48 48 "$(ICON_SRC)" --out "$(ANDROID_RES)/mipmap-mdpi/ic_launcher.png" >/dev/null
	@sips --resampleHeightWidth 72 72 "$(ICON_SRC)" --out "$(ANDROID_RES)/mipmap-hdpi/ic_launcher.png" >/dev/null
	@sips --resampleHeightWidth 96 96 "$(ICON_SRC)" --out "$(ANDROID_RES)/mipmap-xhdpi/ic_launcher.png" >/dev/null
	@sips --resampleHeightWidth 144 144 "$(ICON_SRC)" --out "$(ANDROID_RES)/mipmap-xxhdpi/ic_launcher.png" >/dev/null
	@sips --resampleHeightWidth 192 192 "$(ICON_SRC)" --out "$(ANDROID_RES)/mipmap-xxxhdpi/ic_launcher.png" >/dev/null
	@echo "✓ Android launcher icons generated"

# ============================================================================
# QUALITY
# ============================================================================

.PHONY: analyze
analyze: ## Analyze all packages
	@echo "→ Analyzing domain..."
	@cd packages/domain && dart analyze
	@echo "→ Analyzing data..."
	@cd packages/data && $(FVM) analyze
	@echo "→ Analyzing application..."
	@cd packages/application && $(FVM) analyze
	@echo "→ Analyzing design_system..."
	@cd packages/design_system && $(FVM) analyze
	@echo "→ Analyzing presentation..."
	@cd packages/presentation && $(FVM) analyze
	@echo "→ Analyzing app..."
	@cd $(APP_DIR) && $(FVM) analyze
	@echo "✓ All packages analyzed"

.PHONY: format
format: ## Format all Dart files
	@cd packages/domain        && dart format lib test
	@cd packages/data          && dart format lib
	@cd packages/application   && dart format lib
	@cd packages/design_system && dart format lib
	@cd packages/presentation  && dart format lib
	@cd $(APP_DIR)             && dart format lib
	@echo "✓ All files formatted"

.PHONY: lint
lint: format analyze ## Format + analyze all packages

# ============================================================================
# TESTING
# ============================================================================

.PHONY: test
test: ## Run all tests
	@echo "→ domain"
	@cd packages/domain && dart test
	@echo "→ data"
	@cd packages/data && flutter test
	@echo "→ application"
	@cd packages/application && flutter test
	@echo "→ presentation"
	@cd packages/presentation && flutter test
	@echo "→ app"
	@cd app && flutter test
	@echo "✓ All tests passed"

.PHONY: test-verbose
test-verbose: ## Run all tests with verbose output
	@cd packages/domain && dart test --reporter=expanded

.PHONY: test-coverage
test-coverage: ## Run tests with coverage report
	@cd packages/domain && dart test --coverage=coverage
	@echo "✓ Coverage report generated in packages/domain/coverage"

# ============================================================================
# BUILD
# ============================================================================

.PHONY: build-ios
build-ios: ## Build iOS app (release)
	cd $(APP_DIR) && $(FVM) build ios --release
	@echo "✓ iOS build complete"

.PHONY: testflight-check
testflight-check: gen-icons gen-l10n l10n-check analyze test ## Run checks before a TestFlight build
	@echo "✓ TestFlight preflight checks passed"

.PHONY: build-testflight
build-testflight: gen-icons gen-l10n ## Build signed IPA for TestFlight/App Store Connect
	@mkdir -p $(APP_DIR)/build/ios/ipa
	@touch $(APP_DIR)/build/ios/ipa/.build-testflight-start
	cd $(APP_DIR) && $(FVM) build ipa $(IPA_FLAGS)
	@test -n "$$(find $(APP_DIR)/build/ios/ipa -maxdepth 1 -name '*.ipa' -newer $(APP_DIR)/build/ios/ipa/.build-testflight-start -print -quit)" || (echo "✗ IPA export failed. Open $(APP_DIR)/build/ios/archive/Runner.xcarchive in Xcode to resolve signing/export." && exit 1)
	@echo "✓ TestFlight IPA build complete"
	@echo "  IPA: $(APP_DIR)/build/ios/ipa/*.ipa"

.PHONY: build-android
build-android: ## Build Android APK (release)
	cd $(APP_DIR) && $(FVM) build apk --release
	@echo "✓ Android APK build complete"

.PHONY: build-android-aab
build-android-aab: ## Build Android App Bundle (release)
	cd $(APP_DIR) && $(FVM) build appbundle --release
	@echo "✓ Android AAB build complete"

.PHONY: build-macos
build-macos: ## Build macOS app (release)
	cd $(APP_DIR) && $(FVM) build macos --release
	@echo "✓ macOS build complete"

# ============================================================================
# CLEAN
# ============================================================================

.PHONY: clean
clean: ## Clean all build artifacts
	@cd packages/domain        && dart run build_runner clean 2>/dev/null || true
	@cd packages/data          && $(FVM) clean
	@cd packages/application   && $(FVM) clean
	@cd packages/design_system && $(FVM) clean
	@cd packages/presentation  && $(FVM) clean
	@cd $(APP_DIR)             && $(FVM) clean
	@echo "✓ All packages cleaned"

.PHONY: clean-gen
clean-gen: ## Delete all generated files (*.g.dart, *.freezed.dart)
	@find . -name "*.g.dart" -not -path "*/packages/design_system/lib/generated/*" -delete
	@find . -name "*.freezed.dart" -delete
	@echo "✓ Generated files deleted"

.PHONY: reset
reset: clean clean-gen setup gen-all ## Full reset — clean + regenerate everything
	@echo "✓ Full reset complete"

# ============================================================================
# DATABASE
# ============================================================================

.PHONY: db-reset
db-reset: ## Uninstall iOS app to reset SQLite database
	xcrun simctl uninstall booted $(APP_ID)
	@echo "✓ App uninstalled — database cleared"

.PHONY: db-reset-android
db-reset-android: ## Reset database on Android emulator
	adb uninstall $(APP_ID)
	@echo "✓ App uninstalled on Android — database cleared"

# ============================================================================
# SIMULATOR
# ============================================================================

.PHONY: sim-open
sim-open: ## Open iOS Simulator
	open -a Simulator

.PHONY: sim-launch
sim-launch: ## Launch iOS Simulator
	fvm flutter emulators --launch apple_ios_simulator

.PHONY: devices
devices: ## List connected devices
	$(FVM) devices

.PHONY: emulators
emulators: ## List available emulators
	$(FVM) emulators

# ============================================================================
# LOCALIZATION
# ============================================================================

.PHONY: l10n
l10n: gen-l10n ## Alias for gen-l10n

.PHONY: l10n-check
l10n-check: ## Check all ARB files are valid
	@for f in packages/design_system/lib/l10n/*.arb; do \
		python3 -c "import json; json.load(open('$$f'))" && echo "✓ $$f" || echo "✗ $$f INVALID"; \
	done

# ============================================================================
# GIT
# ============================================================================

.PHONY: precommit
precommit: lint test ## Run lint + tests before committing
	@echo "✓ Pre-commit checks passed"

.PHONY: version
version: ## Show Flutter + Dart + Melos versions
	@$(FVM) --version
	@dart --version
	@melos --version
