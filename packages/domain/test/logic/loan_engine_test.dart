import 'package:test/test.dart';
import 'package:domain/domain.dart';
import '../helpers/transaction_helper.dart';

void main() {
  _costingTests();

  group('computeLoanSummaries', () {
    test('returns empty for no loans', () {
      final result = computeLoanSummaries(
        loans: [],
        transactions: [],
        now: DateTime.now(),
      );
      expect(result, isEmpty);
    });

    test('totalRepaid is zero with no repayments', () {
      final loan = makeLoan(
        id: 'loan1',
        name: 'Test',
        originalAmount: 500000,
        monthlyPayment: 15000,
      );
      final result = computeLoanSummaries(
        loans: [loan],
        transactions: [],
        now: DateTime.now(),
      );
      expect(result.first.totalRepaid, 0);
      expect(result.first.remainingBalance, 500000);
    });

    test('totalRepaid sums matching repayments', () {
      final loan = makeLoan(
        id: 'loan1',
        name: 'Test',
        originalAmount: 500000,
        monthlyPayment: 15000,
      );
      final txs = [
        makeTx(
          year: 2025,
          month: 1,
          day: 1,
          type: TransactionType.repayment,
          amount: 15000,
          loanId: 'loan1',
        ),
        makeTx(
          year: 2025,
          month: 2,
          day: 1,
          type: TransactionType.repayment,
          amount: 15000,
          loanId: 'loan1',
        ),
      ];
      final result = computeLoanSummaries(
        loans: [loan],
        transactions: txs,
        now: DateTime.now(),
      );
      expect(result.first.totalRepaid, 30000);
      expect(result.first.remainingBalance, 470000);
    });

    test('ignores repayments for other loans', () {
      final loan = makeLoan(
        id: 'loan1',
        name: 'Test',
        originalAmount: 500000,
        monthlyPayment: 15000,
      );
      final txs = [
        makeTx(
          year: 2025,
          month: 1,
          day: 1,
          type: TransactionType.repayment,
          amount: 15000,
          loanId: 'loan2',
        ),
      ];
      final result = computeLoanSummaries(
        loans: [loan],
        transactions: txs,
        now: DateTime.now(),
      );
      expect(result.first.totalRepaid, 0);
    });

    test('remainingBalance clamps to zero', () {
      final loan = makeLoan(
        id: 'loan1',
        name: 'Test',
        originalAmount: 10000,
        monthlyPayment: 5000,
      );
      final txs = [
        makeTx(
          year: 2025,
          month: 1,
          day: 1,
          type: TransactionType.repayment,
          amount: 15000,
          loanId: 'loan1',
        ),
      ];
      final result = computeLoanSummaries(
        loans: [loan],
        transactions: txs,
        now: DateTime.now(),
      );
      expect(result.first.remainingBalance, 0);
      expect(result.first.isFullyPaid, true);
    });

    test('repaidRatio calculates correctly', () {
      final loan = makeLoan(
        id: 'loan1',
        name: 'Test',
        originalAmount: 100000,
        monthlyPayment: 10000,
      );
      final txs = [
        makeTx(
          year: 2025,
          month: 1,
          day: 1,
          type: TransactionType.repayment,
          amount: 25000,
          loanId: 'loan1',
        ),
      ];
      final result = computeLoanSummaries(
        loans: [loan],
        transactions: txs,
        now: DateTime.now(),
      );
      expect(result.first.repaidRatio, 0.25);
    });

    test('monthsRemaining calculates correctly', () {
      final loan = makeLoan(
        id: 'loan1',
        name: 'Test',
        originalAmount: 120000,
        monthlyPayment: 10000,
      );
      final txs = [
        makeTx(
          year: 2025,
          month: 1,
          day: 1,
          type: TransactionType.repayment,
          amount: 20000,
          loanId: 'loan1',
        ),
      ];
      final result = computeLoanSummaries(
        loans: [loan],
        transactions: txs,
        now: DateTime.now(),
      );
      expect(result.first.monthsRemaining, 10);
    });

    test('isAheadThisMonth true when paid >= installment', () {
      final loan = makeLoan(
        id: 'loan1',
        name: 'Test',
        originalAmount: 500000,
        monthlyPayment: 15000,
      );
      final now = DateTime.now();
      final txs = [
        Transaction(
          id: 'tx1',
          date: now,
          type: TransactionType.repayment,
          amount: Money(20000),
          loanId: 'loan1',
          createdAt: now,
          updatedAt: now,
        ),
      ];
      final result = computeLoanSummaries(
        loans: [loan],
        transactions: txs,
        now: DateTime.now(),
      );
      expect(result.first.isAheadThisMonth, true);
      expect(result.first.paidThisMonth, 20000);
    });
  });

  group('totalMonthlyPayment', () {
    test('sums active loan payments', () {
      final loans = [
        makeLoan(
          id: 'l1',
          name: 'A',
          originalAmount: 100000,
          monthlyPayment: 10000,
        ),
        makeLoan(
          id: 'l2',
          name: 'B',
          originalAmount: 200000,
          monthlyPayment: 15000,
        ),
      ];
      expect(totalMonthlyPayment(loans), 25000);
    });

    test('excludes inactive loans', () {
      final loans = [
        makeLoan(
          id: 'l1',
          name: 'A',
          originalAmount: 100000,
          monthlyPayment: 10000,
          isActive: true,
        ),
        makeLoan(
          id: 'l2',
          name: 'B',
          originalAmount: 200000,
          monthlyPayment: 15000,
          isActive: false,
        ),
      ];
      expect(totalMonthlyPayment(loans), 10000);
    });

    test('returns zero for empty list', () {
      expect(totalMonthlyPayment([]), 0);
    });
  });

  group('activeLoanSummaries', () {
    test('excludes fully paid loans from active home pressure', () {
      final openLoan = makeLoan(
        id: 'open',
        name: 'Open',
        originalAmount: 100000,
        monthlyPayment: 10000,
      );
      final paidLoan = makeLoan(
        id: 'paid',
        name: 'Paid',
        originalAmount: 50000,
        monthlyPayment: 5000,
      );
      final summaries = computeLoanSummaries(
        now: DateTime.now(),
        loans: [openLoan, paidLoan],
        transactions: [
          makeTx(
            year: 2025,
            month: 1,
            day: 1,
            type: TransactionType.repayment,
            amount: 50000,
            loanId: 'paid',
          ),
        ],
      );

      final active = activeLoanSummaries(summaries);

      expect(active.map((summary) => summary.loan.id), ['open']);
      expect(totalMonthlyPaymentFromSummaries(summaries), 10000);
    });
  });
}

