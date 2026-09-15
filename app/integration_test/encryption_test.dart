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

  Future<void> deleteAll() => deleteEncryptedDatabase(
    // deleteEncryptedDatabase closes the database it is given; nothing real
    // is open here, so hand it a throwaway one.
    database: AppDatabase.forTesting(NativeDatabase.memory()),
  );

  testWidgets('the database file on disk is encrypted with SQLCipher', (
    tester,
  ) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$kDatabaseFileName');
    await deleteAll();
    addTearDown(deleteAll);

    final db = AppDatabase();
    await DriftFinancialSettingsRepository(
      db,
    ).saveBudget(const domain.Budget(rent: 123456, living: 7890));
    final cipherVersion = await readCipherVersion(db);
    await db.close();

    final headerBytes = (await file.readAsBytes()).take(16).toList();
    final header = String.fromCharCodes(headerBytes);
    debugPrint('cipher_version: $cipherVersion');
    debugPrint(
      'file header: ${headerBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
    );

    expect(cipherVersion, isNotNull);
    expect(header, isNot(startsWith('SQLite format 3')));

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
  });
}
