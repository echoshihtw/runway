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
  test('reads zero when nothing has been stored', () async {
    final store = KeychainSimulationCountStore(storage: _MemoryStorage());

    expect(await store.read(), 0);
  });

  test('round-trips the count under its own key', () async {
    final storage = _MemoryStorage();
    final store = KeychainSimulationCountStore(storage: storage);

    await store.write(2);

    expect(await store.read(), 2);
    expect(storage.values, {KeychainSimulationCountStore.key: '2'});
  });

  test('treats an unreadable value as zero', () async {
    final storage = _MemoryStorage()..values[KeychainSimulationCountStore.key] = 'x';

    expect(await KeychainSimulationCountStore(storage: storage).read(), 0);
  });

  test('is a different key from the database key that Delete all data removes', () {
    expect(KeychainSimulationCountStore.key, isNot(kDatabaseKeyName));
  });
}
