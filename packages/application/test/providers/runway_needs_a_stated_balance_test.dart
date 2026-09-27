import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A commitment can be entered before any balance, and nothing stops it. What
/// must not happen is the runway answering anyway.
///
/// Summing an empty ledger gives zero, which is a figure, so the engine used to
/// divide it by the new monthly cost and print 0 MONTHS at critical. A loan was
/// worse: its principal lands as cash, so a loan entered first read as a
/// healthy runway built on the assumption that the owner started at nothing.
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
  _Loans(this.items);
  final List<Loan> items;

  @override
  Stream<List<Loan>> watchAll() => Stream.value(items);

  @override
  Future<List<Loan>> getAll() async => items;

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

class _MemoryStore implements UsageCountStore {
  final counts = <String, int>{};

  @override
  Future<int> read(String key) async => counts[key] ?? 0;

  @override
  Future<void> write(String key, int count) async => counts[key] = count;
}

final _when = DateTime.now().subtract(const Duration(days: 40));

Transaction _tx(String id, TransactionType type, double amount) => Transaction(
  id: id,
  date: _when,
  type: type,
  amount: Money(amount),
  createdAt: _when,
  updatedAt: _when,
);

Subscription _sub(double monthly) => Subscription(
  id: 's1',
  name: 'plan',
  amount: monthly,
  cycle: BillingCycle.monthly,
  category: SubscriptionCategory.personal,
  startDate: _when,
  nextBillingDate: DateTime.now().add(const Duration(days: 20)),
  createdAt: _when,
  updatedAt: _when,
);

Loan _loan(double principal, double payment) => Loan(
  id: 'l1',
  name: 'bank',
  source: 'bank',
  originalAmount: principal,
  monthlyPayment: payment,
  originalTermMonths: 12,
  startDate: _when,
  createdAt: _when,
  updatedAt: _when,
);

Future<ModelState> _model({
  List<Transaction> transactions = const [],
  List<Subscription> subscriptions = const [],
  List<Loan> loans = const [],
}) async {
  SharedPreferences.setMockInitialValues({});
  final container = ProviderContainer(
    overrides: [
      transactionRepositoryProvider.overrideWithValue(
        _Transactions(transactions),
      ),
      loanRepositoryProvider.overrideWithValue(_Loans(loans)),
      subscriptionRepositoryProvider.overrideWithValue(
        _Subscriptions(subscriptions),
      ),
      usageCountStoreProvider.overrideWithValue(_MemoryStore()),
    ],
  );
  addTearDown(container.dispose);
  final subs = [
    container.listen(transactionsProvider, (_, _) {}),
    container.listen(loansProvider, (_, _) {}),
    container.listen(subscriptionsProvider, (_, _) {}),
  ];
  addTearDown(() {
    for (final s in subs) {
      s.close();
    }
  });
  await container.read(transactionsProvider.future);
  await container.read(loansProvider.future);
  await container.read(subscriptionsProvider.future);
  return container.read(modelProvider);
}

void main() {
  test('a subscription entered before any balance withholds the runway', () async {
    final model = await _model(subscriptions: [_sub(1000)]);

    expect(model.subscriptionMonthlyCost, greaterThan(0));
    expect(model.hasCostBasis, isTrue, reason: 'the cost is real');
    expect(model.cashIsKnown, isFalse, reason: 'no balance was ever stated');
    expect(
      model.runwayIsKnown,
      isFalse,
      reason: 'it used to read 0 MONTHS at critical, from a cash total of zero',
    );
  });

  test('a loan entered before any balance withholds the runway', () async {
    final model = await _model(
      transactions: [_tx('drawdown', TransactionType.loan, 12000)],
      loans: [_loan(12000, 1000)],
    );

    expect(model.hasCostBasis, isTrue, reason: 'the payment is real');
    expect(model.cashIsKnown, isFalse, reason: 'a drawdown is not a balance');
    expect(
      model.runwayIsKnown,
      isFalse,
      reason: 'it used to read a healthy runway made of borrowed money alone',
    );
  });

  test('stating the balance is what answers it', () async {
    final model = await _model(
      transactions: [_tx('open', TransactionType.openingBalance, 600000)],
      subscriptions: [_sub(1000)],
    );

    expect(model.cashIsKnown, isTrue);
    expect(model.runwayIsKnown, isTrue);
    expect(model.runwayMonths, greaterThan(0));
  });
}
