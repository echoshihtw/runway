import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  @override
  Stream<List<Subscription>> watchAll() => Stream.value(const []);

  @override
  Future<List<Subscription>> getAll() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Transaction _tx(String id, TransactionType type, double amount) {
  final date = DateTime.now().subtract(const Duration(days: 40));
  return Transaction(
    id: id,
    date: date,
    type: type,
    amount: Money(amount),
    createdAt: date,
    updatedAt: date,
  );
}

void main() {
  test('a scenario has input with only a costs override', () {
    expect(const ScenarioState().hasInput, isFalse);
    expect(const ScenarioState(burnRateOverride: 20000).hasInput, isTrue);
    expect(const ScenarioState(simulatedIncome: 5000).hasInput, isTrue);
  });

  test('a costs-only scenario runs and uses the override as monthly costs', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(
          _Transactions([
            _tx('open', TransactionType.openingBalance, 600000),
            _tx('rent', TransactionType.expense, 50000),
          ]),
        ),
        loanRepositoryProvider.overrideWithValue(_Loans()),
        subscriptionRepositoryProvider.overrideWithValue(_Subscriptions()),
      ],
    );
    addTearDown(container.dispose);
    final subscriptions = [
      container.listen(transactionsProvider, (_, __) {}),
      container.listen(loansProvider, (_, __) {}),
      container.listen(subscriptionsProvider, (_, __) {}),
    ];
    addTearDown(() {
      for (final s in subscriptions) {
        s.close();
      }
    });
    await container.read(transactionsProvider.future);
    await container.read(loansProvider.future);
    await container.read(subscriptionsProvider.future);

    final notifier = container.read(scenarioProvider.notifier);
    notifier.setBurnRateOverride(25000);
    await notifier.activate();

    final real = container.read(modelProvider);
    final simulated = container.read(scenarioModelProvider);
    expect(simulated, isNotNull);
    expect(simulated!.effectiveBurnRate, 25000);
    expect(simulated.runwayMonths, greaterThan(real.runwayMonths));
  });
}
