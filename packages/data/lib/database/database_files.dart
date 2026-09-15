import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_database.dart';

/// Name of the encrypted database file in the app documents directory.
const kDatabaseFileName = 'survival.db';

/// Secure storage entry holding the database encryption key.
const kDatabaseKeyName = 'awareness_db_key';

/// Keychain on iOS, Keystore on Android.
const kDatabaseKeyStorage = FlutterSecureStorage(
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  ),
  aOptions: AndroidOptions(),
);

/// The database file and every SQLite sidecar that can hold its pages.
const _databaseFileSuffixes = ['', '-wal', '-shm', '-journal'];

/// Permanently removes the encrypted database and its key.
///
/// Closes [database] first so no connection writes to a deleted file. Files
/// go before the key: if a file cannot be deleted, the key survives and the
/// remaining data stays readable instead of becoming undecryptable.
///
/// The next [AppDatabase] opened afterwards starts empty with a new key.
Future<void> deleteEncryptedDatabase({
  required AppDatabase database,
  Directory? directory,
  FlutterSecureStorage storage = kDatabaseKeyStorage,
}) async {
  await database.close();
  final dir = directory ?? await getApplicationDocumentsDirectory();
  for (final suffix in _databaseFileSuffixes) {
    final file = File(p.join(dir.path, '$kDatabaseFileName$suffix'));
    if (await file.exists()) await file.delete();
  }
  await storage.delete(key: kDatabaseKeyName);
}
