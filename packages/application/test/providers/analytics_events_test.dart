import 'dart:async';
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
  Future<void> logChangeLanguage(Locale locale) async =>
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

/// Never answers: a slow network, or a call that hangs.
class _Hangs extends NoOpAnalytics {
  final _never = Completer<void>().future;

  @override
  Future<void> logAddTransaction(TransactionType type) => _never;

  @override
  Future<void> logRunSimulation({
    bool hasBurnOverride = false,
    bool hasIncome = false,
  }) => _never;

  @override
  Future<void> logChangeLanguage(Locale locale) => _never;

  @override
  Future<void> logChangeCurrency(String code) => _never;
}

(ProviderContainer, _Analytics) _container({
  _Ledger? ledger,
  AnalyticsService? analytics,
}) {
  final recorder = _Analytics();
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      analyticsProvider.overrideWithValue(analytics ?? recorder),
      transactionRepositoryProvider.overrideWithValue(ledger ?? _Ledger()),
      usageCountStoreProvider.overrideWithValue(_MemoryStore()),
    ],
  );
  addTearDown(container.dispose);
  return (container, recorder);
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

  group('analytics that never answers', () {
    // Analytics is ours; the save, the count and the setting are the user's.
    const soon = Duration(seconds: 1);

    test('neither holds a save nor skips its count', () async {
      final (container, _) = _container(analytics: _Hangs());

      await container
          .read(addTransactionUseCaseProvider)
          .execute(_entry(TransactionType.expense))
          .timeout(soon);

      expect(await container.read(entryCountProvider.future), 1);
    });

    test('neither holds a simulation nor skips its count', () async {
      final (container, _) = _container(analytics: _Hangs());
      final scenario = container.read(scenarioProvider.notifier);

      scenario.setSimulatedIncome(3000);
      await scenario.activate().timeout(const Duration(seconds: 2));

      expect(await container.read(simulationCountProvider.future), 1);
    });

    test('holds neither a language nor a currency choice', () async {
      final (container, _) = _container(analytics: _Hangs());
      await container.read(localeProvider.future);
      await container.read(currencyProvider.future);

      await container
          .read(localeProvider.notifier)
          .setLocale(const Locale('ja'))
          .timeout(soon);
      await container
          .read(currencyProvider.notifier)
          .setCurrency(supportedCurrencies[2])
          .timeout(soon);
    });
  });

  test(
    'choosing the language or currency already in use is not a change',
    () async {
      final (container, analytics) = _container();
      await container.read(localeProvider.future);
      await container.read(currencyProvider.future);
      final locale = container.read(localeProvider.notifier);
      final currency = container.read(currencyProvider.notifier);

      await locale.setLocale(const Locale('zh', 'TW'));
      await locale.setLocale(const Locale('zh', 'TW'));
      await currency.setCurrency(supportedCurrencies[1]);
      await currency.setCurrency(supportedCurrencies[1]);

      expect(analytics.events, [
        'change_language:zh_TW',
        'change_currency:TWD',
      ]);
    },
  );
}
