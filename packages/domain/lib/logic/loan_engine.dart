import '../entities/loan.dart';
import '../entities/loan_summary.dart';
import '../entities/transaction.dart';
import '../enums/transaction_type.dart';

List<LoanSummary> computeLoanSummaries({
  required List<Loan> loans,
  required List<Transaction> transactions,
  required DateTime now,
}) {
  // A repayment dated later this month has not been paid. Counting it zeroed
  // what the month still owed, cut the remaining balance, and could free the
  // free-plan loan slot early.
  final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
  final repayments = transactions.where(
    (t) =>
        t.type == TransactionType.repayment &&
        t.loanId != null &&
        !t.date.isAfter(endOfToday),
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
  DateTime? now,
}) => activeLoanSummaries(
  computeLoanSummaries(
    loans: loans,
    transactions: transactions,
    now: now ?? DateTime.now(),
  ),
).isNotEmpty;

/// The month after the last scheduled payment, or null when no term is set.
DateTime? loanTermEnd(Loan loan) => loan.originalTermMonths > 0
    ? DateTime(
        loan.startDate.year,
        loan.startDate.month + loan.originalTermMonths,
        loan.startDate.day,
      )
    : null;

/// Loans that still cost money every month at [now].
///
/// When a term is set it is the end this app can trust. `remainingBalance`
/// ignores interest, so repaid principal does not mean the payments have
/// stopped: on a loan at 6% over 96 months the payments exceed the principal by
/// about a quarter, and dropping the loan there would raise the runway while the
/// user is still paying.
///
/// Without a term there is nothing better than repaid principal, which is also
/// correct for an interest-free loan. A loan carrying interest but no recorded
/// term will still stop early; recording a term is what fixes that.
List<LoanSummary> costingLoanSummaries(
  List<LoanSummary> summaries, {
  required DateTime now,
}) => summaries.where((summary) {
  if (!summary.loan.isActive) return false;
  final end = loanTermEnd(summary.loan);
  // With a term, the term governs: repaid principal does not mean the payments
  // stopped. Without a term, repaid principal is the only end available, and it
  // is the right one for an interest-free loan, where payment = amount / months.
  return end == null ? !summary.isFullyPaid : now.isBefore(end);
}).toList();

/// Loans to show and to count against the free-plan limit. Repaying the
/// principal frees the slot, which is deliberately more generous than the
/// costing rule above.
List<LoanSummary> activeLoanSummaries(List<LoanSummary> summaries) {
  return summaries
      .where((summary) => summary.loan.isActive && !summary.isFullyPaid)
      .toList();
}

double totalMonthlyPaymentFromSummaries(
  List<LoanSummary> summaries, {
  DateTime? now,
}) => costingLoanSummaries(
  summaries,
  now: now ?? DateTime.now(),
).fold(0.0, (sum, summary) => sum + summary.loan.monthlyPayment);
