import 'package:test/test.dart';
import 'package:domain/domain.dart';
import '../helpers/transaction_helper.dart';

/// Borrowing is an inflow: it raises cash and the runway with it, and the
/// other side of the same transaction had nowhere on the dashboard to appear
/// (#202). This is the figure that gives it somewhere.
void main() {
  final now = DateTime(2026, 6, 1);

  List<LoanSummary> summarise(List<Loan> loans, List<Transaction> txs) =>
      computeLoanSummaries(loans: loans, transactions: txs, now: now);

  group('totalOutstandingFromSummaries', () {
    test('is zero with nothing borrowed', () {
      expect(totalOutstandingFromSummaries(const [], now: now), 0);
    });

    test('is the principal before a payment is made', () {
      final loans = [
        makeLoan(
          id: 'a',
          name: 'Car',
          originalAmount: 500000,
          monthlyPayment: 15000,
        ),
      ];
      expect(
        totalOutstandingFromSummaries(summarise(loans, []), now: now),
        500000,
      );
    });

    test('falls by what has been repaid, and sums across loans', () {
      final loans = [
        makeLoan(
          id: 'a',
          name: 'Car',
          originalAmount: 500000,
          monthlyPayment: 15000,
        ),
        makeLoan(
          id: 'b',
          name: 'Study',
          originalAmount: 200000,
          monthlyPayment: 5000,
        ),
      ];
      final txs = [
        makeTx(
          year: 2026,
          month: 1,
          day: 1,
          type: TransactionType.repayment,
          amount: 30000,
          loanId: 'a',
        ),
      ];
      expect(
        totalOutstandingFromSummaries(summarise(loans, txs), now: now),
        670000,
      );
    });

    test('a settled loan owes nothing', () {
      // Marking a loan settled is the only way to say a commitment is over.
      // It must leave the figure, or OWED would disagree with the count the
      // liabilities panel shows beside it.
      final loans = [
        makeLoan(
          id: 'a',
          name: 'Car',
          originalAmount: 500000,
          monthlyPayment: 15000,
          isActive: false,
        ),
      ];
      expect(totalOutstandingFromSummaries(summarise(loans, []), now: now), 0);
    });

    test('overpaying a loan does not reduce what another one owes', () {
      // A loan repaid past its principal has a negative remainingBalance. Let
      // that through and one overpaid loan quietly discounts the rest, which
      // would understate the debt the card exists to show.
      final loans = [
        makeLoan(
          id: 'a',
          name: 'Car',
          originalAmount: 100000,
          monthlyPayment: 10000,
        ),
        makeLoan(
          id: 'b',
          name: 'Study',
          originalAmount: 200000,
          monthlyPayment: 5000,
        ),
      ];
      final txs = [
        makeTx(
          year: 2026,
          month: 1,
          day: 1,
          type: TransactionType.repayment,
          amount: 150000,
          loanId: 'a',
        ),
      ];
      expect(
        totalOutstandingFromSummaries(summarise(loans, txs), now: now),
        200000,
      );
    });
  });
}
