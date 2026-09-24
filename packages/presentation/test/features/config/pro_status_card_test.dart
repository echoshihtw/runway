import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/config/widgets/pro_status_card.dart';
import 'package:presentation/product_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pro was only ever read to hide something, so nothing in the app said you
/// had it, and the one route to Restore purchase was spending an allowance
/// first.
class _Store implements PurchaseService {
  _Store({required this.isPro});

  final bool isPro;

  @override
  Stream<bool> get proEntitlementUpdates => const Stream<bool>.empty();
  @override
  Future<bool> checkProEntitlement() async => isPro;
  @override
  Future<ProOffering?> fetchOffering() async => null;
  @override
  Future<bool> purchasePackage(ProPackage package) async => false;
  @override
  Future<bool> restorePurchases() async => false;
}

class _Counts implements UsageCountStore {
  _Counts(this.counts);

  final Map<String, int> counts;

  @override
  Future<int> read(String key) async => counts[key] ?? 0;
  @override
  Future<void> write(String key, int count) async => counts[key] = count;
}

Future<void> _pump(
  WidgetTester tester, {
  required bool isPro,
  Map<String, int> counts = const {},
}) async {
  SharedPreferences.setMockInitialValues({'is_pro': isPro});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        purchaseServiceProvider.overrideWithValue(_Store(isPro: isPro)),
        usageCountStoreProvider.overrideWithValue(_Counts({...counts})),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SingleChildScrollView(child: ProStatusCard()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('an owner is told they have it', (tester) async {
    await _pump(tester, isPro: true);
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.text(l10n.proUnlocked), findsOneWidget);
    // Nothing to buy, and no allowance to report: both would read as a doubt
    // about a purchase that has already gone through.
    expect(find.text(l10n.paywallUnlock), findsNothing);
    expect(find.textContaining('free entries'), findsNothing);
  });

  testWidgets('the paywall is reachable with nothing spent', (tester) async {
    // The point of the card. showPaywall had one caller, the gate, so Restore
    // purchase was only offered once an allowance was gone. An owner on a new
    // phone has a full allowance and a purchase to restore.
    await _pump(tester, isPro: false);
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.text(l10n.paywallUnlock), findsOneWidget);
    expect(find.text(l10n.proUnlocked), findsNothing);
  });

  testWidgets('the card changes the moment the purchase lands', (tester) async {
    // The whole point of the card, and the one thing reading instead of
    // watching breaks: isProOwner uses ref.read, which is right for a tap
    // handler and wrong in a build. With it, you buy Pro from this card and the
    // card that offered it goes on saying you have not.
    SharedPreferences.setMockInitialValues({'is_pro': false});
    final container = ProviderContainer(
      overrides: [
        purchaseServiceProvider.overrideWithValue(_Store(isPro: false)),
        usageCountStoreProvider.overrideWithValue(_Counts({})),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: ThemeData.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(child: ProStatusCard()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.proUnlocked), findsNothing);

    await container.read(entitlementProvider.notifier).unlockPro();
    await tester.pumpAndSettle();

    expect(find.text(l10n.proUnlocked), findsOneWidget);
    expect(find.text(l10n.paywallUnlock), findsNothing);
  });

  testWidgets('what is left is stated in the words the gates use', (
    tester,
  ) async {
    await _pump(
      tester,
      isPro: false,
      counts: {UsageKind.entries.key: 3, UsageKind.simulations.key: 1},
    );
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    expect(
      find.text(l10n.freeEntriesUsed(3, ProductConfig.freeEntries)),
      findsOneWidget,
    );
    expect(
      find.text(l10n.freeSimulationsUsed(1, ProductConfig.freeSimulations)),
      findsOneWidget,
    );
  });
}
