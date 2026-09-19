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

/// Permanently removes the encrypted database, keeping its key.
///
/// Closing [database] first stops a live connection writing to a deleted file,
/// but a failure to close must not stop the delete: drift's `LazyDatabase`
/// rethrows a failed open, so a database that cannot be opened cannot be
/// closed either — and deletion is the recovery path for exactly that state.
///
/// The key is deliberately left alone. It is infrastructure rather than user
/// data, and keeping it means "database present, key missing" — the state that
/// cannot be recovered from — can never be caused by deleting data. This
/// function has no access to the key store, so that guarantee is structural.
///
/// The next [AppDatabase] opened afterwards starts empty with the same key.
Future<void> deleteEncryptedDatabase({
  required AppDatabase database,
  Directory? directory,
}) async {
  try {
    await database.close();
  } catch (_) {
    // An unopenable database is the reason this is being called.
  }
  final dir = directory ?? await getApplicationDocumentsDirectory();
  for (final suffix in _databaseFileSuffixes) {
    final file = File(p.join(dir.path, '$kDatabaseFileName$suffix'));
    if (await file.exists()) await file.delete();
  }
}
