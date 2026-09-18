abstract class PurchaseService {
  /// Fetch available offerings. Returns null if unavailable or unconfigured.
  Future<ProOffering?> fetchOffering();

  /// Purchase the given package. Throws [PurchaseException] on failure.
  Future<bool> purchasePackage(ProPackage package);

  /// Restore previous purchases. Returns true if Pro entitlement is active.
  Future<bool> restorePurchases();

  /// Check if the Pro entitlement is currently active server-side.
  Future<bool> checkProEntitlement();

  /// Emits whether the Pro entitlement is active each time purchase data
  /// changes, including purchases completed outside the paywall such as an
  /// offer code redeemed from its URL. Emits nothing when purchases are not
  /// configured on this platform.
  Stream<bool> get proEntitlementUpdates;
}

class ProOffering {
  final String identifier;
  final List<ProPackage> packages;
  const ProOffering({required this.identifier, required this.packages});
}

class ProPackage {
  /// The package's own identifier, such as `$rc_lifetime`.
  final String identifier;

  /// The store product this package sells, such as
  /// `com.silverfern.survivaloptimizer.pro.lifetime`. Carried so a build can
  /// tell whether the offering holds the product it was configured for.
  final String productId;

  final String priceString;
  final ProPackageType type;
  final Object nativePackage;
  const ProPackage({
    required this.identifier,
    required this.productId,
    required this.priceString,
    required this.type,
    required this.nativePackage,
  });
}

enum ProPackageType { monthly, annual, weekly, lifetime, unknown }

class PurchaseException implements Exception {
  final String message;
  final bool userCancelled;
  const PurchaseException(this.message, {this.userCancelled = false});

  @override
  String toString() => 'PurchaseException: $message';
}
