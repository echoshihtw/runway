import 'dart:io';

import 'package:data/data.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// The key is stored `first_unlock_this_device`, which a device restore does
/// not carry over. Anything in Documents is restored, so a restored phone used
/// to arrive with a real database and no key, and the app minted a fresh key
/// straight over it. Every launch afterwards failed the cipher probe with
/// "file is not a database", for good.
///
/// Documents is excluded from backup now, so a restore should bring no database
/// and minting is right. These cover what that cannot reach: an install backed
/// up before the exclusion shipped, or a Keychain cleared on its own.
class _MemoryStorage implements FlutterSecureStorage {
  _MemoryStorage([Map<String, String>? initial])
      : _values = {...?initial};

  final Map<String, String> _values;

  @override
  Future<String?> read({required String key, dynamic iOptions, dynamic aOptions,
      dynamic lOptions, dynamic webOptions, dynamic mOptions, dynamic wOptions}) async =>
      _values[key];

  @override
  Future<void> write({required String key, required String? value,
      dynamic iOptions, dynamic aOptions, dynamic lOptions, dynamic webOptions,
      dynamic mOptions, dynamic wOptions}) async {
    if (value == null) return;
    _values[key] = value;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory dir;
  late File file;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('runway_orphan_');
    file = File(p.join(dir.path, kDatabaseFileName));
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  test('a key is never minted over a database that already exists', () async {
    await file.writeAsString('not really a database, but it is a file');
    final storage = _MemoryStorage();

    await expectLater(
      getOrCreateDatabaseKey(databaseFile: file, storage: storage),
      throwsA(isA<OrphanedDatabaseException>()),
    );
    // The point is what did not happen: nothing was written over it.
    expect(await storage.read(key: kDatabaseKeyName), isNull);
  });

  test('a first run with no database mints and keeps a key', () async {
    final storage = _MemoryStorage();

    final key = await getOrCreateDatabaseKey(databaseFile: file, storage: storage);
    expect(key, isNotEmpty);
    expect(await storage.read(key: kDatabaseKeyName), key,
        reason: 'the key is kept, or the next launch mints another one');
  });

  test('an existing key is returned, database or not', () async {
    await file.writeAsString('a database');
    final storage = _MemoryStorage({kDatabaseKeyName: 'the-existing-key'});

    expect(
      await getOrCreateDatabaseKey(databaseFile: file, storage: storage),
      'the-existing-key',
    );
  });

  test('the exception names the file, so the state can be acted on', () async {
    await file.writeAsString('a database');
    try {
      await getOrCreateDatabaseKey(databaseFile: file, storage: _MemoryStorage());
      fail('should have refused');
    } on OrphanedDatabaseException catch (e) {
      expect(e.path, file.path);
      expect(e.toString(), contains('must not be written over it'));
    }
  });
}
