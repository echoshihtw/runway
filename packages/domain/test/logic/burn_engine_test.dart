import 'package:domain/domain.dart';
import 'package:test/test.dart';

final _now = DateTime(2026, 9, 15); // September has 30 days: 16 left, counting today.

Transaction _tx(
  String id,
  TransactionType type,
  double amount,
  DateTime date, {
  ExpenseCategory? category,
  String? loanId,
}) => Transaction(
  id: id,
  date: date,
  type: type,
  amount: Money(amount),
  category: category,
  loanId: loanId,
  createdAt: date,
  updatedAt: date,
);

LoanSummary _loan({required double payment, double paidThisMonth = 0}) =>
    LoanSummary(
      loan: Loan(
        id: 'loan-1',
        name: 'Bank',
        source: 'bank',
        originalAmount: 100000,
        monthlyPayment: payment,
        startDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
      totalRepaid: paidThisMonth,
      remainingBalance: 100000 - paidThisMonth,
      paidThisMonth: paidThisMonth,
    );

Subscription _subscription(double monthly) => Subscription(
  id: 'sub-1',
  name: 'Music',
  category: SubscriptionCategory.values.first,
  amount: monthly,
  cycle: BillingCycle.monthly,
  startDate: DateTime(2026, 1, 1),
  nextBillingDate: DateTime(2026, 10, 1),
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

MonthlyBurn _burn({
  List<Transaction> transactions = const [],
  Budget budget = const Budget(),
  List<LoanSummary> loans = const [],
  List<Subscription> subscriptions = const [],
  DateTime? now,
}) => computeMonthlyBurn(
  transactions: transactions,
  budget: budget,
  loans: loans,
  subscriptions: subscriptions,
  now: now ?? _now,
);

const _budget = Budget(rent: 32000, living: 30000);

void main() {
  test('a logged expense uses up the living budget instead of adding to it', () {
    final burn = _burn(
      budget: _budget,
      transactions: [_tx('lunch', TransactionType.expense, 210, _now)],
    );

    expect(burn.total, 62000);
    expect(burn.living.spentThisMonth, 210);
    expect(burn.living.leftThisMonth, 29790);
    expect(burn.rent.leftThisMonth, 32000);
    expect(burn.dueThisMonth, 61790);
  });

  test('rent logged with the rent category is not counted twice', () {
    final burn = _burn(
      budget: _budget,
      transactions: [
        _tx('lunch', TransactionType.expense, 210, _now),
        _tx(
          'rent',
          TransactionType.expense,
          32000,
          DateTime(2026, 9, 1),
          category: ExpenseCategory.rent,
        ),
      ],
    );

    expect(burn.total, 62000);
    expect(burn.rent.leftThisMonth, 0);
    expect(burn.living.spentThisMonth, 210);
    expect(burn.dueThisMonth, 29790);
  });

  test('going over budget in a completed month raises the burn', () {
    final burn = _burn(
      budget: _budget,
      transactions: [
        _tx('august', TransactionType.expense, 31500, DateTime(2026, 8, 20)),
      ],
    );

    expect(burn.living.monthlyEstimate, 31500);
    expect(burn.total, 63500);
  });

  test('uncategorized and non-rent expenses count as living', () {
    final burn = _burn(
      transactions: [
        _tx('lunch', TransactionType.expense, 210, _now),
        _tx(
          'bus',
          TransactionType.expense,
          90,
          _now,
          category: ExpenseCategory.transport,
        ),
      ],
    );

    expect(burn.living.spentThisMonth, 300);
    expect(burn.rent.spentThisMonth, 0);
  });

  test('without earlier months, this month\'s spending is the estimate', () {
    final burn = _burn(
      transactions: [_tx('lunch', TransactionType.expense, 210, _now)],
    );

    expect(burn.total, 210);
  });

  test('loan repayments count only against their loan', () {
    final burn = _burn(
      budget: _budget,
      loans: [_loan(payment: 10000, paidThisMonth: 4000)],
      transactions: [
        _tx('repay', TransactionType.repayment, 4000, _now, loanId: 'loan-1'),
      ],
    );

    expect(burn.living.spentThisMonth, 0);
    expect(burn.loanPayments, 10000);
    expect(burn.loanPaymentsLeftThisMonth, 6000);
    expect(burn.total, 72000);
  });

  test('income, loans received, investments and opening balances are not burn', () {
    final burn = _burn(
      transactions: [
        _tx('open', TransactionType.openingBalance, 500000, DateTime(2026, 8, 1)),
        _tx('salary', TransactionType.income, 90000, _now),
        _tx('loan', TransactionType.loan, 100000, _now),
        _tx('etf', TransactionType.investment, 20000, _now),
      ],
    );

    expect(burn.total, 0);
    expect(burn.dueThisMonth, 0);
  });

  test('subscriptions are spread over what is left of the month', () {
    final burn = _burn(subscriptions: [_subscription(3000)]);

    expect(burn.total, 3000);
    expect(burn.dueThisMonth, closeTo(3000 * 16 / 30, 0.001));
  });

  test('every expense except rent counts as living', () {
    expect(countsAsLiving(_tx('a', TransactionType.expense, 1, _now)), isTrue);
    expect(
      countsAsLiving(
        _tx('b', TransactionType.expense, 1, _now, category: ExpenseCategory.food),
      ),
      isTrue,
    );
    final rent = _tx('c', TransactionType.expense, 1, _now, category: ExpenseCategory.rent);
    expect(countsAsLiving(rent), isFalse);
    expect(countsAsRent(rent), isTrue);
    expect(countsAsLiving(_tx('d', TransactionType.income, 1, _now)), isFalse);
  });

  test('days left this month counts today', () {
    expect(_burn().daysLeftThisMonth, 16);
    expect(_burn(now: DateTime(2026, 9, 30)).daysLeftThisMonth, 1);
    expect(_burn(now: DateTime(2026, 2, 1)).daysLeftThisMonth, 28);
  });

  test('the share of the month left counts today', () {
    expect(_burn(now: DateTime(2026, 9, 1)).fractionOfMonthLeft, 1.0);
    expect(_burn(now: DateTime(2026, 9, 30)).fractionOfMonthLeft, 1 / 30);
  });
}
