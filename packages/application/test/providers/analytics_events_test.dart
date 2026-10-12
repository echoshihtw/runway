import 'dart:ui';

import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Each event fires once, after the action it names has landed, and never
/// for an action that was refused or abandoned.
class _Analytics extends NoOpAnalytics {
  final events = <String>[];

  @override
  Future<void> logAddTransaction(TransactionType type) async =>
      events.add('add_transaction:${type.name}');

  @override
  Future<void> logRepayLoan() async => events.add('repay_loan');

  @override
  Future<void> logRunSimulation({
    bool hasBurnOverride = false,
    bool hasIncome = false,
  }) async => events.add('run_simulation:$hasBurnOverride,$hasIncome');

  @override
  Future<void> logChangeLanguage(Locale? locale) async =>
      events.add('change_language:$locale');

  @override
  Future<void> logChangeCurrency(String code) async =>
      events.add('change_currency:$code');
}

class _Ledger implements TransactionRepository {
  bool refuses = false;

  @override
  Future<void> add(Transaction transaction) async {
    if (refuses) throw Exception('disk is full');
  }

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

Transaction _entry(TransactionType type, {double amount = 980}) {
  final now = DateTime(2026, 10, 12);
  return Transaction(
    id: 'tx-${type.name}',
    date: now,
    type: type,
    amount: Money(amount),
    createdAt: now,
    updatedAt: now,
  );
}

(ProviderContainer, _Analytics) _container({_Ledger? ledger}) {
  final analytics = _Analytics();
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      analyticsProvider.overrideWithValue(analytics),
      transactionRepositoryProvider.overrideWithValue(ledger ?? _Ledger()),
      usageCountStoreProvider.overrideWithValue(_MemoryStore()),
    ],
  );
  addTearDown(container.dispose);
  return (container, analytics);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('a saved entry', () {
    test('is one add_transaction carrying its type', () async {
      final (container, analytics) = _container();

      for (final type in [
        TransactionType.expense,
        TransactionType.openingBalance,
        TransactionType.subscriptionCharge,
      ]) {
        await container
            .read(addTransactionUseCaseProvider)
            .execute(_entry(type));
      }

      expect(analytics.events, [
        'add_transaction:expense',
        'add_transaction:openingBalance',
        'add_transaction:subscriptionCharge',
      ]);
    });

    test('that repays a loan is one repay_loan', () async {
      final (container, analytics) = _container();

      await container
          .read(addTransactionUseCaseProvider)
          .execute(_entry(TransactionType.repayment));

      expect(analytics.events, ['repay_loan']);
    });

    test('that was refused is not counted', () async {
      final (container, analytics) = _container(
        ledger: _Ledger()..refuses = true,
      );
      final add = container.read(addTransactionUseCaseProvider);

      await expectLater(
        add.execute(_entry(TransactionType.expense)),
        throwsA(anything),
      );
      await expectLater(
        add.execute(_entry(TransactionType.expense, amount: 0)),
        throwsA(isA<InvalidTransactionFailure>()),
      );

      expect(analytics.events, isEmpty);
    });
  });

  group('a simulation', () {
    test(
      'that shows its result is one run_simulation with its flags',
      () async {
        final (container, analytics) = _container();
        final scenario = container.read(scenarioProvider.notifier);

        scenario.setSimulatedIncome(3000);
        await scenario.activate();

        expect(analytics.events, ['run_simulation:false,true']);
      },
    );

    test('reset before its result is not counted', () async {
      final (container, analytics) = _container();
      final scenario = container.read(scenarioProvider.notifier);

      scenario.setBurnRateOverride(1200);
      final running = scenario.activate();
      scenario.reset();
      await running;

      expect(analytics.events, isEmpty);
    });
  });

  test('choosing a language is one change_language', () async {
    final (container, analytics) = _container();
    await container.read(localeProvider.future);

    await container
        .read(localeProvider.notifier)
        .setLocale(const Locale('zh', 'TW'));

    expect(analytics.events, ['change_language:zh_TW']);
  });

  test('choosing a currency is one change_currency', () async {
    final (container, analytics) = _container();
    await container.read(currencyProvider.future);

    await container
        .read(currencyProvider.notifier)
        .setCurrency(supportedCurrencies[1]);

    expect(analytics.events, ['change_currency:TWD']);
  });
}
