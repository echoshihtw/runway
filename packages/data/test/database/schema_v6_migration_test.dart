import 'dart:io';

import 'package:data/data.dart' hide Transaction, Loan, Subscription;
import 'package:domain/domain.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  late Directory dir;
  late File file;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('runway_schema_v6_');
    file = File(p.join(dir.path, kDatabaseFileName));
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  test('upgrading from version 5 adds financial settings and keeps entries', () async {
    // Build a version 5 database: today's schema without the new table.
    final current = AppDatabase.forTesting(NativeDatabase(file));
    await DriftTransactionRepository(current).add(
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
    await current.close();

    final raw = sqlite3.open(file.path);
    raw.execute('DROP TABLE financial_settings;');
    raw.execute('PRAGMA user_version = 5;');
    raw.dispose();

    final upgraded = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(upgraded.close);
    final settings = DriftFinancialSettingsRepository(upgraded);
    await settings.saveBudget(const Budget(rent: 1000, living: 500));

    final version = await upgraded
        .customSelect('PRAGMA user_version;')
        .getSingle();
    expect(version.data.values.first, 6);
    expect((await settings.getBudget()).rent, 1000);
    final entries = await DriftTransactionRepository(upgraded).getAll();
    expect(entries.single.id, 'tx-1');
  });
}
