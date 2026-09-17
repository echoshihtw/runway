enum TransactionType {
  expense,
  income,
  loan,
  investment, // kept for backward-compatibility with stored data
  repayment,
  openingBalance,
  subscriptionCharge;

  String get label => switch (this) {
    TransactionType.expense => 'EXPENSE',
    TransactionType.income => 'INCOME',
    TransactionType.loan => 'LOAN',
    TransactionType.investment => 'INVEST',
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
