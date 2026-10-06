import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:application/application.dart';
import 'revenuecat_config.dart';

class RevenueCatService implements PurchaseService {
  static Future<RevenueCatService> init() async {
    if (!isRevenueCatConfigured) {
      debugPrint('[RevenueCat] Placeholder keys detected — skipping init');
      return RevenueCatService.unconfigured(
        'RevenueCat keys are placeholders on this platform.',
      );
    }
    try {
      final key = Platform.isIOS ? kRevenueCatAppleKey : kRevenueCatGoogleKey;
      await Purchases.setLogLevel(LogLevel.warn);
      final config = PurchasesConfiguration(key);
      await Purchases.configure(config);
      debugPrint('[RevenueCat] Configured');
    } catch (e) {
      debugPrint('[RevenueCat] Init failed: $e');
      return RevenueCatService.unconfigured(
        'RevenueCat failed to configure: $e',
      );
    }
    return RevenueCatService._();
  }

  RevenueCatService._() : _unavailable = null;

  /// A service that cannot talk to the store, and says why when asked to.
  ///
  /// `init()` used to swallow a failed `configure` and hand back a service
  /// indistinguishable from a working one, whose `fetchOffering` then
  /// returned null. The paywall rendered that as a price line with no price,
  /// and purchases were silently impossible.
  @visibleForTesting
  RevenueCatService.unconfigured(String reason) : _unavailable = reason;

  /// Why the store is unreachable, or null when it is not.
  final String? _unavailable;

  @override
  Future<ProOffering?> fetchOffering() async {
    if (_unavailable != null) throw StateError(_unavailable);
    // A failed call propagates to the provider as an error, so the paywall
    // can say the store could not be reached. Swallowing it to null made that
    // indistinguishable from "nothing is on sale".
    final offerings = await Purchases.getOfferings();
    final current = offerings.current;
    if (current == null) return null;
    final mapped = current.availablePackages.map(_toProPackage);
    // The dashboard can be reconfigured without the app changing, so the
    // product this build expects goes first and cannot lose a tie to another
    // lifetime package. The assert makes a mismatch loud in development
    // rather than a wrong sale in production.
    final expected = mapped.where((p) => p.productId == kProProductId);
    final others = mapped.where((p) => p.productId != kProProductId);
    assert(
      expected.isNotEmpty,
      'RevenueCat offering "${current.identifier}" does not hold '
      '$kProProductId. It offers: '
      '${mapped.map((p) => p.productId).join(', ')}',
    );
    return ProOffering(
      identifier: current.identifier,
      packages: [...expected, ...others],
    );
  }

  @override
  Future<bool> purchasePackage(ProPackage package) async {
    if (_unavailable != null) throw PurchaseException(_unavailable);
    try {
      final nativePkg = package.nativePackage as Package;
      final result = await Purchases.purchase(PurchaseParams.package(nativePkg));
      return result.customerInfo.entitlements.active
          .containsKey(kProEntitlementId);
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        throw const PurchaseException('Cancelled', userCancelled: true);
      }
      throw PurchaseException(e.message ?? e.toString());
    } catch (e) {
      throw PurchaseException(e.toString());
    }
  }

  @override
  Future<bool> restorePurchases() async {
    // Returning false here read as "No previous purchase found" on a store
    // that was never reached.
    if (_unavailable != null) throw PurchaseException(_unavailable);
    try {
      final info = await Purchases.restorePurchases();
      return info.entitlements.active.containsKey(kProEntitlementId);
    } catch (e) {
      debugPrint('[RevenueCat] restorePurchases error: $e');
      return false;
    }
  }

  /// Whether the store currently recognises the Pro entitlement.
  ///
  /// Two failures that look alike and are not. **No store at all** answers no,
  /// which is honest: there is nothing configured to hold an entitlement, and
  /// nothing to listen to afterwards. **A store that cannot answer** throws,
  /// because the caller treats that as offline and keeps whatever the owner
  /// already paid for.
  ///
  /// This used to swallow the second into the first and return false. The
  /// provider's guard for it — "only a store that answers may revoke" — was
  /// therefore unreachable in production, and a single failed call revoked a
  /// paying owner's Pro and wrote that to disk for the next launch as well.
  @override
  Future<bool> checkProEntitlement() async {
    if (_unavailable != null) return false;
    final info = await Purchases.getCustomerInfo();
    return info.entitlements.active.containsKey(kProEntitlementId);
  }

  @override
  Stream<bool> get proEntitlementUpdates {
    if (_unavailable != null) return const Stream<bool>.empty();
    late final StreamController<bool> controller;
    void onCustomerInfo(CustomerInfo info) => controller.add(
      info.entitlements.active.containsKey(kProEntitlementId),
    );
    // Registering replays the last known customer info straight away, so a
    // purchase that finished before the listener was attached still arrives.
    controller = StreamController<bool>(
      onListen: () {
        try {
          Purchases.addCustomerInfoUpdateListener(onCustomerInfo);
        } catch (e) {
          debugPrint('[RevenueCat] listener error: $e');
        }
      },
      onCancel: () =>
          Purchases.removeCustomerInfoUpdateListener(onCustomerInfo),
    );
    return controller.stream;
  }

  ProPackage _toProPackage(Package pkg) {
    final type = switch (pkg.packageType) {
      PackageType.monthly  => ProPackageType.monthly,
      PackageType.annual   => ProPackageType.annual,
      PackageType.weekly   => ProPackageType.weekly,
      PackageType.lifetime => ProPackageType.lifetime,
      _                    => ProPackageType.unknown,
    };
    return ProPackage(
      identifier: pkg.identifier,
      productId: pkg.storeProduct.identifier,
      priceString: pkg.storeProduct.priceString,
      type: type,
      nativePackage: pkg,
    );
  }
}
