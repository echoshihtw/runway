import 'loan.dart';

class LoanSummary {
  final Loan loan;
  final double totalRepaid;
  final double remainingBalance;
  final double paidThisMonth;

  const LoanSummary({
    required this.loan,
    required this.totalRepaid,
    required this.remainingBalance,
    required this.paidThisMonth,
  });

  double get repaidRatio => loan.originalAmount > 0
      ? (totalRepaid / loan.originalAmount).clamp(0.0, 1.0)
      : 0.0;

  /// Whether the principal has been repaid. Display only: `remainingBalance`
  /// ignores interest, so this can be true while the lender is still charging.
  bool get isFullyPaid => remainingBalance <= 0;

  int get monthsRemaining {
    if (isFullyPaid) return 0;
    if (loan.originalTermMonths > 0) {
      final now = DateTime.now();
      final start = loan.startDate;
      final elapsed = (now.year - start.year) * 12 + (now.month - start.month);
      return (loan.originalTermMonths - elapsed).clamp(
        0,
        loan.originalTermMonths,
      );
    }
    return loan.monthlyPayment > 0
        ? (remainingBalance / loan.monthlyPayment).ceil().clamp(0, 9999)
        : 0;
  }

  bool get isAheadThisMonth => paidThisMonth >= loan.monthlyPayment;
}
