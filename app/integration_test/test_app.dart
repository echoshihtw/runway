import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:data/data.dart';
import 'package:application/application.dart';
import 'package:app/main.dart';

/// Builds the full app wired to an isolated in-memory database.
/// Use this in every integration test instead of calling main().
///
/// Pass [database] to seed data before the app starts; otherwise the app opens
/// an empty database of its own.
Widget buildTestApp({AppDatabase? database}) {
  final db = database ?? AppDatabase.forTesting(NativeDatabase.memory());
  return ProviderScope(
    overrides: [
      analyticsProvider.overrideWithValue(const NoOpAnalytics()),
      transactionRepositoryProvider.overrideWithValue(
        DriftTransactionRepository(db),
      ),
      loanRepositoryProvider.overrideWithValue(DriftLoanRepository(db)),
      subscriptionRepositoryProvider.overrideWithValue(
        DriftSubscriptionRepository(db),
      ),
      financialSettingsRepositoryProvider.overrideWithValue(
        DriftFinancialSettingsRepository(db),
      ),
      // Nothing is bought, counted or prompted for in a test.
      purchaseServiceProvider.overrideWithValue(const _NoPurchases()),
      simulationCountStoreProvider.overrideWithValue(_MemorySimulationCount()),
      reviewPrompterProvider.overrideWithValue(const _NoReviewPrompt()),
    ],
    // The real root widget, so tests see the app's theme and localizations.
    child: const FinancialRunwayApp(),
  );
}

/// Pumps real frames for [seconds].
///
/// The boot sequence navigates on timers rather than animations, so
/// pumpAndSettle returns while the app is still on the boot screen.
Future<void> pumpRealTime(WidgetTester tester, {required int seconds}) async {
  for (var i = 0; i < seconds * 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

class _NoPurchases implements PurchaseService {
  const _NoPurchases();

  @override
  Future<ProOffering?> fetchOffering() async => null;

  @override
  Future<bool> purchasePackage(ProPackage package) async => false;

  @override
  Future<bool> restorePurchases() async => false;

  @override
  Future<bool> checkProEntitlement() async => false;

  @override
  Stream<bool> get proEntitlementUpdates => const Stream<bool>.empty();
}

class _NoReviewPrompt implements ReviewPrompter {
  const _NoReviewPrompt();

  @override
  Future<void> requestReview() async {}
}

class _MemorySimulationCount implements SimulationCountStore {
  int _count = 0;

  @override
  Future<int> read() async => _count;

  @override
  Future<void> write(int count) async {
    _count = count;
  }
}
