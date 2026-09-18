import 'package:application/application.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../database/database_files.dart';

/// Keeps the entry count in the iOS Keychain, which survives deleting and
/// reinstalling the app. Delete all data only removes the database key, so
/// this count stays. On Android, uninstalling clears it.
class KeychainEntryCountStore implements EntryCountStore {
  const KeychainEntryCountStore({
    FlutterSecureStorage storage = kDatabaseKeyStorage,
  }) : _storage = storage;

  static const key = 'entries_logged';

  final FlutterSecureStorage _storage;

  @override
  Future<int> read() async =>
      int.tryParse(await _storage.read(key: key) ?? '') ?? 0;

  @override
  Future<void> write(int count) =>
      _storage.write(key: key, value: count.toString());
}
