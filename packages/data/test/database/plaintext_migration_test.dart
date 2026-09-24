import 'dart:io';

import 'package:data/data.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

// encryptPlaintextDatabase needs SQLCipher, which the host test runner does not
// load. It is covered by app/integration_test/encryption_test.dart.
void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('runway_plaintext_');
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  test('a missing file is not plaintext', () async {
    expect(await isPlaintextSqliteFile(File(p.join(dir.path, 'none.db'))), isFalse);
  });

  test('an unencrypted SQLite database is plaintext', () async {
    final file = File(p.join(dir.path, kDatabaseFileName));
    final db = AppDatabase.forTesting(NativeDatabase(file));
    await db.transactionDao.getAll();
    await db.close();

    expect(await isPlaintextSqliteFile(file), isTrue);
  });

  test('random bytes, like an SQLCipher file, are not plaintext', () async {
    final file = File(p.join(dir.path, kDatabaseFileName));
    await file.writeAsBytes(List<int>.generate(4096, (i) => (i * 37 + 11) % 256));

    expect(await isPlaintextSqliteFile(file), isFalse);
  });

  test('a file shorter than the header is not plaintext', () async {
    final file = File(p.join(dir.path, kDatabaseFileName));
    await file.writeAsString('SQLite');

    expect(await isPlaintextSqliteFile(file), isFalse);
  });
}
