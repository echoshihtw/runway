import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'database_files.dart';
import '../tables/transactions_table.dart';
import '../tables/loans_table.dart';
import '../tables/subscriptions_table.dart';
import '../daos/transaction_dao.dart';
import '../daos/loan_dao.dart';
import '../daos/subscription_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Transactions, Loans, Subscriptions],
  daos: [TransactionDao, LoanDao, SubscriptionDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => await m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(transactions, transactions.loanId);
        await m.createTable(loans);
      }
      if (from < 3) {
        await m.createTable(subscriptions);
      }
      if (from < 4) {
        await m.addColumn(loans, loans.originalTermMonths);
      }
      if (from < 5) {
        await customStatement(
          'ALTER TABLE "transactions" ADD COLUMN "category" TEXT;',
        );
      }
    },
  );
}

/// Retrieves or creates a secure encryption key
/// Stored in iOS Secure Enclave / Android Keystore
/// Never stored in plain text or SharedPreferences
Future<String> _getOrCreateKey() async {
  const storage = kDatabaseKeyStorage;
  const keyName = kDatabaseKeyName;
  var key = await storage.read(key: keyName);

  if (key == null) {
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
    final dbKey = await _getOrCreateKey();
    final pragmaKey = "PRAGMA key = '$dbKey';";
    return NativeDatabase.createInBackground(
      file,
      isolateSetup: () async {
        open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
        open.overrideFor(OperatingSystem.iOS, () => DynamicLibrary.process());
      },
      setup: (db) {
        db.execute(pragmaKey);
        db.execute('PRAGMA journal_mode=WAL;');
        db.execute('SELECT count(*) FROM sqlite_master;');
      },
    );
  });
}
