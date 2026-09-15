import 'dart:io';

import 'package:data/data.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// Records deleted keys without touching a real Keychain.
class _RecordingStorage implements FlutterSecureStorage {
  final deletedKeys = <String>[];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #delete) {
      deletedKeys.add(invocation.namedArguments[#key] as String);
      return Future<void>.value();
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('runway_db_files_');
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  test('closes the database, deletes its files, then deletes the key', () async {
    final file = File(p.join(dir.path, kDatabaseFileName));
    final db = AppDatabase.forTesting(
      NativeDatabase(
        file,
        setup: (raw) => raw.execute('PRAGMA journal_mode=WAL;'),
      ),
    );
    await db.transactionDao.getAll();
    await File('${file.path}-journal').writeAsString('stale');
    expect(await file.exists(), isTrue);

    final storage = _RecordingStorage();
    await deleteEncryptedDatabase(
      database: db,
      directory: dir,
      storage: storage,
    );

    final remaining = await dir.list().map((e) => p.basename(e.path)).toList();
    expect(remaining, isEmpty);
    expect(storage.deletedKeys, [kDatabaseKeyName]);
  });

  test('succeeds when no database file was ever created', () async {
    final storage = _RecordingStorage();

    await deleteEncryptedDatabase(
      database: AppDatabase.forTesting(NativeDatabase.memory()),
      directory: dir,
      storage: storage,
    );

    expect(storage.deletedKeys, [kDatabaseKeyName]);
  });
}
