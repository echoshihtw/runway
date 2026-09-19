import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/scenarios/scenarios_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The Plan screen's one primary button rendered dimmed as its resting state:
/// before any input, and again after a run, underneath the result it had just
/// produced (#108). And its cost field was called "Monthly costs" two rows
/// under a TOTAL/MO figure that includes subscriptions and loans, while the
/// field itself changes only rent + living (#116).
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
  final items = <Subscription>[];

  @override
  Stream<List<Subscription>> watchAll() => Stream.value(items);

  @override
  Future<List<Subscription>> getAll() async => items;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Settings implements FinancialSettingsRepository {
  _Settings({this.budget = const Budget(living: 1100)});
  final Budget budget;

  @override
  Future<Budget> getBudget() async => budget;

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

Subscription _streaming() => Subscription(
  id: 'tv',
  name: 'TV',
  category: SubscriptionCategory.values.first,
  amount: 503,
  cycle: BillingCycle.monthly,
  startDate: DateTime(2026, 1, 1),
  nextBillingDate: DateTime(2026, 10, 1),
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

Future<void> _pump(
  WidgetTester tester, {
  bool withFixedCosts = false,
  bool noBudget = false,
}) async {
  SharedPreferences.setMockInitialValues({});
  final subscriptions = _Subscriptions();
  if (withFixedCosts) subscriptions.items.add(_streaming());
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(_Transactions()),
        loanRepositoryProvider.overrideWithValue(_Loans()),
        subscriptionRepositoryProvider.overrideWithValue(subscriptions),
        financialSettingsRepositoryProvider.overrideWithValue(
          _Settings(budget: noBudget ? const Budget() : const Budget(living: 1100)),
        ),
        usageCountStoreProvider.overrideWithValue(_Count()),
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

Finder get _costField => find.byType(TextField).first;

void main() {
  _statesWhatItKnows();

  group('#108 the button shows whether it has a job', () {
    // It used to be deleted when disabled, because a faded primary fill read
    // as broken. That left the screen with no primary action at all on a cold
    // open. NeoButton has a real disabled state now, so the button stays and
    // carries the state itself.
    testWidgets('with nothing to run the button is there and dead', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('RUN SIMULATION'), findsOneWidget);
      expect(_runButton(tester).onPressed, isNull);
      expect(find.text('Reset scenario'), findsOneWidget);
    });

    testWidgets('a change makes it live, and running it makes it dead again', (
      tester,
    ) async {
      await _pump(tester);

      await tester.enterText(_costField, '900');
      await tester.pump();
      expect(_runButton(tester).onPressed, isNotNull);

      await tester.ensureVisible(find.text('RUN SIMULATION'));
      await tester.tap(find.text('RUN SIMULATION'));
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      expect(find.text('Projected runway'), findsOneWidget);
      expect(
        _runButton(tester).onPressed,
        isNull,
        reason: 'the result is on screen, so there is nothing left to run',
      );
      expect(find.text('Reset scenario'), findsOneWidget);
    });
  });

  group('#116 the cost field is named for what it changes', () {
    testWidgets('and starts at the current value, not a ghost hint', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('Rent + living / month'), findsOneWidget);
      expect(find.text('Monthly costs'), findsNothing);
      expect(tester.widget<TextField>(_costField).controller!.text, '1100');
    });

    testWidgets('and says what it leaves alone, when there is anything', (
      tester,
    ) async {
      await _pump(tester, withFixedCosts: true);
      expect(find.textContaining('Fixed costs unchanged'), findsOneWidget);
      expect(find.textContaining('503'), findsOneWidget);

      await _pump(tester);
      expect(find.textContaining('Fixed costs unchanged'), findsNothing);
    });

    testWidgets('clearing the field does not snap back to the current value', (
      tester,
    ) async {
      await _pump(tester);

      await tester.enterText(_costField, '');
      await tester.pump();

      expect(tester.widget<TextField>(_costField).controller!.text, '');
    });
  });
}

NeoButton _runButton(WidgetTester tester) => tester.widget<NeoButton>(
  find
      .ancestor(
        of: find.text('RUN SIMULATION'),
        matching: find.byType(NeoButton),
      )
      .first,
);

/// The screen used to state a runway the dashboard refuses to state, and to
/// subtract a sentinel. Audited 2026-09-19 by a CFO, a financial adviser and
/// a product designer; all three found these independently.
void _statesWhatItKnows() {
  testWidgets('with no cost known the runway is an em dash, not infinity', (
    tester,
  ) async {
    // Exactly what onboarding asks for: a balance and nothing else. The
    // dashboard shows "—"; this screen showed ∞ in mint with a STABLE colour
    // one tab away (CONTRACTS §3.1).
    await _pump(tester, noBudget: true);

    expect(find.text('∞'), findsNothing);
    expect(find.text('—'), findsWidgets);
  });
}
