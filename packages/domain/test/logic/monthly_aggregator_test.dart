import 'package:test/test.dart';
import 'package:domain/domain.dart';
import '../helpers/transaction_helper.dart';

void main() {
  _openingBalanceTests();

  group('aggregateMonths', () {
    test('returns empty for no transactions', () {
      expect(aggregateMonths([]), isEmpty);
    });

    test('returns empty if only opening balance', () {
      final txs = [
        makeTx(
          year: 2025,
          month: 1,
          day: 1,
          type: TransactionType.openingBalance,
          amount: 1000000,
        ),
      ];
      expect(aggregateMonths(txs).first.balance, 1000000);
    });

    test('opening balance sets starting cash', () {
      final txs = [
        makeTx(
          year: 2025,
          month: 1,
          day: 1,
          type: TransactionType.openingBalance,
          amount: 1000000,
        ),
        makeTx(
          year: 2025,
          month: 1,
          day: 15,
          type: TransactionType.expense,
          amount: 50000,
        ),
      ];
      final months = aggregateMonths(txs);
      expect(months.first.balance, 950000);
    });

    test('income is positive netFlow', () {
      final txs = [
        makeTx(
          year: 2025,
          month: 1,
          day: 1,
          type: TransactionType.openingBalance,
          amount: 500000,
        ),
        makeTx(
          year: 2025,
          month: 2,
          day: 1,
          type: TransactionType.income,
          amount: 80000,
        ),
        makeTx(
          year: 2025,
          month: 2,
          day: 15,
          type: TransactionType.expense,
          amount: 50000,
        ),
      ];
      final months = aggregateMonths(txs);
      final feb = months.firstWhere((m) => m.month.value.month == 2);
      expect(feb.netFlow, 30000);
    });

    test('loan is treated as inflow', () {
      final txs = [
        makeTx(
          year: 2025,
          month: 1,
          day: 1,
          type: TransactionType.openingBalance,
          amount: 0,
        ),
        makeTx(
          year: 2025,
          month: 1,
          day: 1,
          type: TransactionType.loan,
          amount: 500000,
        ),
      ];
      final months = aggregateMonths(txs);
      expect(months.first.netFlow, 500000);
    });

    test('repayment is outflow', () {
      final txs = [
        makeTx(
          year: 2025,
          month: 1,
          day: 1,
          type: TransactionType.openingBalance,
          amount: 500000,
        ),
        makeTx(
          year: 2025,
          month: 1,
          day: 1,
          type: TransactionType.repayment,
          amount: 15000,
        ),
      ];
      final months = aggregateMonths(txs);
      expect(months.first.netFlow, -15000);
    });

    test('balance accumulates across months', () {
      final txs = [
        makeTx(
          year: 2025,
          month: 1,
          day: 1,
          type: TransactionType.openingBalance,
          amount: 1000000,
        ),
        makeTx(
          year: 2025,
          month: 1,
          day: 1,
          type: TransactionType.expense,
          amount: 50000,
        ),
        makeTx(
          year: 2025,
          month: 2,
          day: 1,
          type: TransactionType.expense,
          amount: 50000,
        ),
        makeTx(
          year: 2025,
          month: 3,
          day: 1,
          type: TransactionType.expense,
          amount: 50000,
        ),
      ];
      final months = aggregateMonths(txs);
      expect(months[0].balance, 950000);
      expect(months[1].balance, 900000);
      expect(months[2].balance, 850000);
    });

    test('months sorted chronologically', () {
      final txs = [
        makeTx(
          year: 2025,
          month: 1,
          day: 1,
          type: TransactionType.openingBalance,
          amount: 500000,
        ),
        makeTx(
          year: 2025,
          month: 3,
          day: 1,
          type: TransactionType.expense,
          amount: 10000,
        ),
        makeTx(
          year: 2025,
          month: 1,
          day: 1,
          type: TransactionType.expense,
          amount: 10000,
        ),
        makeTx(
          year: 2025,
          month: 2,
          day: 1,
          type: TransactionType.expense,
          amount: 10000,
        ),
      ];
      final months = aggregateMonths(txs);
      final nums = months.map((m) => m.month.value.month).toList();
      expect(nums, [1, 2, 3]);
    });

    test('multiple transactions in same month aggregate correctly', () {
      final txs = [
        makeTx(
          year: 2025,
          month: 1,
          day: 1,
          type: TransactionType.openingBalance,
          amount: 1000000,
        ),
        makeTx(
          year: 2025,
          month: 1,
          day: 5,
          type: TransactionType.expense,
          amount: 20000,
        ),
        makeTx(
          year: 2025,
          month: 1,
          day: 10,
          type: TransactionType.expense,
          amount: 30000,
        ),
        makeTx(
          year: 2025,
          month: 1,
          day: 15,
          type: TransactionType.income,
          amount: 80000,
        ),
      ];
      final months = aggregateMonths(txs);
      expect(months.first.netFlow, 30000); // 80000 - 20000 - 30000
    });
  });
}

void _openingBalanceTests() {
  Transaction opening(double amount, DateTime date) => Transaction(
    id: 'ob-${date.toIso8601String()}-$amount',
    date: date,
    type: TransactionType.openingBalance,
    amount: Money(amount),
    createdAt: date,
    updatedAt: date,
  );

  group('opening balance is a starting point, not a running total', () {
    test('a single opening balance sets the balance', () {
      final months = aggregateMonths([opening(100000, DateTime(2026, 9, 1))]);

      expect(months.single.balance, 100000);
    });

    test('a later opening balance replaces an earlier one', () {
      // Correcting a balance must never double it.
      final months = aggregateMonths([
        opening(100000, DateTime(2026, 9, 1)),
        opening(90000, DateTime(2026, 9, 10)),
      ]);

      expect(months.single.balance, 90000);
    });

    test('no opening balance leaves nothing to report', () {
      expect(aggregateMonths(const []), isEmpty);
    });
  });
}
