import 'package:drift/drift.dart';
import 'package:domain/domain.dart' as domain;
import '../database/app_database.dart';

/// Types are stored by name, and a name this version does not know belongs to
/// a feature that has since been removed — `investment` was one. The row is
/// still a real movement of money, so it reads as an ordinary expense rather
/// than throwing and taking the whole ledger down with it.
domain.TransactionType _typeFromName(String name) {
  for (final type in domain.TransactionType.values) {
    if (type.name == name) return type;
  }
  return domain.TransactionType.expense;
}

extension TransactionRowMapper on Transaction {
  domain.Transaction toDomain() => domain.Transaction(
    id: id,
    date: date,
    type: _typeFromName(type),
    amount: domain.Money(amount),
    note: note,
    loanId: loanId,
    category: category == null
        ? null
        : domain.ExpenseCategory.values.byName(category!),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension TransactionDomainMapper on domain.Transaction {
  TransactionsCompanion toCompanion() => TransactionsCompanion(
    id: Value(id),
    date: Value(date),
    type: Value(type.name),
    amount: Value(amount.value),
    note: Value(note),
    loanId: Value(loanId),
    category: Value(category?.name),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
  );
}
