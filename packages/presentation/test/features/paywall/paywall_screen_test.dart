import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/paywall/paywall_screen.dart';

/// Riverpod 3 retries a failing provider ten times with backoff — about 38
/// seconds of AsyncLoading before AsyncError — so a test that wants the error
/// state must switch retry off, or two pumps later it is still "Loading".
Duration? _noRetry(int retryCount, Object error) => null;

Future<void> _pumpPaywall(
  WidgetTester tester, {
  Locale? locale,
  Future<ProOffering?> Function()? offering,
  String trigger = 'default',
}) async {
  final container = ProviderContainer(
    retry: _noRetry,
    overrides: [
      proOfferingProvider.overrideWith(
        (ref) => offering == null ? Future.value(null) : offering(),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(child: PaywallScreen(trigger: trigger)),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('links to the Terms of Use and the Privacy Policy', (tester) async {
    await _pumpPaywall(tester);

    expect(find.text('Terms of Use'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
  });

  testWidgets('lists only Pro features that ship', (tester) async {
    await _pumpPaywall(tester);

    expect(find.text('Unlimited entries'), findsOneWidget);
    expect(find.text('Unlimited scenario simulations'), findsOneWidget);
    // Loans are free (#80): selling them as Pro would be a lie in the listing.
    expect(find.text('Unlimited loans'), findsNothing);
    expect(find.text('Cash timeline chart'), findsNothing);
    expect(find.text('Priority support'), findsNothing);
    expect(find.text('Subscriptions tracker'), findsNothing);
  });

  testWidgets('no current offering reads as unavailable, not as a price', (
    tester,
  ) async {
    // fetchOffering returns null when RevenueCat has no offering marked
    // Current — a configuration state, not a product. The screen rendered it
    // under "One-time purchase · Unlock forever" with a disabled button: a
    // price line with no price, which reads as a broken app.
    await _pumpPaywall(tester);

    expect(find.text('One-time purchase · Unlock forever'), findsNothing);
    expect(find.textContaining("Pro isn't available right now"), findsOneWidget);
  });

  testWidgets('a store that cannot be reached says so', (tester) async {
    await _pumpPaywall(tester, offering: () async => throw Exception('offline'));

    expect(find.textContaining("Couldn't reach the store"), findsOneWidget);
    expect(find.text('Price unavailable'), findsNothing);
  });

  testWidgets('the entry paywall says what was used, and how many', (
    tester,
  ) async {
    await _pumpPaywall(tester, trigger: 'entry_limit');
    expect(find.textContaining('5 free entries'), findsOneWidget);
  });

  testWidgets('the simulation paywall says what was used, and how many', (
    tester,
  ) async {
    await _pumpPaywall(tester, trigger: 'simulation');
    expect(find.textContaining('3 free simulations'), findsOneWidget);
  });

  testWidgets('translates the legal links', (tester) async {
    await _pumpPaywall(tester, locale: const Locale('ja'));

    expect(find.text('利用規約'), findsOneWidget);
    expect(find.text('プライバシーポリシー'), findsOneWidget);
  });

  testWidgets('the purchase screen speaks the device language, not English', (
    tester,
  ) async {
    // #96: only the two legal links translated. The title, the feature list,
    // the price line, both buttons and every error were Dart literals.
    await _pumpPaywall(
      tester,
      locale: const Locale('ja'),
      trigger: 'entry_limit',
    );

    expect(find.text('UNLOCK RUNWAY PRO'), findsNothing);
    expect(find.text('Maybe later'), findsNothing);
    expect(find.text('Restore purchase'), findsNothing);
    expect(find.text('Unlimited entries'), findsNothing);
    expect(find.text('RUNWAY PROをアンロック'), findsOneWidget);
    expect(find.text('あとで'), findsOneWidget);
    expect(find.text('購入を復元'), findsOneWidget);
    expect(find.text('記録は無制限'), findsOneWidget);
    expect(
      find.textContaining('5件'),
      findsOneWidget,
      reason: 'the title still says how many were used',
    );
  });

  testWidgets('a subscription-only offering is unavailable, not sold as Pro', (
    tester,
  ) async {
    // _lifetimePackage used to fall back to packages.firstOrNull, so an
    // offering holding only a monthly package rendered an enabled buy button
    // under "one-time purchase" copy and charged for the wrong thing (#17).
    await _pumpPaywall(
      tester,
      offering: () async => const ProOffering(
        identifier: 'default',
        packages: [
          ProPackage(
            identifier: r'$rc_monthly',
            productId: 'com.silverfern.survivaloptimizer.pro.monthly',
            priceString: r'$1.99',
            type: ProPackageType.monthly,
            nativePackage: Object(),
          ),
        ],
      ),
    );

    expect(find.textContaining("Pro isn't available right now"), findsOneWidget);
    expect(find.textContaining(r'$1.99'), findsNothing);
  });
}
