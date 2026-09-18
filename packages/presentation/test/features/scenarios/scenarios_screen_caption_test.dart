import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/scenarios/scenarios_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The paywall arrived with no warning: the Plan screen read the simulation
/// count only to feed the gate and never showed it, so the fourth run felt
/// arbitrary even to someone who knew the rule. Count down in the open.
class _Transactions implements TransactionRepository {
  final items = [
    Transaction(
      id: 'ob',
      date: DateTime(2026, 9, 1),
      type: TransactionType.openingBalance,
      amount: Money(34000),
      createdAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    ),
  ];

  @override
  Stream<List<Transaction>> watchAll() => Stream.value(items);

  @override
  Future<List<Transaction>> getAll() async => items;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Loans implements LoanRepository {
  @override
  Stream<List<Loan>> watchAll() => Stream.value(const []);

  @override
  Future<List<Loan>> getAll() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Subscriptions implements SubscriptionRepository {
  @override
  Stream<List<Subscription>> watchAll() => Stream.value(const []);

  @override
  Future<List<Subscription>> getAll() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Settings implements FinancialSettingsRepository {
  @override
  Future<Budget> getBudget() async => const Budget(living: 1100);

  @override
  Future<FinancialAssumptions> getFinancialAssumptions() async =>
      const FinancialAssumptions();

  @override
  Future<RunwayGoal?> getRunwayGoal() async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Count implements UsageCountStore {
  final counts = <String, int>{};

  @override
  Future<int> read(String key) async => counts[key] ?? 0;

  @override
  Future<void> write(String key, int count) async => counts[key] = count;
}

class _FreeTier implements PurchaseService {
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

Future<void> _pump(WidgetTester tester, {required int simulationsRun}) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(_Transactions()),
        loanRepositoryProvider.overrideWithValue(_Loans()),
        subscriptionRepositoryProvider.overrideWithValue(_Subscriptions()),
        financialSettingsRepositoryProvider.overrideWithValue(_Settings()),
        usageCountStoreProvider.overrideWithValue(
          _Count()..counts[UsageKind.simulations.key] = simulationsRun,
        ),
        purchaseServiceProvider.overrideWithValue(_FreeTier()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ScenariosScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the Plan screen says how many free simulations are used', (
    tester,
  ) async {
    await _pump(tester, simulationsRun: 1);

    expect(find.text('1 of 3 free simulations used'), findsOneWidget);
  });

  testWidgets('and is quiet before any is spent', (tester) async {
    await _pump(tester, simulationsRun: 0);

    expect(find.textContaining('free simulations used'), findsNothing);
  });
}
