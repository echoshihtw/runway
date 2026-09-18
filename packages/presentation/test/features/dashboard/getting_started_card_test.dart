import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:presentation/features/dashboard/widgets/getting_started_card.dart';
import 'package:presentation/features/transactions/widgets/transaction_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// "Log your first expense" navigated to the Log tab and stopped, leaving a
/// new user to find the + button on their own. The step is the instruction;
/// tapping it should do the thing — open the grid, right here, so the number
/// moves on the screen they are looking at.
class _Transactions implements TransactionRepository {
  @override
  Stream<List<Transaction>> watchAll() => Stream.value(const []);

  @override
  Future<List<Transaction>> getAll() async => const [];

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

class _Settings implements FinancialSettingsRepository {
  @override
  Future<Budget> getBudget() async => const Budget();

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

/// The card lives on the dashboard inside a real router, so `context.go` has
/// somewhere to go: a red here means "it navigated away", not a missing router.
Future<GoRouter> _pump(WidgetTester tester, {Locale? locale}) async {
  SharedPreferences.setMockInitialValues({});
  final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(
        path: '/dashboard',
        builder: (_, __) => const Scaffold(
          body: SingleChildScrollView(child: GettingStartedCard()),
        ),
      ),
      GoRoute(
        path: '/transactions',
        builder: (_, __) => const Scaffold(body: Text('LOG TAB')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(_Transactions()),
        loanRepositoryProvider.overrideWithValue(_Loans()),
        financialSettingsRepositoryProvider.overrideWithValue(_Settings()),
        usageCountStoreProvider.overrideWithValue(_Count()),
        purchaseServiceProvider.overrideWithValue(_FreeTier()),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('"Log your first expense" opens the grid, right here', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.text('Log your first expense'), findsOneWidget);

    await tester.tap(find.text('Log your first expense'));
    await tester.pumpAndSettle();

    expect(
      find.text('WHAT DID YOU SPEND ON?'),
      findsOneWidget,
      reason: 'the step is the instruction; tapping it should do the thing',
    );
    expect(
      find.text('LOG TAB'),
      findsNothing,
      reason: 'the number should move on the screen the user is looking at',
    );
  });

  testWidgets('"Add your cash balance" opens the form with the balance chosen', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.text('Add your cash balance'));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionForm), findsOneWidget);
    expect(find.text('LOG TAB'), findsNothing);
  });

  testWidgets('the card speaks the device language, not English', (
    tester,
  ) async {
    // #96: the seven ARBs already carried stepBalanceLabel, stepBudgetHint,
    // gettingStarted and stepsComplete, unused, while the card drew its own
    // English. Wiring, not authoring.
    await _pump(tester, locale: const Locale('ja'));

    expect(find.text('GETTING STARTED'), findsNothing);
    expect(find.text('Add your cash balance'), findsNothing);
    expect(find.text('はじめに'), findsOneWidget);
    expect(find.text('残高を追加する'), findsOneWidget);
    expect(find.text('4中0完了'), findsOneWidget);
    expect(find.text('OPTIONAL'), findsNothing);
  });
}
