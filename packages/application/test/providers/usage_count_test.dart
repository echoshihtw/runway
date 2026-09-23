import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for the Keychain. One instance plays the device across restarts.
class _MemoryStore implements UsageCountStore {
  final counts = <String, int>{};

  @override
  Future<int> read(String key) async => counts[key] ?? 0;

  @override
  Future<void> write(String key, int count) async => counts[key] = count;
}

class _ThrowingStore implements UsageCountStore {
  @override
  Future<int> read(String key) async => throw Exception('keychain locked');

  @override
  Future<void> write(String key, int count) async =>
      throw Exception('keychain locked');
}

class _Ledger implements TransactionRepository {
  final items = <Transaction>[];

  @override
  Future<void> add(Transaction transaction) async => items.add(transaction);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Transaction _entry(TransactionType type) {
  final now = DateTime(2026, 9, 18);
  return Transaction(
    id: 'tx-${type.name}',
    date: now,
    type: type,
    amount: Money(980),
    createdAt: now,
    updatedAt: now,
  );
}

ProviderContainer _container(UsageCountStore store, {TransactionRepository? ledger}) {
  final container = ProviderContainer(
    // A throwing store would otherwise be retried for ~38 s.
    retry: (_, _) => null,
    overrides: [
      usageCountStoreProvider.overrideWithValue(store),
      transactionRepositoryProvider.overrideWithValue(ledger ?? _Ledger()),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('one more needs Pro exactly at the allowance, never for Pro', () {
    for (final used in [0, 1, 2]) {
      expect(needsPro(isPro: false, used: used, free: 3), isFalse);
    }
    expect(needsPro(isPro: false, used: 3, free: 3), isTrue);
    expect(needsPro(isPro: false, used: 4, free: 5), isFalse);
    expect(needsPro(isPro: false, used: 5, free: 5), isTrue);
    expect(needsPro(isPro: true, used: 500, free: 5), isFalse);
  });

  test('the two counters are separate keys in one store', () {
    expect(UsageKind.entries.key, isNot(UsageKind.simulations.key));
    // These are Keychain item names on real devices. Renaming one forgets
    // every count ever recorded under it.
    expect(UsageKind.entries.key, 'entries_logged');
    expect(UsageKind.simulations.key, 'simulations_run');
  });

  group('each count', () {
    for (final (kind, provider) in [
      (UsageKind.entries, entryCountProvider),
      (UsageKind.simulations, simulationCountProvider),
    ]) {
      test('${kind.name}: starts at zero and survives a restart', () async {
        final device = _MemoryStore();
        final first = _container(device);
        expect(await first.read(provider.future), 0);

        await first.read(provider.notifier).increment();
        await first.read(provider.notifier).increment();
        expect(first.read(provider).value, 2);

        final afterRestart = _container(device);
        expect(await afterRestart.read(provider.future), 2);
        expect(device.counts, {kind.key: 2});
      });

      test('${kind.name}: Delete all data leaves it alone', () async {
        final device = _MemoryStore()..counts[kind.key] = 4;
        expect(await _container(device).read(provider.future), 4);
      });
    }
  });

  group('simulations', () {
    test('running one adds one to the count', () async {
      final device = _MemoryStore();
      final container = _container(device);
      final keepAlive = container.listen(simulationCountProvider, (_, _) {});
      addTearDown(keepAlive.close);
      await container.read(simulationCountProvider.future);

      container.read(scenarioProvider.notifier).setBurnRateOverride(20000);
      await container.read(scenarioProvider.notifier).activate();

      expect(container.read(scenarioProvider).isActive, isTrue);
      expect(device.counts[UsageKind.simulations.key], 1);
    });

    test('a failed count write does not lose the simulation', () async {
      // The result is the user's; the count is ours. activate() awaited the
      // increment last and the screen does not await activate(), so a
      // Keychain refusal was an unhandled error.
      final container = _container(_ThrowingStore());
      container.read(scenarioProvider.notifier).setBurnRateOverride(20000);

      await container.read(scenarioProvider.notifier).activate();

      expect(container.read(scenarioProvider).isActive, isTrue);
    });
  });

  group('entries', () {
    test('an entry the owner chose to log counts, whatever kind it is', () async {
      // Everything goes through the one add use case, so counting there means
      // no door can forget to.
      final device = _MemoryStore();
      final ledger = _Ledger();
      final container = _container(device, ledger: ledger);
      final keepAlive = container.listen(entryCountProvider, (_, _) {});
      addTearDown(keepAlive.close);
      await container.read(entryCountProvider.future);

      final add = container.read(addTransactionUseCaseProvider);
      await add.execute(_entry(TransactionType.expense));
      await add.execute(_entry(TransactionType.repayment));

      expect(ledger.items, hasLength(2));
      expect(device.counts[UsageKind.entries.key], 2);
    });

    test('a confirmed subscription charge is written but not counted', () async {
      // The owner is answering a question the app asked, not logging an entry
      // of their own, and the listing promises subscription tracking is free
      // for everyone. Someone tracking three of them used to spend most of
      // five free entries confirming bills.
      final device = _MemoryStore();
      final ledger = _Ledger();
      final container = _container(device, ledger: ledger);
      final keepAlive = container.listen(entryCountProvider, (_, _) {});
      addTearDown(keepAlive.close);
      await container.read(entryCountProvider.future);

      final add = container.read(addTransactionUseCaseProvider);
      await add.execute(_entry(TransactionType.subscriptionCharge));

      expect(ledger.items, hasLength(1), reason: 'the charge is still recorded');
      expect(device.counts[UsageKind.entries.key] ?? 0, 0);
    });

    test('a free owner at the limit can still confirm a charge', () async {
      final device = _MemoryStore()..counts[UsageKind.entries.key] = 5;
      final ledger = _Ledger();
      final container = _container(device, ledger: ledger);
      final keepAlive = container.listen(entryCountProvider, (_, _) {});
      addTearDown(keepAlive.close);
      await container.read(entryCountProvider.future);

      await container
          .read(addTransactionUseCaseProvider)
          .execute(_entry(TransactionType.subscriptionCharge));

      expect(ledger.items, hasLength(1));
      expect(device.counts[UsageKind.entries.key], 5, reason: 'unchanged');
    });

    test('the opening balance is not an entry, so onboarding never dead-ends', () async {
      final device = _MemoryStore()..counts[UsageKind.entries.key] = 5;
      final container = _container(device);
      final keepAlive = container.listen(entryCountProvider, (_, _) {});
      addTearDown(keepAlive.close);
      await container.read(entryCountProvider.future);

      await container
          .read(addTransactionUseCaseProvider)
          .execute(_entry(TransactionType.openingBalance));

      expect(device.counts[UsageKind.entries.key], 5);
    });

    test('a failed count write does not lose the entry', () async {
      final ledger = _Ledger();
      final container = _container(_ThrowingStore(), ledger: ledger);

      await container
          .read(addTransactionUseCaseProvider)
          .execute(_entry(TransactionType.expense));

      expect(ledger.items, hasLength(1));
    });
  });
}
