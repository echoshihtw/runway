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
      return RevenueCatService._();
    }
    try {
      final key = Platform.isIOS ? kRevenueCatAppleKey : kRevenueCatGoogleKey;
      await Purchases.setLogLevel(LogLevel.warn);
      final config = PurchasesConfiguration(key);
      await Purchases.configure(config);
      debugPrint('[RevenueCat] Configured');
    } catch (e) {
      debugPrint('[RevenueCat] Init failed: $e');
    }
    return RevenueCatService._();
  }

  RevenueCatService._();

  @override
  Future<ProOffering?> fetchOffering() async {
    if (!isRevenueCatConfigured) return null;
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) return null;
      return ProOffering(
        identifier: current.identifier,
        packages: current.availablePackages.map(_toProPackage).toList(),
      );
    } catch (e) {
      debugPrint('[RevenueCat] fetchOffering error: $e');
      return null;
    }
  }

  @override
  Future<bool> purchasePackage(ProPackage package) async {
    if (!isRevenueCatConfigured) return false;
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
    if (!isRevenueCatConfigured) return false;
    try {
      final info = await Purchases.restorePurchases();
      return info.entitlements.active.containsKey(kProEntitlementId);
    } catch (e) {
      debugPrint('[RevenueCat] restorePurchases error: $e');
      return false;
    }
  }

  @override
  Future<bool> checkProEntitlement() async {
    if (!isRevenueCatConfigured) return false;
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(kProEntitlementId);
    } catch (e) {
      debugPrint('[RevenueCat] checkProEntitlement error: $e');
      return false;
    }
  }

  @override
  Stream<bool> get proEntitlementUpdates {
    if (!isRevenueCatConfigured) return const Stream<bool>.empty();
    late final StreamController<bool> controller;
    void onCustomerInfo(CustomerInfo info) => controller.add(
      info.entitlements.active.containsKey(kProEntitlementId),
    );
    // Registering replays the last known customer info straight away, so a
    // purchase that finished before the listener was attached still arrives.
    controller = StreamController<bool>(
      onListen: () => Purchases.addCustomerInfoUpdateListener(onCustomerInfo),
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
      priceString: pkg.storeProduct.priceString,
      type: type,
      nativePackage: pkg,
    );
  }
}
