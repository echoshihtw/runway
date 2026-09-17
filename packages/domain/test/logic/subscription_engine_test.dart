import 'package:test/test.dart';
import 'package:domain/domain.dart';

void main() {
  group('totalSubscriptionMonthlyCost', () {
    test('returns zero for empty list', () {
      expect(totalSubscriptionMonthlyCost([]), 0.0);
    });

    test('sums monthly equivalent of all active subscriptions', () {
      final subs = [
        _sub(id: '1', amount: 1000, cycle: BillingCycle.monthly),
        _sub(id: '2', amount: 12000, cycle: BillingCycle.yearly), // 1000/month
      ];
      expect(totalSubscriptionMonthlyCost(subs), closeTo(2000, 0.01));
    });

    test('excludes inactive subscriptions', () {
      final subs = [
        _sub(id: '1', amount: 500, cycle: BillingCycle.monthly),
        _sub(id: '2', amount: 999, cycle: BillingCycle.monthly, isActive: false),
      ];
      expect(totalSubscriptionMonthlyCost(subs), 500);
    });

    test('handles all four billing cycles correctly', () {
      // weekly: 100 × 52/12, monthly: 500, quarterly: 900/3, yearly: 12000/12
      final subs = [
        _sub(id: '1', amount: 100, cycle: BillingCycle.weekly),
        _sub(id: '2', amount: 500, cycle: BillingCycle.monthly),
        _sub(id: '3', amount: 900, cycle: BillingCycle.quarterly),
        _sub(id: '4', amount: 12000, cycle: BillingCycle.yearly),
      ];
      final expected = 100 * 52 / 12 + 500 + 900 / 3 + 12000 / 12;
      expect(totalSubscriptionMonthlyCost(subs), closeTo(expected, 0.01));
    });
  });

  group('subscriptionMonthlyCostByCategory', () {
    test('sums only active subscriptions matching the given category', () {
      final subs = [
        _sub(id: '1', amount: 980, category: SubscriptionCategory.personal),
        _sub(id: '2', amount: 2000, category: SubscriptionCategory.business),
        _sub(id: '3', amount: 500, category: SubscriptionCategory.personal, isActive: false),
      ];
      expect(
        subscriptionMonthlyCostByCategory(subs, SubscriptionCategory.personal),
        980,
      );
      expect(
        subscriptionMonthlyCostByCategory(subs, SubscriptionCategory.business),
        2000,
      );
    });

    test('returns zero when no subscriptions match category', () {
      final subs = [_sub(amount: 500, category: SubscriptionCategory.personal)];
      expect(
        subscriptionMonthlyCostByCategory(subs, SubscriptionCategory.business),
        0.0,
      );
    });
  });

  group('totalSubscriptionYearlyCost', () {
    test('equals monthly cost multiplied by 12', () {
      final subs = [_sub(amount: 1000, cycle: BillingCycle.monthly)];
      expect(totalSubscriptionYearlyCost(subs), closeTo(12000, 0.01));
    });

    test('excludes inactive subscriptions', () {
      final subs = [
        _sub(id: '1', amount: 1000, cycle: BillingCycle.monthly),
        _sub(id: '2', amount: 500, cycle: BillingCycle.monthly, isActive: false),
      ];
      expect(totalSubscriptionYearlyCost(subs), closeTo(12000, 0.01));
    });
  });

  group('sortedByNextBilling', () {
    final now = DateTime(2025, 6, 1);

    test('orders by the bill that comes next, derived not stored', () {
      // The stored date is deliberately misleading here: it is never advanced
      // in the app, so ordering by it froze the list in creation order.
      final subs = [
        _sub(id: '3', startDate: DateTime(2025, 6, 15), nextBillingDate: DateTime(2025, 6, 2)),
        _sub(id: '1', startDate: DateTime(2025, 6, 3), nextBillingDate: DateTime(2025, 6, 20)),
        _sub(id: '2', startDate: DateTime(2025, 6, 8), nextBillingDate: DateTime(2025, 6, 9)),
      ];
      expect(sortedByNextBilling(subs, now: now).map((s) => s.id).toList(), [
        '1',
        '2',
        '3',
      ]);
    });

    test('excludes inactive subscriptions from sorted result', () {
      final subs = [
        _sub(id: '1', startDate: DateTime(2025, 6, 3)),
        _sub(id: '2', startDate: DateTime(2025, 6, 1), isActive: false),
      ];
      expect(sortedByNextBilling(subs, now: now).map((s) => s.id).toList(), ['1']);
    });

    test('returns empty list when all subscriptions are inactive', () {
      final subs = [_sub(isActive: false), _sub(id: '2', isActive: false)];
      expect(sortedByNextBilling(subs, now: DateTime(2025, 6, 1)), isEmpty);
    });
  });

  group('computeNextBillingDate', () {
    test('returns future date unchanged', () {
      final future = DateTime.now().add(const Duration(days: 10));
      expect(computeNextBillingDate(future, BillingCycle.monthly), future);
    });

    test('weekly: date 6 days ago advances by one week', () {
      final sixDaysAgo = DateTime.now().subtract(const Duration(days: 6));
      final result = computeNextBillingDate(sixDaysAgo, BillingCycle.weekly);
      expect(result, sixDaysAgo.add(const Duration(days: 7)));
      expect(result.isAfter(DateTime.now()), isTrue);
    });

    test('monthly: result is in the future and previous month was in the past', () {
      final longAgo = DateTime(2020, 1, 1);
      final result = computeNextBillingDate(longAgo, BillingCycle.monthly);
      expect(result.isAfter(DateTime.now()) || result.isAtSameMomentAs(DateTime.now()), isTrue);
      final prevMonth = DateTime(result.year, result.month - 1, result.day);
      expect(prevMonth.isBefore(DateTime.now()), isTrue);
    });

    test('yearly: result is in the future and previous year was in the past', () {
      final longAgo = DateTime(2015, 3, 15);
      final result = computeNextBillingDate(longAgo, BillingCycle.yearly);
      expect(result.isAfter(DateTime.now()) || result.isAtSameMomentAs(DateTime.now()), isTrue);
      final prevYear = DateTime(result.year - 1, result.month, result.day);
      expect(prevYear.isBefore(DateTime.now()), isTrue);
    });
  });
}

Subscription _sub({
  String id = 'sub-1',
  double amount = 500,
  BillingCycle cycle = BillingCycle.monthly,
  SubscriptionCategory category = SubscriptionCategory.personal,
  bool isActive = true,
  DateTime? nextBillingDate,
  DateTime? startDate,
}) {
  final anchor = DateTime(2025, 6, 1);
  return Subscription(
    id: id,
    name: 'TEST SERVICE',
    category: category,
    amount: amount,
    cycle: cycle,
    startDate: startDate ?? anchor,
    nextBillingDate: nextBillingDate ?? anchor.add(const Duration(days: 30)),
    isActive: isActive,
    createdAt: anchor,
    updatedAt: anchor,
  );
}