void _costingTests() {
  Loan loanFrom(DateTime start, {int termMonths = 0, bool isActive = true}) =>
      Loan(
        id: 'l1',
        name: 'Student loan',
        source: 'Bank',
        originalAmount: 18000,
        monthlyPayment: 210,
        originalTermMonths: termMonths,
        startDate: start,
        isActive: isActive,
        createdAt: start,
        updatedAt: start,
      );

  LoanSummary summaryOf(Loan loan, {double repaid = 0}) => LoanSummary(
    loan: loan,
    totalRepaid: repaid,
    remainingBalance: (loan.originalAmount - repaid).clamp(0, double.infinity),
    paidThisMonth: 0,
  );

  group('a loan keeps costing until its term ends', () {
    test('repaid principal does not stop the monthly payment', () {
      // Every rupee of principal is repaid, but interest means payments go on.
      final loan = loanFrom(DateTime(2020, 1, 1), termMonths: 96);
      final summary = summaryOf(loan, repaid: 18000);

      expect(summary.isFullyPaid, isTrue);
      expect(
        costingLoanSummaries([summary], now: DateTime(2026, 9, 16)),
        hasLength(1),
      );
      expect(
        totalMonthlyPaymentFromSummaries([summary], now: DateTime(2026, 9, 16)),
        210,
      );
    });

    test('a term starting at the end of a month ends inside one', () {
      // DateTime rolls a day past the end of a month into the next one, so a
      // loan taken out on 31 August over six months used to run to 3 March
      // and keep costing the runway for three days it did not owe.
      final loan = loanFrom(DateTime(2025, 8, 31), termMonths: 6);

      expect(loanTermEnd(loan), DateTime(2026, 2, 28));
      expect(
        costingLoanSummaries([summaryOf(loan)], now: DateTime(2026, 3, 1)),
        isEmpty,
      );
    });

    test('a leap February takes the 29th', () {
      final loan = loanFrom(DateTime(2023, 8, 31), termMonths: 6);

      expect(loanTermEnd(loan), DateTime(2024, 2, 29));
    });

    test('a loan past its term stops counting', () {
      final loan = loanFrom(DateTime(2020, 1, 1), termMonths: 12);

      expect(
        costingLoanSummaries([summaryOf(loan)], now: DateTime(2026, 9, 16)),
        isEmpty,
      );
    });

    test('a loan with no term counts until it is made inactive', () {
      final open = loanFrom(DateTime(2020, 1, 1));
      final closed = loanFrom(DateTime(2020, 1, 1), isActive: false);
      final now = DateTime(2026, 9, 16);

      expect(costingLoanSummaries([summaryOf(open)], now: now), hasLength(1));
      expect(costingLoanSummaries([summaryOf(closed)], now: now), isEmpty);
    });

    test('a loan that still costs money stays on the list', () {
      // It used to drop off here: repaid principal ended it for the list while
      // the term kept it costing, so the payment went on being subtracted from
      // the runway with nothing on screen to explain it, and no way to record
      // the payment that would net it off.
      final loan = loanFrom(DateTime(2020, 1, 1), termMonths: 96);
      final summary = summaryOf(loan, repaid: 18000);
      final now = DateTime(2026, 9, 16);

      expect(summary.isFullyPaid, isTrue);
      expect(loanIsCosting(summary, now: now), isTrue);
      expect(activeLoanSummaries([summary], now: now), hasLength(1));
    });

    test('a repayment does not land on a loan that is already repaid', () {
      // The settled loan sorts first alphabetically, and the form preselects
      // the first target. Before this it took the payment, where the balance
      // clamp hid it and the real loan kept its installment reserved.
      final now = DateTime(2026, 9, 16);
      final settled = LoanSummary(
        loan: loanFrom(
          DateTime(2020, 1, 1),
          termMonths: 96,
        ).copyWith(id: 'settled', name: 'Acme'),
        totalRepaid: 18000,
        remainingBalance: 0,
        paidThisMonth: 0,
      );
      final owing = LoanSummary(
        loan: loanFrom(
          DateTime(2020, 1, 1),
          termMonths: 96,
        ).copyWith(id: 'owing', name: 'Zenith'),
        totalRepaid: 0,
        remainingBalance: 18000,
        paidThisMonth: 0,
      );

      final targets = repaymentTargets([settled, owing], now: now);

      expect(targets.map((loan) => loan.id), ['owing', 'settled']);
    });

    test('the loan an edited entry already names is offered even when it is '
        'closed', () {
      final now = DateTime(2026, 9, 16);
      final closed = summaryOf(loanFrom(DateTime(2020, 1, 1), isActive: false));

      expect(repaymentTargets([closed], now: now), isEmpty);
      expect(
        repaymentTargets(
          [closed],
          existingLoanId: 'l1',
          now: now,
        ).map((loan) => loan.id),
        ['l1'],
      );
    });

    test('a loan that is finished with drops off the list', () {
      final loan = loanFrom(DateTime(2020, 1, 1), termMonths: 12);
      final summary = summaryOf(loan, repaid: 18000);
      final now = DateTime(2026, 9, 16);

      expect(loanIsCosting(summary, now: now), isFalse);
      expect(activeLoanSummaries([summary], now: now), isEmpty);
    });
  });
}
