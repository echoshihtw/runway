import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

const _plaintextHeader = 'SQLite format 3';

/// Whether [file] is an unencrypted SQLite database.
///
/// Builds before SQLCipher was linked ahead of the system sqlite3 on iOS wrote
/// the database in plaintext, even though `PRAGMA key` ran.
Future<bool> isPlaintextSqliteFile(File file) async {
  if (!await file.exists()) return false;
  final handle = await file.open();
  try {
    final bytes = await handle.read(_plaintextHeader.length);
    return String.fromCharCodes(bytes) == _plaintextHeader;
  } finally {
    await handle.close();
  }
}

/// Rewrites the plaintext database at [file] as an SQLCipher database keyed
/// with [key], keeping every row and the schema version.
///
/// Must run with SQLCipher loaded, since `sqlcipher_export` only exists there.
/// Crash-safe: the plaintext file stays in place until the encrypted copy is
/// complete, and the final rename is atomic.
void encryptPlaintextDatabase(File file, String key) {
  final encrypted = File('${file.path}.encrypting');
  if (encrypted.existsSync()) encrypted.deleteSync();

  final db = sqlite3.open(file.path);
  try {
    final version = db.select('PRAGMA user_version;').first.columnAt(0) as int;
    db.execute(
      "ATTACH DATABASE '${_quote(encrypted.path)}' AS encrypted "
      "KEY '${_quote(key)}';",
    );
    db.execute("SELECT sqlcipher_export('encrypted');");
    db.execute('PRAGMA encrypted.user_version = $version;');
    db.execute('DETACH DATABASE encrypted;');
  } finally {
    // Closing the last connection checkpoints the plaintext WAL into the file.
    db.dispose();
  }

  for (final suffix in ['-wal', '-shm', '-journal']) {
    final sidecar = File('${file.path}$suffix');
    if (sidecar.existsSync()) sidecar.deleteSync();
  }
  encrypted.renameSync(file.path);
}

String _quote(String value) => value.replaceAll("'", "''");
