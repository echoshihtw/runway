import 'package:domain/domain.dart';
import 'package:test/test.dart';

Loan _loan({bool isActive = true}) => Loan(
  id: 'loan-1',
  name: 'Bank',
  source: 'bank',
  originalAmount: 10000,
  monthlyPayment: 1000,
  startDate: DateTime(2026, 1, 1),
  isActive: isActive,
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

Transaction _repayment(double amount) => Transaction(
  id: 'repay-$amount',
  date: DateTime(2026, 3, 1),
  type: TransactionType.repayment,
  amount: Money(amount),
  loanId: 'loan-1',
  createdAt: DateTime(2026, 3, 1),
  updatedAt: DateTime(2026, 3, 1),
);

void main() {
  test('no loans means no active loan', () {
    expect(hasActiveLoan(loans: const [], transactions: const []), isFalse);
  });

  test('an unpaid loan is active', () {
    expect(
      hasActiveLoan(loans: [_loan()], transactions: [_repayment(4000)]),
      isTrue,
    );
  });

  test('a paid-off loan no longer counts, so another loan can be added', () {
    expect(
      hasActiveLoan(loans: [_loan()], transactions: [_repayment(10000)]),
      isFalse,
    );
  });

  test('an inactive loan does not count', () {
    expect(
      hasActiveLoan(loans: [_loan(isActive: false)], transactions: const []),
      isFalse,
    );
  });
}
