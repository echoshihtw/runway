import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'subscription_provider.dart';
import 'transaction_provider.dart';

class ThisMonthFlow {
  final double income;
  final double expenses;

  double get net => income - expenses;
  bool get isEmpty => income == 0 && expenses == 0;

  const ThisMonthFlow({required this.income, required this.expenses});
}

final thisMonthFlowProvider = Provider<ThisMonthFlow>((ref) {
  final txs = ref.watch(transactionsProvider).value ?? [];
  final now = DateTime.now();
  final thisMonth = txs.where(
    (t) => t.date.year == now.year && t.date.month == now.month,
  );
  final income = thisMonth
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount.value);
  final txExpenses = thisMonth
      .where(
        (t) =>
            t.type == TransactionType.expense ||
            t.type == TransactionType.repayment,
      )
      .fold(0.0, (sum, t) => sum + t.amount.value);
  final activeSubs = (ref.watch(subscriptionsProvider).value ?? [])
      .where((s) => s.isActive)
      .toList();
  // What actually bills this month, not a twelfth of every yearly plan: a
  // yearly bill belongs to its anniversary month.
  final subCost = subscriptionsChargedInMonth(
    subscriptions: activeSubs,
    month: now,
  );
  return ThisMonthFlow(income: income, expenses: txExpenses + subCost);
});
