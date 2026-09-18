import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for the Keychain. One instance plays the device across restarts.
class _MemoryStore implements EntryCountStore {
  int count = 0;

  @override
  Future<int> read() async => count;

  @override
  Future<void> write(int value) async => count = value;
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

ProviderContainer _container(EntryCountStore store, TransactionRepository ledger) {
  final container = ProviderContainer(
    // A throwing store would otherwise be retried for ~38 s.
    retry: (_, __) => null,
    overrides: [
      entryCountStoreProvider.overrideWithValue(store),
      transactionRepositoryProvider.overrideWithValue(ledger),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('free users log five entries, then need Pro', () {
    expect(kFreeEntries, 5);
    for (final logged in [0, 1, 2, 3, 4]) {
      expect(needsProForEntry(isPro: false, entriesLogged: logged), isFalse);
    }
    expect(needsProForEntry(isPro: false, entriesLogged: 5), isTrue);
    expect(needsProForEntry(isPro: true, entriesLogged: 500), isFalse);
  });

  test('the count starts at zero and survives a restart', () async {
    final device = _MemoryStore();
    final first = _container(device, _Ledger());
    expect(await first.read(entryCountProvider.future), 0);

    await first.read(entryCountProvider.notifier).increment();
    await first.read(entryCountProvider.notifier).increment();
    expect(first.read(entryCountProvider).value, 2);

    final afterRestart = _container(device, _Ledger());
    expect(await afterRestart.read(entryCountProvider.future), 2);
  });

  test('adding an entry counts it, whatever kind it is', () async {
    // "Every entry" was the decision: an expense, a repayment, a confirmed
    // subscription charge and a loan disbursement all go through the one add
    // use case, so counting there means no door can forget to.
    final device = _MemoryStore();
    final ledger = _Ledger();
    final container = _container(device, ledger);
    final keepAlive = container.listen(entryCountProvider, (_, __) {});
    addTearDown(keepAlive.close);
    await container.read(entryCountProvider.future);

    final add = container.read(addTransactionUseCaseProvider);
    await add.execute(_entry(TransactionType.expense));
    await add.execute(_entry(TransactionType.repayment));
    await add.execute(_entry(TransactionType.subscriptionCharge));

    expect(ledger.items, hasLength(3));
    expect(device.count, 3);
  });

  test('the opening balance is not an entry, so onboarding never dead-ends', () async {
    final device = _MemoryStore()..count = 5;
    final container = _container(device, _Ledger());
    final keepAlive = container.listen(entryCountProvider, (_, __) {});
    addTearDown(keepAlive.close);
    await container.read(entryCountProvider.future);

    await container
        .read(addTransactionUseCaseProvider)
        .execute(_entry(TransactionType.openingBalance));

    expect(device.count, 5, reason: 'starting is not logging');
  });

  test('a failed count write does not lose the entry', () async {
    // The ledger is the user's data; the counter is ours. If the Keychain
    // refuses, the entry must still be saved.
    final ledger = _Ledger();
    final container = _container(_ThrowingStore(), ledger);

    await container
        .read(addTransactionUseCaseProvider)
        .execute(_entry(TransactionType.expense));

    expect(ledger.items, hasLength(1));
  });

  test('Delete all data leaves the count alone', () async {
    final device = _MemoryStore()..count = 4;
    expect(await _container(device, _Ledger()).read(entryCountProvider.future), 4);
  });
}

class _ThrowingStore implements EntryCountStore {
  @override
  Future<int> read() async => throw Exception('keychain locked');

  @override
  Future<void> write(int value) async => throw Exception('keychain locked');
}
