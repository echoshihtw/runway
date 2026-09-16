import 'package:domain/domain.dart';
import 'package:test/test.dart';

const _budget = Budget(rent: 32000, living: 30000);

ModelState _model({
  required double cash,
  required DateTime now,
  Budget budget = _budget,
  List<Transaction> transactions = const [],
  List<Subscription> subscriptions = const [],
  double? expectedMonthlyInflow,
  double? expectedMonthlyBurnOverride,
}) => computeModel(
  currentCash: cash,
  burn: computeMonthlyBurn(
    transactions: transactions,
    budget: budget,
    loans: const [],
    subscriptions: subscriptions,
    now: now,
  ),
  expectedMonthlyInflow: expectedMonthlyInflow,
  expectedMonthlyBurnOverride: expectedMonthlyBurnOverride,
);

Transaction _lunch(DateTime date) => Transaction(
  id: 'lunch',
  date: date,
  type: TransactionType.expense,
  amount: Money(210),
  createdAt: date,
  updatedAt: date,
);

void main() {
  _unknownRunwayTests();

  _scenarioBasisTests();

  _cashAndStatusTests();

  group('runway from today', () {
    test('covers the rest of this month, then full months of burn', () {
      // 999,790 cash. The rest of September still costs 61,790, leaving
      // 938,000 = 15.1 months of 62,000. Plus 16 of 30 days: 15.7 months.
      final now = DateTime(2026, 9, 15);
      final m = _model(cash: 999790, now: now, transactions: [_lunch(now)]);

      expect(m.effectiveBurnRate, 62000);
      expect(m.runwayMonths, 15);
      expect(m.runOutDate, DateTime(2028, 1, 1));
      expect(m.runwayStatus, RunwayStatus.stable);
    });

    test('on the first day the whole month is still ahead', () {
      final now = DateTime(2026, 9, 1);
      final m = _model(cash: 999790, now: now, transactions: [_lunch(now)]);

      expect(m.runwayMonths, 16);
      expect(m.runOutDate, DateTime(2028, 1, 1));
    });

    test('cash that does not cover this month runs out this month', () {
      final m = _model(cash: 20000, now: DateTime(2026, 9, 15));

      expect(m.runwayMonths, 0);
      expect(m.runOutDate, DateTime(2026, 9, 1));
      expect(m.runwayStatus, RunwayStatus.critical);
    });

    test('no burn means unlimited runway', () {
      final m = _model(
        cash: 1000,
        now: DateTime(2026, 9, 15),
        budget: const Budget(),
      );

      expect(m.runwayMonths, 9999);
      expect(m.runwayDays, 99999);
      expect(m.runOutDate, isNull);
    });

    test('runway has no cap', () {
      final m = _model(
        cash: 300000,
        now: DateTime(2026, 9, 1),
        budget: const Budget(living: 167),
      );

      expect(m.runwayMonths, greaterThan(120));
    });
  });

  test('subscriptions shorten runway', () {
    final now = DateTime(2026, 9, 15);
    final withSubscription = _model(
      cash: 999790,
      now: now,
      subscriptions: [
        Subscription(
          id: 'sub-1',
          name: 'Music',
          category: SubscriptionCategory.values.first,
          amount: 10000,
          cycle: BillingCycle.monthly,
          startDate: DateTime(2026, 1, 1),
          nextBillingDate: DateTime(2026, 10, 1),
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ],
    );
    final without = _model(cash: 999790, now: now);

    expect(withSubscription.subscriptionMonthlyCost, 10000);
    expect(withSubscription.runwayMonths, lessThan(without.runwayMonths));
  });

  test('an expected burn override replaces the monthly burn', () {
    final now = DateTime(2026, 9, 15);
    final baseline = _model(cash: 300000, now: now);
    final m = _model(cash: 300000, now: now, expectedMonthlyBurnOverride: 25000);

    expect(m.effectiveBurnRate, 25000);
    expect(m.runwayMonths, greaterThan(baseline.runwayMonths));
  });

  test('expected inflow above burn is sustainable indefinitely', () {
    final m = _model(
      cash: 100000,
      now: DateTime(2026, 9, 15),
      expectedMonthlyInflow: 70000,
    );

    expect(m.emergencyMonthlyBurn, 62000);
    expect(m.sustainableNetMonthlyFlow, 8000);
    expect(m.isSustainableIndefinitely, isTrue);
  });

  test('large cash is stable', () {
    final m = _model(cash: 3000000, now: DateTime(2026, 9, 15));

    expect(m.runwayStatus, RunwayStatus.stable);
  });
}

Transaction _entry(
  DateTime date,
  TransactionType type,
  double amount,
) => Transaction(
  id: 'e-${date.toIso8601String()}-${type.name}',
  date: date,
  type: type,
  amount: Money(amount),
  createdAt: date,
  updatedAt: date,
);

void _cashAndStatusTests() {
  group('cash counts only what has happened', () {
    final now = DateTime(2026, 9, 16);

    test('a future-dated income does not lengthen the runway', () {
      final settled = [_entry(DateTime(2026, 9, 1), TransactionType.openingBalance, 100000)];
      final planned = [...settled, _entry(DateTime(2026, 12, 20), TransactionType.income, 500000)];

      expect(
        currentCashAsOf(transactions: planned, now: now),
        currentCashAsOf(transactions: settled, now: now),
      );
    });

    test('a future-dated expense does not shorten it', () {
      final settled = [_entry(DateTime(2026, 9, 1), TransactionType.openingBalance, 100000)];
      final planned = [...settled, _entry(DateTime(2026, 10, 5), TransactionType.expense, 40000)];

      expect(currentCashAsOf(transactions: planned, now: now), 100000);
    });

    test('an entry dated today counts', () {
      final txs = [
        _entry(DateTime(2026, 9, 1), TransactionType.openingBalance, 100000),
        _entry(now, TransactionType.expense, 10000),
      ];

      expect(currentCashAsOf(transactions: txs, now: now), 90000);
    });
  });

  group('status bands', () {
    ModelState atMonths(int months) => ModelState(
      currentCash: 0,
      burnRate: 0,
      effectiveBurnRate: 0,
      monthlyPayment: 0,
      subscriptionMonthlyCost: 0,
      runwayMonths: months,
      runwayDays: months * 30,
    );

    test('under three months is critical', () {
      expect(atMonths(0).runwayStatus, RunwayStatus.critical);
      expect(atMonths(2).runwayStatus, RunwayStatus.critical);
    });

    test('three to six months is caution', () {
      expect(atMonths(3).runwayStatus, RunwayStatus.caution);
      expect(atMonths(5).runwayStatus, RunwayStatus.caution);
    });

    test('above six months is stable', () {
      expect(atMonths(6).runwayStatus, RunwayStatus.stable);
      expect(atMonths(12).runwayStatus, RunwayStatus.stable);
    });
  });

  group('scenario shares the dashboard basis', () {
    final now = DateTime(2026, 9, 16);

    MonthlyBurn burnAt(DateTime when) => computeMonthlyBurn(
      transactions: [_lunch(when)],
      budget: _budget,
      loans: const [],
      subscriptions: const [],
      now: when,
    );

    test('no changes returns the dashboard runway', () {
      final burn = burnAt(now);
      final dashboard = computeModel(currentCash: 999790, burn: burn);
      final scenario = modelForScenario(currentCash: 999790, burn: burn);

      expect(scenario.runwayMonths, dashboard.runwayMonths);
      expect(scenario.runOutDate, dashboard.runOutDate);
      expect(scenario.effectiveBurnRate, dashboard.effectiveBurnRate);
    });

    test('a lower cost only saves the part of the month still to come', () {
      final burn = burnAt(now);
      final cut = modelForScenario(
        currentCash: 999790,
        burn: burn,
        monthlyCostOverride: burn.variableBurn - 30000,
      );

      expect(cut.effectiveBurnRate, burn.total - 30000);
      expect(cut.runwayMonths, greaterThan(computeModel(currentCash: 999790, burn: burn).runwayMonths));
    });
  });
}

void _scenarioBasisTests() {
  final now = DateTime(2026, 9, 16);

  MonthlyBurn burnAt() => computeMonthlyBurn(
    transactions: const [],
    budget: const Budget(rent: 1450, living: 1100),
    loans: const [],
    subscriptions: const [],
    now: now,
  );

  group('a scenario starts from the basis the dashboard uses', () {
    test('no change, no assumption, equals the dashboard', () {
      final burn = burnAt();
      final dashboard = computeModel(currentCash: 34000, burn: burn);
      final scenario = modelForScenario(currentCash: 34000, burn: burn);

      expect(scenario.runwayMonths, dashboard.runwayMonths);
      expect(scenario.runOutDate, dashboard.runOutDate);
    });

    test('no change with an assumption active equals the dashboard', () {
      // Previously the scenario ignored the assumption, so simulating nothing
      // reported losing five months.
      final burn = burnAt();
      final dashboard = computeModel(
        currentCash: 34000,
        burn: burn,
        expectedMonthlyBurnOverride: 2000,
      );
      final scenario = modelForScenario(
        currentCash: 34000,
        burn: burn,
        expectedMonthlyBurnOverride: 2000,
      );

      expect(scenario.runwayMonths, dashboard.runwayMonths);
      expect(scenario.effectiveBurnRate, dashboard.effectiveBurnRate);
      expect(scenario.runwayMonths - dashboard.runwayMonths, 0);
    });

    test('a cut applies to the assumption, not the budget figure', () {
      final burn = burnAt();
      final scenario = modelForScenario(
        currentCash: 34000,
        burn: burn,
        monthlyCostOverride: burn.variableBurn - 250,
        expectedMonthlyBurnOverride: 2000,
      );

      expect(scenario.effectiveBurnRate, 1750);
    });

    test('without an assumption a cut behaves as it always did', () {
      final burn = burnAt();
      final scenario = modelForScenario(
        currentCash: 34000,
        burn: burn,
        monthlyCostOverride: burn.variableBurn - 250,
      );

      expect(scenario.effectiveBurnRate, burn.total - 250);
    });

    test('the scenario reports sustainability on the dashboard footing', () {
      // Nothing renders this on the plan screen today, but leaving the two
      // sides on different assumptions is the bug this group exists to stop.
      final burn = burnAt();
      final dashboard = computeModel(
        currentCash: 34000,
        burn: burn,
        expectedMonthlyInflow: 2400,
      );
      final scenario = modelForScenario(
        currentCash: 34000,
        burn: burn,
        expectedMonthlyInflow: 2400,
      );

      expect(scenario.hasSustainableProjection, isTrue);
      expect(
        scenario.sustainableMonthlyShortfall,
        dashboard.sustainableMonthlyShortfall,
      );
      // And it still does not move the number.
      expect(scenario.runwayMonths, dashboard.runwayMonths);
    });

    test('simulated income above costs gives an unlimited runway', () {
      final burn = burnAt();
      final scenario = modelForScenario(
        currentCash: 34000,
        burn: burn,
        simulatedIncome: burn.total + 1,
      );

      expect(scenario.runwayMonths, 9999);
    });
  });
}

void _unknownRunwayTests() {
  final now = DateTime(2026, 9, 16);

  Transaction cash(double amount) => Transaction(
    id: 'ob',
    date: now,
    type: TransactionType.openingBalance,
    amount: Money(amount),
    createdAt: now,
    updatedAt: now,
  );

  MonthlyBurn burnWith({
    Budget budget = const Budget(),
    List<Transaction> transactions = const [],
  }) => computeMonthlyBurn(
    transactions: transactions,
    budget: budget,
    loans: const [],
    subscriptions: const [],
    now: now,
  );

  group('a cost of zero means unknown, not unlimited', () {
    test('cash entered and nothing else leaves the runway unknown', () {
      // Exactly what onboarding instructs: enter your balance. This used to
      // report 9999 months and a stable status.
      final burn = burnWith(transactions: [cash(34000)]);
      final model = computeModel(currentCash: 34000, burn: burn);

      expect(burn.total, 0);
      expect(model.hasCostBasis, isFalse);
      expect(model.runwayIsKnown, isFalse);
    });

    test('no data at all is also unknown, not zero months', () {
      final model = computeModel(currentCash: 0, burn: burnWith());

      expect(model.hasCostBasis, isFalse);
    });

    test('a budget alone is enough of a basis', () {
      final burn = burnWith(budget: const Budget(rent: 200, living: 500));
      final model = computeModel(currentCash: 34000, burn: burn);

      expect(model.hasCostBasis, isTrue);
      expect(model.runwayMonths, greaterThan(0));
    });

    test('an expected cost assumption is a basis on its own', () {
      final model = computeModel(
        currentCash: 34000,
        burn: burnWith(),
        expectedMonthlyBurnOverride: 2000,
      );

      expect(model.hasCostBasis, isTrue);
      expect(model.runwayMonths, 17);
    });

    test('simulated income covering costs stays genuinely unlimited', () {
      // The distinction that matters: this runway is unlimited *and* known.
      final burn = burnWith(budget: const Budget(rent: 200, living: 500));
      final scenario = modelForScenario(
        currentCash: 34000,
        burn: burn,
        simulatedIncome: burn.total + 1,
      );

      expect(scenario.hasCostBasis, isTrue);
      expect(scenario.runwayMonths, 9999);
    });
  });
}
