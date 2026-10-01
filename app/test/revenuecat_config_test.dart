import 'package:app/revenuecat_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const appleKey = 'appl_realKey123';
  const googleKey = 'goog_realKey123';
  const placeholder = 'REVENUECAT_GOOGLE_KEY_PLACEHOLDER';

  group('isRevenueCatConfiguredFor', () {
    test('iOS is configured when only the Apple key is set', () {
      expect(
        isRevenueCatConfiguredFor(
          isIOS: true,
          isAndroid: false,
          appleKey: appleKey,
          googleKey: placeholder,
        ),
        isTrue,
      );
    });

    test('Android stays disabled while its key is a placeholder', () {
      expect(
        isRevenueCatConfiguredFor(
          isIOS: false,
          isAndroid: true,
          appleKey: appleKey,
          googleKey: placeholder,
        ),
        isFalse,
      );
    });

    test('both platforms are configured when both keys are set', () {
      for (final isIOS in [true, false]) {
        expect(
          isRevenueCatConfiguredFor(
            isIOS: isIOS,
            isAndroid: !isIOS,
            appleKey: appleKey,
            googleKey: googleKey,
          ),
          isTrue,
        );
      }
    });

    test('neither platform is configured when both keys are placeholders', () {
      for (final isIOS in [true, false]) {
        expect(
          isRevenueCatConfiguredFor(
            isIOS: isIOS,
            isAndroid: !isIOS,
            appleKey: 'APPLE_PLACEHOLDER',
            googleKey: placeholder,
          ),
          isFalse,
        );
      }
    });

    test('an empty key is not set', () {
      expect(isRevenueCatKeySet(''), isFalse);
    });

    test('unsupported platforms are never configured', () {
      expect(
        isRevenueCatConfiguredFor(
          isIOS: false,
          isAndroid: false,
          appleKey: appleKey,
          googleKey: googleKey,
        ),
        isFalse,
      );
    });
  });

  test('the shipped Apple key is set and the shipped Google key is not', () {
    expect(isRevenueCatKeySet(kRevenueCatAppleKey), isTrue);
    expect(isRevenueCatKeySet(kRevenueCatGoogleKey), isFalse);
  });

  group('the store identifiers this build ships', () {
    // These four values have to equal what App Store Connect and RevenueCat
    // hold. A purchase against a mismatched entitlement succeeds and leaves
    // the app locked, so they are pinned here rather than left to a reader.
    test('the entitlement is exactly "pro", not "Pro" or "pro_lifetime"', () {
      expect(kProEntitlementId, 'pro');
    });

    test('the product is the lifetime non-consumable', () {
      expect(kProProductId, 'com.silverfern.survivaloptimizer.pro.lifetime');
    });

    test('the product id is namespaced under the app bundle', () {
      // Not cosmetic: a product id from another app's namespace would import
      // into RevenueCat and then never match a purchase from this build.
      expect(kProProductId, startsWith('com.silverfern.survivaloptimizer.'));
      expect(isRevenueCatKeySet(kProProductId), isTrue);
    });
  });
}
