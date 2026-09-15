import 'dart:io';

// RevenueCat public SDK keys. Public SDK keys are designed to ship in the app.
// iOS key:     RevenueCat dashboard → Apps → iOS → Public SDK key
// Android key: RevenueCat dashboard → Apps → Android → Public SDK key
// Entitlement: RevenueCat dashboard → Entitlements → identifier
// TODO: Replace the Android placeholder with the real Google Play public SDK key.
const kRevenueCatAppleKey = 'appl_zGjlmTUHvOFVPVRrjrHpDXlxZwc';
const kRevenueCatGoogleKey = 'REVENUECAT_GOOGLE_KEY_PLACEHOLDER';
const kProEntitlementId = 'pro';

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
