import '../enums/expense_category.dart';
import '../enums/transaction_type.dart';
import '../value_objects/money.dart';
import '../value_objects/ledger_month.dart';

class Transaction {
  final String id;
  final DateTime date;
  final LedgerMonth month;
  final TransactionType type;
  final Money amount;
  final String? note;
  final String? loanId; // links REPAY to a specific loan
  final ExpenseCategory? category; // only set when type == expense
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    this.note,
    this.loanId,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  }) : month = LedgerMonth(date);

  double get signedAmount => type.isInflow ? amount.value : -amount.value;

  Transaction copyWith({
    String? id,
    DateTime? date,
    TransactionType? type,
    Money? amount,
    String? note,
    String? loanId,
    bool clearLoanId = false,
    ExpenseCategory? category,
    bool clearCategory = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      loanId: clearLoanId ? null : (loanId ?? this.loanId),
      category: clearCategory ? null : (category ?? this.category),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
