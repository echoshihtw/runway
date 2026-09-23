import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'database_files.dart';
import 'plaintext_migration.dart';
import 'sqlcipher_check.dart';
import '../tables/transactions_table.dart';
import '../tables/loans_table.dart';
import '../tables/subscriptions_table.dart';
import '../tables/financial_settings_table.dart';
import '../daos/transaction_dao.dart';
import '../daos/loan_dao.dart';
import '../daos/subscription_dao.dart';
import '../daos/financial_settings_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Transactions, Loans, Subscriptions, FinancialSettings],
  daos: [TransactionDao, LoanDao, SubscriptionDao, FinancialSettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : _verifyCipher = true, super(_openConnection());

  /// Plain SQLite for tests, so the SQLCipher check is skipped.
  AppDatabase.forTesting(super.executor) : _verifyCipher = false;

  final bool _verifyCipher;

  @override
  int get schemaVersion => 6;

  /// Whether [table] exists. Names come from drift rather than from string
  /// literals, so a renamed table cannot leave a check quietly looking for
  /// something that is no longer there.
  Future<bool> _hasTable(TableInfo table) async {
    final rows = await customSelect(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?",
      variables: [Variable<String>(table.actualTableName)],
    ).get();
    return rows.isNotEmpty;
  }

  /// Whether [column] exists on [table].
  Future<bool> _hasColumn(TableInfo table, GeneratedColumn column) async {
    final rows = await customSelect(
      'PRAGMA table_info("${table.actualTableName}")',
    ).get();
    return rows.any((r) => r.read<String>('name') == column.name);
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => await m.createAll(),
    // Every step asks whether it has already happened.
    //
    // drift stamps the new schema version only once beforeOpen succeeds, and
    // these steps are not wrapped in a transaction, so a failure part way
    // through leaves the earlier ones committed with user_version unchanged.
    // The next launch then re-ran from the start and addColumn threw
    // "duplicate column name" — every launch, for good. Asking first means a
    // half-finished upgrade simply finishes.
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        if (!await _hasColumn(transactions, transactions.loanId)) {
          await m.addColumn(transactions, transactions.loanId);
        }
        if (!await _hasTable(loans)) await m.createTable(loans);
      }
      if (from < 3) {
        if (!await _hasTable(subscriptions)) await m.createTable(subscriptions);
      }
      if (from < 4) {
        if (!await _hasColumn(loans, loans.originalTermMonths)) {
          await m.addColumn(loans, loans.originalTermMonths);
        }
      }
      if (from < 5) {
        if (!await _hasColumn(transactions, transactions.category)) {
          await customStatement(
            'ALTER TABLE "transactions" ADD COLUMN "category" TEXT;',
          );
        }
      }
      if (from < 6) {
        if (!await _hasTable(financialSettings)) {
          await m.createTable(financialSettings);
        }
      }
    },
    beforeOpen: (details) async {
      if (_verifyCipher) ensureSqlCipher(await readCipherVersion(this));
    },
  );
}

/// Retrieves or creates a secure encryption key
/// Stored in iOS Secure Enclave / Android Keystore
/// Never stored in plain text or SharedPreferences
/// Thrown when a database exists but the key for it does not.
///
/// The key is stored `first_unlock_this_device`, which a device restore does
/// not carry over, while anything in Documents is restored. Minting a fresh key
/// in that state writes a new one over a real database, and every launch after
/// it fails the cipher probe with "file is not a database" — permanently, with
/// no way back but deleting the app.
///
/// Documents is excluded from backup now, in
/// `AppDelegate.excludeDocumentsFromBackup`, so a restore should arrive with no
/// database at all and minting is then correct. This covers what exclusion
/// cannot reach: an install backed up before that shipped, or a Keychain
/// cleared without the files going with it. Refusing to mint turns a permanent
/// brick into a state something can be done about.
class OrphanedDatabaseException implements Exception {
  const OrphanedDatabaseException(this.path);

  final String path;

  @override
  String toString() =>
      'OrphanedDatabaseException: a database exists at $path but its key is '
      'gone. A new key must not be written over it.';
}

/// The key for [databaseFile], minting one only when there is nothing to lose.
///
/// [storage] is injectable for the same reason [KeychainUsageCountStore] takes
/// it: the branch that must never mint cannot be exercised against a real
/// Keychain.
@visibleForTesting
Future<String> getOrCreateDatabaseKey({
  File? databaseFile,
  FlutterSecureStorage storage = kDatabaseKeyStorage,
}) async {
  const keyName = kDatabaseKeyName;
  var key = await storage.read(key: keyName);

  if (key == null) {
    if (databaseFile != null && await databaseFile.exists()) {
      throw OrphanedDatabaseException(databaseFile.path);
    }
    // Generate a cryptographically secure 256-bit key
    final random = Random.secure();
    final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
    key = base64Url.encode(keyBytes);
    await storage.write(key: keyName, value: key);
  }

  return key;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
    }

    final dir  = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, kDatabaseFileName));
    final dbKey = await getOrCreateDatabaseKey(databaseFile: file);
    if (await isPlaintextSqliteFile(file)) {
      final path = file.path;
      await Isolate.run(() {
        _useSqlCipher();
        encryptPlaintextDatabase(File(path), dbKey);
      });
    }
    final pragmaKey = "PRAGMA key = '$dbKey';";
    return NativeDatabase.createInBackground(
      file,
      isolateSetup: _useSqlCipher,
      setup: (db) {
        db.execute(pragmaKey);
        db.execute('PRAGMA journal_mode=WAL;');
        db.execute('SELECT count(*) FROM sqlite_master;');
      },
    );
  });
}

/// Points the sqlite3 package at SQLCipher in the current isolate.
void _useSqlCipher() {
  open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
  open.overrideFor(OperatingSystem.iOS, () => DynamicLibrary.process());
}
