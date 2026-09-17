import 'package:data/data.dart' hide Transaction, Loan, Subscription;
import 'package:domain/domain.dart';
import 'package:test/test.dart';
import 'db_helper.dart';

/// `investment` was a transaction type until the feature was removed. Deleting
/// the enum value would make `values.byName` throw on a database written back
/// then, which would take the whole ledger down rather than one row.
void main() {
  test('a row stored by a removed feature still loads, as an expense', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final seconds = DateTime(2026, 4, 1).millisecondsSinceEpoch ~/ 1000;
    await db.customStatement(
      'INSERT INTO transactions (id, date, type, amount, created_at, updated_at) '
      "VALUES ('legacy-etf', $seconds, 'investment', 20000, $seconds, $seconds)",
    );

    final entries = await DriftTransactionRepository(db).getAll();

    expect(entries, hasLength(1), reason: 'the row must still be readable');
    expect(entries.single.amount.value, 20000);
    expect(entries.single.type.isInflow, isFalse, reason: 'it was money out');
    // It was never an expense, so it must not start consuming a budget.
    expect(countsAsLiving(entries.single), isFalse);
    expect(countsAsRent(entries.single), isFalse);
  });
}
