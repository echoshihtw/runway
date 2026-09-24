import 'dart:io';

// Everything the store side is identified by, in one place. Each value is a
// compile-time constant that a build can override with --dart-define, so a
// test build or a renamed product needs no code edit:
//
//   flutter build ipa --dart-define=PRO_PRODUCT_ID=com.example.pro
//
// Public SDK keys are designed to ship in the app.
// iOS key:     RevenueCat dashboard → Apps → iOS → Public SDK key
// Android key: RevenueCat dashboard → Apps → Android → Public SDK key
// Entitlement: RevenueCat dashboard → Entitlements → identifier
// Product:     App Store Connect → In-App Purchases → Product ID, which the
//              RevenueCat product must import under the same id.
// TODO: Replace the Android placeholder with the real Google Play public SDK key.
const kRevenueCatAppleKey = String.fromEnvironment(
  'REVENUECAT_APPLE_KEY',
  defaultValue: 'appl_zGjlmTUHvOFVPVRrjrHpDXlxZwc',
);
const kRevenueCatGoogleKey = String.fromEnvironment(
  'REVENUECAT_GOOGLE_KEY',
  defaultValue: 'REVENUECAT_GOOGLE_KEY_PLACEHOLDER',
);
const kProEntitlementId = String.fromEnvironment(
  'PRO_ENTITLEMENT_ID',
  defaultValue: 'pro',
);

/// The non-consumable that grants [kProEntitlementId].
///
/// The original `…pro` could not be reused after its App Store Connect record
/// was deleted, which is why this reads `.pro.lifetime` (#17). Keep it equal
/// to the product id in App Store Connect and RevenueCat.
const kProProductId = String.fromEnvironment(
  'PRO_PRODUCT_ID',
  defaultValue: 'com.silverfern.survivaloptimizer.pro.lifetime',
);

/// Whether [key] is a real RevenueCat key rather than an empty or placeholder
/// value.
bool isRevenueCatKeySet(String key) =>
    key.isNotEmpty && !key.contains('PLACEHOLDER');

/// Whether RevenueCat can run on a platform. Each platform only needs its own
/// key, so iOS purchases work while the Android key is still a placeholder.
bool isRevenueCatConfiguredFor({
  required bool isIOS,
  required bool isAndroid,
  String appleKey = kRevenueCatAppleKey,
  String googleKey = kRevenueCatGoogleKey,
}) {
  if (isIOS) return isRevenueCatKeySet(appleKey);
  if (isAndroid) return isRevenueCatKeySet(googleKey);
  return false;
}

bool get isRevenueCatConfigured => isRevenueCatConfiguredFor(
  isIOS: Platform.isIOS,
  isAndroid: Platform.isAndroid,
);
