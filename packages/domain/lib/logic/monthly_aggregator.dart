import '../entities/transaction.dart';
import '../entities/monthly_state.dart';
import '../enums/transaction_type.dart';
import '../value_objects/survival_month.dart';

List<MonthlyState> aggregateMonths(List<Transaction> transactions) {
  if (transactions.isEmpty) return [];

  final opening = transactions
      .where((t) => t.type == TransactionType.openingBalance)
      .fold(0.0, (sum, t) => sum + t.signedAmount);

  final regular = transactions
      .where((t) => t.type != TransactionType.openingBalance)
      .toList();

  if (regular.isEmpty && opening > 0) {
    return [
      MonthlyState(
        month: SurvivalMonth(DateTime.now()),
        netFlow: 0,
        balance: opening,
        grossOutflow: 0,
      ),
    ];
  }

  if (regular.isEmpty) return [];

  final Map<String, List<Transaction>> byMonth = {};
  for (final t in regular) {
    byMonth.putIfAbsent(t.month.toString(), () => []).add(t);
  }

  final sortedKeys = byMonth.keys.toList()..sort();
  double balance = opening;
  final result = <MonthlyState>[];

  for (final key in sortedKeys) {
    final monthTxs = byMonth[key]!;
    final netFlow = monthTxs.fold(0.0, (sum, t) => sum + t.signedAmount);
    final grossOutflow = monthTxs
        .where((t) => !t.type.isInflow)
        .fold(0.0, (sum, t) => sum + t.amount.value);
    balance += netFlow;
    result.add(
      MonthlyState(
        month: monthTxs.first.month,
        netFlow: netFlow,
        balance: balance,
        grossOutflow: grossOutflow,
      ),
    );
  }

  return result;
}

/// Cash on hand at [now].
///
/// Entries dated after today are plans: the log shows them with a badge, and
/// they must not move cash or the runway until their date arrives.
double currentCashAsOf({
  required List<Transaction> transactions,
  required DateTime now,
}) {
  final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
  final settled = transactions
      .where((t) => !t.date.isAfter(endOfToday))
      .toList();
  final months = aggregateMonths(settled);
  return months.isEmpty ? 0.0 : months.last.balance;
}
