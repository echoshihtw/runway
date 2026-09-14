// TODO: Replace placeholder keys with your real RevenueCat API keys.
// iOS key:     RevenueCat dashboard → Apps → iOS → Public SDK key
// Android key: RevenueCat dashboard → Apps → Android → Public SDK key
// Entitlement: RevenueCat dashboard → Entitlements → identifier
const kRevenueCatAppleKey = 'appl_zGjlmTUHvOFVPVRrjrHpDXlxZwc';
const kRevenueCatGoogleKey = 'REVENUECAT_GOOGLE_KEY_PLACEHOLDER';
const kProEntitlementId = 'pro';

bool get isRevenueCatConfigured =>
    !kRevenueCatAppleKey.contains('PLACEHOLDER') &&
    !kRevenueCatGoogleKey.contains('PLACEHOLDER');
