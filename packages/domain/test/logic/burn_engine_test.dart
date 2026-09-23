import 'package:domain/domain.dart';
import 'package:test/test.dart';

final _now = DateTime(
  2026,
  9,
  15,
); // September has 30 days: 16 left, counting today.

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

Subscription _subscription(double monthly, {int billingDay = 1}) =>
    Subscription(
      id: 'sub-1',
      name: 'Music',
      category: SubscriptionCategory.values.first,
      amount: monthly,
      cycle: BillingCycle.monthly,
      startDate: DateTime(2026, 1, billingDay),
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
  _typicalOverElapsedMonths();
  _readsLongTests();

  test(
    'a logged expense uses up the living budget instead of adding to it',
    () {
      final burn = _burn(
        budget: _budget,
        transactions: [_tx('lunch', TransactionType.expense, 210, _now)],
      );

      expect(burn.total, 62000);
      expect(burn.living.spentThisMonth, 210);
      expect(burn.living.leftThisMonth, 29790);
      expect(burn.rent.leftThisMonth, 32000);
      expect(burn.dueThisMonth, 61790);
    },
  );

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

  test('income, loans received and opening balances are not burn', () {
    final burn = _burn(
      transactions: [
        _tx(
          'open',
          TransactionType.openingBalance,
          500000,
          DateTime(2026, 8, 1),
        ),
        _tx('salary', TransactionType.income, 90000, _now),
        _tx('loan', TransactionType.loan, 100000, _now),
      ],
    );

    expect(burn.total, 0);
    expect(burn.dueThisMonth, 0);
  });

  test('a subscription billed this month is owed until it is confirmed', () {
    // It bills on the 1st and today is the 15th, but nobody has answered for
    // it yet, so it is in neither cash nor the month's cost. Leaving it out of
    // both pushed the runway long.
    final burn = _burn(subscriptions: [_subscription(3000)]);

    // The normalised figure stays as the forward run rate for future months.
    expect(burn.total, 3000);
    expect(burn.dueThisMonth, 3000);
  });

  test('a confirmed subscription charge is out of cash, not owed again', () {
    final confirmed = _tx(
      subscriptionChargeId('sub-1', DateTime(2026, 9, 1)),
      TransactionType.subscriptionCharge,
      3000,
      DateTime(2026, 9, 1),
    );
    final burn = _burn(
      subscriptions: [_subscription(3000)],
      transactions: [confirmed],
    );

    expect(burn.total, 3000, reason: 'still the forward run rate');
    expect(burn.dueThisMonth, 0);
  });

  test('a subscription still ahead this month is owed in full', () {
    // Not pro-rated: the 28th either takes the whole 3000 or none of it.
    final burn = _burn(subscriptions: [_subscription(3000, billingDay: 28)]);

    expect(burn.total, 3000);
    expect(burn.dueThisMonth, 3000);
  });

  test('every expense except rent counts as living', () {
    expect(countsAsLiving(_tx('a', TransactionType.expense, 1, _now)), isTrue);
    expect(
      countsAsLiving(
        _tx(
          'b',
          TransactionType.expense,
          1,
          _now,
          category: ExpenseCategory.food,
        ),
      ),
      isTrue,
    );
    final rent = _tx(
      'c',
      TransactionType.expense,
      1,
      _now,
      category: ExpenseCategory.rent,
    );
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

void _readsLongTests() {
  Transaction entry(
    String id,
    DateTime date,
    TransactionType type,
    double amount, {
    String? loanId,
  }) => Transaction(
    id: id,
    date: date,
    type: type,
    amount: Money(amount),
    loanId: loanId,
    createdAt: date,
    updatedAt: date,
  );

  group('the rest of the month is charged on the same basis as later months', () {
    test('with no budget set, the month still costs typical spending', () {
      // The default Budget() is 0/0 and nothing gates the runway on it, so
      // charging the budget remainder handed a new user a free month.
      final now = DateTime(2026, 9, 1);
      final txs = [
        entry(
          'ob',
          DateTime(2026, 8, 1),
          TransactionType.openingBalance,
          400000,
        ),
        entry('aug', DateTime(2026, 8, 10), TransactionType.expense, 40000),
      ];
      final burn = computeMonthlyBurn(
        transactions: txs,
        budget: const Budget(),
        loans: const [],
        subscriptions: const [],
        now: now,
      );

      expect(burn.living.monthlyEstimate, 40000);
      expect(burn.living.remainingThisMonth, 40000);
      expect(burn.dueThisMonth, 40000);
      expect(
        computeModel(
          currentCash: currentCashAsOf(transactions: txs, now: now),
          burn: burn,
        ).runwayMonths,
        9,
      );
    });

    test('a budget above typical spending still drives the remainder', () {
      final now = DateTime(2026, 9, 16);
      final txs = [
        entry(
          'ob',
          DateTime(2026, 9, 1),
          TransactionType.openingBalance,
          34000,
        ),
        entry('lunch', DateTime(2026, 9, 6), TransactionType.expense, 18),
      ];
      final burn = computeMonthlyBurn(
        transactions: txs,
        budget: const Budget(rent: 1450, living: 1100),
        loans: const [],
        subscriptions: const [],
        now: now,
      );

      // Budget is the floor, so the remainder is the budget less what is spent.
      expect(burn.living.remainingThisMonth, 1082);
      expect(burn.living.leftThisMonth, 1082);
    });
  });

  group('entries dated later have not happened', () {
    final now = DateTime(2026, 9, 15);
    const budget = Budget(rent: 32000, living: 30000);

    List<Transaction> base() => [
      entry('ob', DateTime(2026, 9, 1), TransactionType.openingBalance, 100000),
    ];

    MonthlyBurn burnFor(List<Transaction> txs) => computeMonthlyBurn(
      transactions: txs,
      budget: budget,
      loans: const [],
      subscriptions: const [],
      now: now,
    );

    test('an expense dated later this month does not pay for the month', () {
      // Cash already ignores it, so counting it as spent let the month be
      // part-paid in advance and lengthened the runway.
      final planned = [
        ...base(),
        entry('f', DateTime(2026, 9, 28), TransactionType.expense, 30000),
      ];

      expect(burnFor(planned).dueThisMonth, burnFor(base()).dueThisMonth);
      expect(burnFor(planned).living.spentThisMonth, 0);
    });

    test('an expense dated today does count', () {
      final today = [...base(), entry('t', now, TransactionType.expense, 5000)];

      expect(burnFor(today).living.spentThisMonth, 5000);
    });

    test('a repayment dated later this month does not satisfy it', () {
      final loan = Loan(
        id: 'l',
        name: 'Student loan',
        source: 'Bank',
        originalAmount: 100000,
        monthlyPayment: 10000,
        startDate: DateTime(2024, 1, 1),
        createdAt: now,
        updatedAt: now,
      );
      final later = [
        entry(
          'r',
          DateTime(2026, 9, 30),
          TransactionType.repayment,
          10000,
          loanId: 'l',
        ),
      ];

      final summary = computeLoanSummaries(
        loans: [loan],
        transactions: later,
        now: now,
      ).first;

      expect(summary.paidThisMonth, 0);
      expect(summary.remainingBalance, 100000);
      expect(summary.isFullyPaid, isFalse);
    });
  });
}

/// Typical spending used to be averaged over the months that happened to hold
/// an entry, not over the months that had passed. Someone who logged 40,000 in
/// January and nothing afterwards divided by one for ever, so "typical" stayed
/// at 40,000 and the runway stayed short — and the app treats logging
/// intermittently as normal, because budgets are the primary basis.
void _typicalOverElapsedMonths() {
  group('typical spending', () {
    final now = DateTime(2026, 9, 15);

    List<Transaction> onlyJanuary() => [
      _tx('open', TransactionType.openingBalance, 100000, DateTime(2026, 1, 1)),
      _tx('jan', TransactionType.expense, 40000, DateTime(2026, 1, 10)),
    ];

    test('divides by the months that passed, not the months with entries', () {
      final burn = _burn(
        transactions: onlyJanuary(),
        budget: const Budget(living: 1),
        now: now,
      );
      // January to August is eight completed months. 40,000 over eight.
      expect(burn.living.typicalSpending, closeTo(5000, 0.01));
    });

    test('a quiet month lowers it, because it was still lived through', () {
      final early = _burn(
        transactions: onlyJanuary(),
        budget: const Budget(living: 1),
        now: DateTime(2026, 3, 15),
      );
      final later = _burn(
        transactions: onlyJanuary(),
        budget: const Budget(living: 1),
        now: DateTime(2026, 9, 15),
      );
      expect(
        later.living.typicalSpending,
        lessThan(early.living.typicalSpending),
        reason: 'six more quiet months have to bring the average down',
      );
    });

    test('no backdated entry of any kind stretches the average', () {
      // The date picker reaches back to 2020 for every type, not just an
      // opening balance. None of these is a month lived through with the app,
      // and none of them adds anything to divide over, so each would push the
      // divisor from eight to eighty and read as a tenth of the real burn.
      for (final type in TransactionType.values) {
        if (type == TransactionType.expense) continue;
        final burn = _burn(
          transactions: [
            _tx('old', type, 100000, DateTime(2020, 1, 1)),
            ...onlyJanuary().where(
              (t) => t.type != TransactionType.openingBalance,
            ),
          ],
          budget: const Budget(living: 1),
          now: now,
        );
        expect(
          burn.living.typicalSpending,
          closeTo(5000, 0.01),
          reason: 'a backdated ${type.name} moved the window',
        );
      }
    });

    test('a balance backdated years does not stretch the average', () {
      // The date picker on an opening balance reaches back to 2020, and the
      // figure is a statement about the past, not a month lived with the app.
      // Counting it would divide six months of spending by eighty.
      final burn = _burn(
        transactions: [
          _tx(
            'open',
            TransactionType.openingBalance,
            100000,
            DateTime(2020, 1, 1),
          ),
          ...onlyJanuary().where(
            (t) => t.type != TransactionType.openingBalance,
          ),
        ],
        budget: const Budget(living: 1),
        now: now,
      );
      expect(
        burn.living.typicalSpending,
        closeTo(5000, 0.01),
        reason: 'the window starts at the first month actually lived through',
      );
    });

    test('the first month falls back to what has been spent so far', () {
      final burn = _burn(
        transactions: [
          _tx(
            'open',
            TransactionType.openingBalance,
            100000,
            DateTime(2026, 9, 1),
          ),
          _tx('a', TransactionType.expense, 700, DateTime(2026, 9, 3)),
        ],
        budget: const Budget(living: 1),
        now: now,
      );
      // No month has completed, so there is nothing to average over yet.
      expect(burn.living.typicalSpending, closeTo(700, 0.01));
    });
  });
}
