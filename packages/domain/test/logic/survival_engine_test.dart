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
  group('runway from today', () {
    test('covers the rest of this month, then full months of burn', () {
      // 999,790 cash. The rest of September still costs 61,790, leaving
      // 938,000 = 15.1 months of 62,000. Plus 16 of 30 days: 15.7 months.
      final now = DateTime(2026, 9, 15);
      final m = _model(cash: 999790, now: now, transactions: [_lunch(now)]);

      expect(m.effectiveBurnRate, 62000);
      expect(m.runwayMonths, 15);
      expect(m.runOutDate, DateTime(2028, 1, 1));
      expect(m.survivalStatus, SurvivalStatus.caution);
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
      expect(m.survivalStatus, SurvivalStatus.critical);
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

    expect(m.survivalStatus, SurvivalStatus.stable);
  });
}
