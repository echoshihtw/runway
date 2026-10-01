import 'package:application/application.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../database/database_files.dart';

/// Counts live in secure storage, which Delete all data does not touch and an
/// iOS reinstall keeps. An Android uninstall clears them.
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
