import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/paywall/paywall_screen.dart';

/// The one screen where the app takes money. It is a bottom sheet with no
/// height cap and no scroll view, which is the fault the subscription sheet
/// had before #168 and both loan sheets had before #176.
class _NoStore implements PurchaseService {
  @override
  Stream<bool> get proEntitlementUpdates => const Stream<bool>.empty();
  @override
  Future<bool> checkProEntitlement() async => false;
  @override
  Future<ProOffering?> fetchOffering() async => null;
  @override
  Future<bool> purchasePackage(ProPackage package) async => false;
  @override
  Future<bool> restorePurchases() async => false;
}

Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  required double scale,
  String trigger = 'entry_limit',
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [purchaseServiceProvider.overrideWithValue(_NoStore())],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(body: PaywallScreen(trigger: trigger)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('it fits a small phone', (tester) async {
    await _pump(tester, size: const Size(320, 568), scale: 1.0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('and fits with the text size turned up', (tester) async {
    await _pump(tester, size: const Size(320, 568), scale: 1.5);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the way to decline is reachable', (tester) async {
    await _pump(tester, size: const Size(320, 568), scale: 1.5);
    await tester.ensureVisible(find.text('Maybe later'));
    expect(tester.takeException(), isNull);
  });
}
