import 'dart:io';

import 'package:data/data.dart' hide Transaction, Loan, Subscription;
import 'package:domain/domain.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

/// drift stamps the new schema version only once beforeOpen succeeds, and the
/// upgrade steps are not wrapped in a transaction. A failure part way through
/// therefore leaves the earlier steps committed while user_version still says
/// the old number, so the next launch re-runs the upgrade from the start.
///
/// It used to run straight into "duplicate column name" on the first step that
/// had already finished, and then do that on every launch for good: the app
/// could not open and nothing short of deleting it helped.
void main() {
  late Directory dir;
  late File file;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('runway_interrupted_');
    file = File(p.join(dir.path, kDatabaseFileName));
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  /// A database at today's schema, with one entry to prove nothing is lost.
  Future<void> seed() async {
    final db = AppDatabase.forTesting(NativeDatabase(file));
    await DriftTransactionRepository(db).add(
      Transaction(
        id: 'tx-1',
        type: TransactionType.expense,
        amount: Money(42),
        date: DateTime(2026, 9, 1),
        note: 'Groceries',
        createdAt: DateTime(2026, 9, 1),
        updatedAt: DateTime(2026, 9, 1),
      ),
    );
    await db.close();
  }

  test('an upgrade that stopped half way finishes on the next launch', () async {
    await seed();

    // The state an interrupted upgrade leaves: some steps applied, the version
    // still at the old number, so all of them are about to run again.
    final raw = sqlite3.open(file.path);
    raw.execute('DROP TABLE financial_settings;');
    raw.execute('PRAGMA user_version = 1;');
    raw.dispose();

    final reopened = AppDatabase.forTesting(NativeDatabase(file));
    // Every step that had already been applied is asked about rather than
    // repeated, so the upgrade completes instead of throwing.
    final rows = await DriftTransactionRepository(reopened).getAll();
    expect(rows, hasLength(1), reason: 'the entry survives the upgrade');
    await reopened.close();
  });

  test('running the upgrade twice over is not an error', () async {
    await seed();

    for (var attempt = 0; attempt < 2; attempt++) {
      final raw = sqlite3.open(file.path);
      raw.execute('PRAGMA user_version = 1;');
      raw.dispose();

      final db = AppDatabase.forTesting(NativeDatabase(file));
      expect(await DriftTransactionRepository(db).getAll(), hasLength(1));
      await db.close();
    }
  });
}
