import 'dart:io';

import 'package:data/data.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('runway_db_files_');
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  test('closes the database and deletes every file it left behind', () async {
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

    await deleteEncryptedDatabase(database: db, directory: dir);

    final remaining = await dir.list().map((e) => p.basename(e.path)).toList();
    expect(remaining, isEmpty);
  });

  test('succeeds when no database file was ever created', () async {
    await deleteEncryptedDatabase(
      database: AppDatabase.forTesting(NativeDatabase.memory()),
      directory: dir,
    );

    expect(await dir.list().isEmpty, isTrue);
  });

  test('deletes the data even when the database cannot be opened', () async {
    // This is the state deletion exists for. Drift's LazyDatabase rethrows a
    // failed open, so awaiting close() aborted the delete and left the owner
    // with no escape but removing the app.
    final file = File(p.join(dir.path, kDatabaseFileName));
    await file.writeAsString('not a database at all');
    final unopenable = AppDatabase.forTesting(
      LazyDatabase(() async => throw StateError('file is not a database')),
    );

    await deleteEncryptedDatabase(database: unopenable, directory: dir);

    expect(await file.exists(), isFalse);
  });

  test('the key store is out of reach, so data deletion cannot orphan it', () {
    // "Database present, key missing" is the one unrecoverable state. Keeping
    // the key means deleting data can never cause it, and the guarantee is
    // structural: this function takes no storage to delete from.
    expect(kDatabaseKeyName, 'awareness_db_key');
    expect(
      deleteEncryptedDatabase,
      isA<Future<void> Function({required AppDatabase database, Directory? directory})>(),
    );
  });
}
