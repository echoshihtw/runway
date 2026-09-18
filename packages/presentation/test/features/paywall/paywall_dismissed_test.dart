import 'dart:async';

import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/paywall/paywall_screen.dart';

/// The purchase path (#95 item 1): the finally blocks checked mounted, the
/// catch blocks did not. Start a purchase, dismiss the sheet, and StoreKit's
/// error arrives at a State that no longer exists.
class _HangingStore implements PurchaseService {
  final purchase = Completer<bool>();

  static const _pkg = ProPackage(
    identifier: 'pro',
    priceString: r'$4.99',
    type: ProPackageType.lifetime,
    nativePackage: Object(),
  );

  @override
  Stream<bool> get proEntitlementUpdates => const Stream<bool>.empty();

  @override
  Future<bool> checkProEntitlement() async => false;

  @override
  Future<ProOffering?> fetchOffering() async =>
      const ProOffering(identifier: 'default', packages: [_pkg]);

  @override
  Future<bool> purchasePackage(ProPackage package) => purchase.future;

  @override
  Future<bool> restorePurchases() async => false;
}

void main() {
  testWidgets('a store error that lands after the sheet is gone does nothing', (
    tester,
  ) async {
    final store = _HangingStore();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [purchaseServiceProvider.overrideWithValue(store)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: PaywallScreen(trigger: 'default'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('UNLOCK RUNWAY PRO'));
    await tester.pump();

    await tester.pumpWidget(const SizedBox());
    store.purchase.completeError(const PurchaseException('declined'));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
