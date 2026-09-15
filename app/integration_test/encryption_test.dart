import 'dart:io';

import 'package:data/data.dart';
import 'package:domain/domain.dart' as domain;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

/// Runs on a simulator or device against the real SQLCipher build:
///
/// `flutter test integration_test/encryption_test.dart -d DEVICE_ID`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late File file;

  Future<void> deleteAll() => deleteEncryptedDatabase(
    // deleteEncryptedDatabase closes the database it is given; nothing real
    // is open here, so hand it a throwaway one.
    database: AppDatabase.forTesting(NativeDatabase.memory()),
  );

  Future<void> expectEncryptedOnDisk() async {
    final headerBytes = (await file.readAsBytes()).take(16).toList();
    debugPrint(
      'file header: '
      '${headerBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
    );
    expect(await isPlaintextSqliteFile(file), isFalse);

    // Opening the same file without the key must fail.
    final keyless = AppDatabase.forTesting(NativeDatabase(file));
    Object? keylessError;
    try {
      await keyless.customSelect('SELECT count(*) FROM sqlite_master;').get();
    } catch (error) {
      keylessError = error;
    } finally {
      await keyless.close();
    }
    debugPrint('open without key: $keylessError');
    expect(keylessError, isNotNull);
  }

  setUp(() async {
    final dir = await getApplicationDocumentsDirectory();
    file = File('${dir.path}/$kDatabaseFileName');
    await deleteAll();
    addTearDown(deleteAll);
  });

  testWidgets('a new database is encrypted with SQLCipher', (tester) async {
    final db = AppDatabase();
    await DriftFinancialSettingsRepository(
      db,
    ).saveBudget(const domain.Budget(rent: 123456, living: 7890));
    final cipherVersion = await readCipherVersion(db);
    await db.close();

    debugPrint('cipher_version: $cipherVersion');
    expect(cipherVersion, isNotNull);
    await expectEncryptedOnDisk();
  });

  testWidgets('a plaintext database from an older build is encrypted in place', (
    tester,
  ) async {
    // Older iOS builds loaded the system sqlite3, so PRAGMA key did nothing.
    // Opening without a key reproduces that file.
    final legacy = AppDatabase.forTesting(NativeDatabase(file));
    await DriftFinancialSettingsRepository(
      legacy,
    ).saveBudget(const domain.Budget(rent: 4321, living: 1234));
    await legacy.close();
    expect(await isPlaintextSqliteFile(file), isTrue);

    final db = AppDatabase();
    final budget = await DriftFinancialSettingsRepository(db).getBudget();
    final cipherVersion = await readCipherVersion(db);
    await db.close();

    expect(budget.rent, 4321);
    expect(budget.living, 1234);
    expect(cipherVersion, isNotNull);
    await expectEncryptedOnDisk();
  });
}
