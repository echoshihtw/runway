import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This Month reports what happened; the runway divides by what a month costs.
/// OUT used to add the normalised subscription figure to the logged rows, so a
/// line reading "money that left this month" carried a smoothed projection —
/// and an annual premium contributed a twelfth every month while never
/// appearing in the month it actually left.
class _Transactions implements TransactionRepository {
  _Transactions(this.items);
  final List<Transaction> items;

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
  _Subscriptions(this.items);
  final List<Subscription> items;

  @override
  Stream<List<Subscription>> watchAll() => Stream.value(items);

  @override
  Future<List<Subscription>> getAll() async => items;

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

final _now = DateTime.now();
final _firstOfMonth = DateTime(_now.year, _now.month);

Transaction _tx(String id, TransactionType type, double amount) => Transaction(
  id: id,
  date: _firstOfMonth,
  type: type,
  amount: Money(amount),
  createdAt: _firstOfMonth,
  updatedAt: _firstOfMonth,
);

/// A yearly plan whose anniversary is six months away: it bills in no month
/// near today, so its only contribution is the normalised monthly figure.
Subscription _yearlyPlan() {
  final started = DateTime(_now.year, _now.month - 6, 10);
  return Subscription(
    id: 'sub-1',
    name: 'Adobe',
    category: SubscriptionCategory.personal,
    amount: 12000,
    cycle: BillingCycle.yearly,
    startDate: started,
    nextBillingDate: started,
    createdAt: started,
    updatedAt: started,
  );
}

Future<ProviderContainer> _open({
  required List<Transaction> transactions,
  required List<Subscription> subscriptions,
}) async {
  SharedPreferences.setMockInitialValues({});
  final container = ProviderContainer(
    overrides: [
      transactionRepositoryProvider.overrideWithValue(
        _Transactions(transactions),
      ),
      loanRepositoryProvider.overrideWithValue(_Loans()),
      subscriptionRepositoryProvider.overrideWithValue(
        _Subscriptions(subscriptions),
      ),
      financialSettingsRepositoryProvider.overrideWithValue(_Settings()),
    ],
  );
  addTearDown(container.dispose);
  final listeners = [
    container.listen(transactionsProvider, (_, __) {}),
    container.listen(loansProvider, (_, __) {}),
    container.listen(subscriptionsProvider, (_, __) {}),
  ];
  addTearDown(() {
    for (final l in listeners) {
      l.close();
    }
  });
  await container.read(transactionsProvider.future);
  await container.read(loansProvider.future);
  await container.read(subscriptionsProvider.future);
  await container.read(budgetProvider.future);
  return container;
}

void main() {
  test('OUT counts only money that moved, while the monthly cost keeps the '
      'commitment', () async {
    final container = await _open(
      transactions: [
        _tx('open', TransactionType.openingBalance, 500000),
        _tx('lunch', TransactionType.expense, 2100),
      ],
      subscriptions: [_yearlyPlan()],
    );

    final flow = container.read(thisMonthFlowProvider);
    final burn = container.read(monthlyBurnProvider);

    expect(flow.expenses, 2100, reason: 'only the logged expense moved money');
    expect(
      burn.subscriptions,
      closeTo(1000, 0.01),
      reason: '12,000 a year is 1,000 a month of cover',
    );
    expect(
      burn.total,
      closeTo(3100, 0.01),
      reason: 'the divisor still carries the commitment OUT excludes',
    );
  });

  test('a confirmed subscription charge does count as money that moved', () {
    // The point is not that subscriptions are excluded from OUT, but that only
    // the entry counts. Once a charge is confirmed it is an ordinary outflow.
    final charge = Transaction(
      id: subscriptionChargeId('sub-1', _firstOfMonth),
      date: _firstOfMonth,
      type: TransactionType.subscriptionCharge,
      amount: Money(980),
      createdAt: _firstOfMonth,
      updatedAt: _firstOfMonth,
    );

    return _open(
      transactions: [_tx('open', TransactionType.openingBalance, 500000), charge],
      subscriptions: const [],
    ).then((container) {
      expect(container.read(thisMonthFlowProvider).expenses, 980);
    });
  });
}
