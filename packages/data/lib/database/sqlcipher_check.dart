import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

/// The database runs on plain SQLite, so `PRAGMA key` encrypted nothing.
class SqlCipherUnavailableError extends Error {
  @override
  String toString() =>
      'SqlCipherUnavailableError: PRAGMA cipher_version returned nothing, so '
      'the database is not encrypted. Check sqlcipher_flutter_libs and the '
      'open.overrideFor calls in app_database.dart.';
}

/// Returns the SQLCipher version, or null when plain SQLite is in use.
Future<String?> readCipherVersion(DatabaseConnectionUser db) async {
  final rows = await db.customSelect('PRAGMA cipher_version;').get();
  if (rows.isEmpty || rows.first.data.isEmpty) return null;
  final version = rows.first.data.values.first?.toString().trim();
  return (version == null || version.isEmpty) ? null : version;
}

/// Fails loudly when [cipherVersion] shows SQLCipher is not active.
///
/// Fatal by default, in release as well as debug. It used to default to
/// [kDebugMode], so a release build whose SQLCipher linkage regressed wrote
/// plaintext and only filed an error report nobody sees — while the store
/// listing promised the data was encrypted on the device. This project has
/// shipped that exact linker failure once before.
///
/// Refusing to run is recoverable: "Delete all data" no longer needs a
/// healthy database.
void ensureSqlCipher(String? cipherVersion, {bool fatal = true}) {
  if (cipherVersion != null) return;
  final error = SqlCipherUnavailableError();
  if (fatal) throw error;
  FlutterError.reportError(
    FlutterErrorDetails(
      exception: error,
      library: 'data',
      context: ErrorDescription('while opening the encrypted database'),
    ),
  );
}
