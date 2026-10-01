import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/scenarios/scenarios_screen.dart';
import 'package:presentation/features/transactions/widgets/transaction_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// With no cash the Plan screen said "Go to LOG → + ADD → Opening Balance",
/// naming a control that stopped existing when the add sheet became the preset
/// grid (#134, #135). A new user who reached Plan first was sent to a door
/// that is not there (#153).
class _Transactions implements TransactionRepository {
  /// No opening balance, which is the state this file is about.
  final items = const <Transaction>[];

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
  final items = <Subscription>[];

  @override
  Stream<List<Subscription>> watchAll() => Stream.value(items);

  @override
  Future<List<Subscription>> getAll() async => items;

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


Future<void> _pump(WidgetTester tester, {Locale? locale}) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(_Transactions()),
        loanRepositoryProvider.overrideWithValue(_Loans()),
        subscriptionRepositoryProvider.overrideWithValue(_Subscriptions()),
        financialSettingsRepositoryProvider.overrideWithValue(_Settings()),
        usageCountStoreProvider.overrideWithValue(_Count()),
        purchaseServiceProvider.overrideWithValue(_FreeTier()),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ScenariosScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the stale route is gone', (tester) async {
    await _pump(tester);

    expect(find.textContaining('+ ADD'), findsNothing);
    expect(find.textContaining('Go to LOG'), findsNothing);
    expect(find.text('Add your opening balance first'), findsOneWidget);
  });

  testWidgets('the panel opens the form with the balance already chosen', (
    tester,
  ) async {
    await _pump(tester);

    await tester.ensureVisible(find.text('ADD MY BALANCE'));
    await tester.tap(find.text('ADD MY BALANCE'));
    await tester.pumpAndSettle();

    expect(
      find.byType(TransactionForm),
      findsOneWidget,
      reason: 'the panel should do the thing, not describe a route',
    );
  });

  testWidgets('and says it in the device language', (tester) async {
    await _pump(tester, locale: const Locale('ja'));

    expect(find.text('Add your opening balance first'), findsNothing);
    expect(find.text('まず期初残高を入力してください'), findsOneWidget);
    expect(find.text('RUN SIMULATION'), findsNothing);
  });
}
