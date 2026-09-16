import '../value_objects/ledger_month.dart';

class MonthlyState {
  final LedgerMonth month;
  final double netFlow;
  final double balance;
  final double grossOutflow; // expenses + repayments only, no income

  const MonthlyState({
    required this.month,
    required this.netFlow,
    required this.balance,
    this.grossOutflow = 0,
  });
}
