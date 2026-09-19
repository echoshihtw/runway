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
  // what the month still owed and cut the remaining balance.
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
bool loanIsCosting(LoanSummary summary, {required DateTime now}) {
  if (!summary.loan.isActive) return false;
  final end = loanTermEnd(summary.loan);
  // With a term, the term governs: repaid principal does not mean the payments
  // stopped. Without a term, repaid principal is the only end available, and it
  // is the right one for an interest-free loan, where payment = amount / months.
  return end == null ? !summary.isFullyPaid : now.isBefore(end);
}

List<LoanSummary> costingLoanSummaries(
  List<LoanSummary> summaries, {
  required DateTime now,
}) => summaries.where((summary) => loanIsCosting(summary, now: now)).toList();

/// Loans to show and to offer a repayment against.
///
/// A loan stays here while it still costs money, even once the principal is
/// repaid. Dropping it at repaid principal hid a loan that the term rule was
/// still charging for: the payment went on being subtracted from the runway
/// with nothing on screen to explain it, and `loanPaymentsLeftThisMonth`
/// reserved the whole payment every month with no way to record paying it.
List<LoanSummary> activeLoanSummaries(
  List<LoanSummary> summaries, {
  DateTime? now,
}) {
  final at = now ?? DateTime.now();
  return summaries
      .where(
        (summary) =>
            summary.loan.isActive &&
            (!summary.isFullyPaid || loanIsCosting(summary, now: at)),
      )
      .toList();
}

/// The loans a repayment may be pointed at, best target first.
///
/// [existingLoanId] is the loan an entry being edited already names: it is
/// included even once that loan is closed, or editing the entry would
/// silently drop its link.
///
/// A loan whose principal is repaid sorts last. It belongs on the list,
/// because its term may still be charging, but it must not be what a
/// repayment lands on by default: the form preselects the first of these, the
/// remaining balance clamps at zero so a misdirected payment leaves no trace
/// on the card, and the loan actually being repaid keeps its installment
/// reserved against the runway.
List<Loan> repaymentTargets(
  List<LoanSummary> summaries, {
  String? existingLoanId,
  DateTime? now,
}) {
  final chosen = activeLoanSummaries(summaries, now: now).toList();

  if (existingLoanId != null &&
      !chosen.any((summary) => summary.loan.id == existingLoanId)) {
    for (final summary in summaries) {
      if (summary.loan.id == existingLoanId) {
        chosen.add(summary);
        break;
      }
    }
  }

  chosen.sort((a, b) {
    if (a.loan.isActive != b.loan.isActive) return a.loan.isActive ? -1 : 1;
    if (a.isFullyPaid != b.isFullyPaid) return a.isFullyPaid ? 1 : -1;
    return a.loan.name.compareTo(b.loan.name);
  });
  return chosen.map((summary) => summary.loan).toList();
}

double totalMonthlyPaymentFromSummaries(
  List<LoanSummary> summaries, {
  DateTime? now,
}) => costingLoanSummaries(
  summaries,
  now: now ?? DateTime.now(),
).fold(0.0, (sum, summary) => sum + summary.loan.monthlyPayment);
