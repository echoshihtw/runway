import 'package:application/application.dart';
import 'package:data/data.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:test/test.dart';

/// An in-memory stand-in for the Keychain.
class _MemoryStorage implements FlutterSecureStorage {
  final values = <String, String>{};

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final key = invocation.namedArguments[#key] as String?;
    switch (invocation.memberName) {
      case #read:
        return Future<String?>.value(values[key]);
      case #write:
        values[key!] = invocation.namedArguments[#value] as String;
        return Future<void>.value();
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  const entries = 'entries_logged';
  const simulations = 'simulations_run';

  test('reads zero when nothing has been stored', () async {
    final store = KeychainUsageCountStore(storage: _MemoryStorage());

    expect(await store.read(entries), 0);
    expect(await store.read(simulations), 0);
  });

  test('round-trips each count under its own key, without crossing', () async {
    final storage = _MemoryStorage();
    final store = KeychainUsageCountStore(storage: storage);

    await store.write(entries, 2);
    await store.write(simulations, 7);

    expect(await store.read(entries), 2);
    expect(await store.read(simulations), 7);
    expect(storage.values, {entries: '2', simulations: '7'});
  });

  test('treats an unreadable value as zero', () async {
    final storage = _MemoryStorage()..values[entries] = 'x';

    expect(await KeychainUsageCountStore(storage: storage).read(entries), 0);
  });

  test('neither key is the database key that Delete all data removes', () {
    for (final kind in UsageKind.values) {
      expect(kind.key, isNot(kDatabaseKeyName));
    }
  });
}
