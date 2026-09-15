import '../entities/loan.dart';
import '../entities/loan_summary.dart';
import '../entities/transaction.dart';
import '../enums/transaction_type.dart';

List<LoanSummary> computeLoanSummaries({
  required List<Loan> loans,
  required List<Transaction> transactions,
}) {
  final now = DateTime.now();
  final repayments = transactions.where(
    (t) => t.type == TransactionType.repayment && t.loanId != null,
  );

  return loans.map((loan) {
    final loanRepayments = repayments.where((t) => t.loanId == loan.id);

    final totalRepaid = loanRepayments.fold(
      0.0,
      (sum, t) => sum + t.amount.value,
    );

    final paidThisMonth = loanRepayments
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount.value);

    final remaining = (loan.originalAmount - totalRepaid).clamp(
      0.0,
      double.infinity,
    );

    return LoanSummary(
      loan: loan,
      totalRepaid: totalRepaid,
      remainingBalance: remaining,
      paidThisMonth: paidThisMonth,
    );
  }).toList();
}

double totalMonthlyPayment(List<Loan> loans) {
  return loans
      .where((l) => l.isActive)
      .fold(0.0, (sum, l) => sum + l.monthlyPayment);
}

/// Whether the user has a loan that is still active and not paid off. The free
/// plan allows one such loan at a time, so paying a loan off frees the slot.
bool hasActiveLoan({
  required List<Loan> loans,
  required List<Transaction> transactions,
}) => activeLoanSummaries(
  computeLoanSummaries(loans: loans, transactions: transactions),
).isNotEmpty;

List<LoanSummary> activeLoanSummaries(List<LoanSummary> summaries) {
  return summaries
      .where((summary) => summary.loan.isActive && !summary.isFullyPaid)
      .toList();
}

double totalMonthlyPaymentFromSummaries(List<LoanSummary> summaries) {
  return activeLoanSummaries(
    summaries,
  ).fold(0.0, (sum, summary) => sum + summary.loan.monthlyPayment);
}
