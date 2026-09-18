import 'package:application/application.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../database/database_files.dart';

/// Keeps the usage counts in the iOS Keychain, which survives deleting and
/// reinstalling the app. Delete all data only removes the database key, so
/// these counts stay. On Android, uninstalling clears them.
class KeychainUsageCountStore implements UsageCountStore {
  const KeychainUsageCountStore({
    FlutterSecureStorage storage = kDatabaseKeyStorage,
  }) : _storage = storage;

  final FlutterSecureStorage _storage;

  @override
  Future<int> read(String key) async =>
      int.tryParse(await _storage.read(key: key) ?? '') ?? 0;

  @override
  Future<void> write(String key, int count) =>
      _storage.write(key: key, value: count.toString());
}
