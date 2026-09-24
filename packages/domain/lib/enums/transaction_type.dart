enum TransactionType {
  expense,
  income,
  loan,
  repayment,
  openingBalance,
  subscriptionCharge;

  String get label => switch (this) {
    TransactionType.expense => 'EXPENSE',
    TransactionType.income => 'INCOME',
    TransactionType.loan => 'LOAN',
    TransactionType.repayment => 'REPAY',
    TransactionType.openingBalance => 'OPENING',
    TransactionType.subscriptionCharge => 'SUBSCRIPTION',
  };

  bool get isInflow => switch (this) {
    TransactionType.income => true,
    TransactionType.loan => true,
    TransactionType.openingBalance => true,
    _ => false,
  };
}
