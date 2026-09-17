import 'package:domain/domain.dart';
import 'package:test/test.dart';

Subscription _sub({
  String id = 'sub-1',
  double amount = 980,
  BillingCycle cycle = BillingCycle.monthly,
  required DateTime startDate,
  bool isActive = true,
}) => Subscription(
  id: id,
  name: 'Music',
  category: SubscriptionCategory.personal,
  amount: amount,
  cycle: cycle,
  startDate: startDate,
  nextBillingDate: startDate,
  isActive: isActive,
  createdAt: startDate,
  updatedAt: startDate,
);

void main() {
  final september = DateTime(2026, 9, 17, 10);

  group('subscriptionsChargedInMonth', () {
    test('a monthly plan bills once in the month', () {
      expect(
        subscriptionsChargedInMonth(
          subscriptions: [_sub(startDate: DateTime(2026, 1, 3))],
          month: september,
        ),
        980,
      );
    });

    test('a yearly plan bills in its anniversary month and nowhere else', () {
      final yearly = [
        _sub(amount: 12000, cycle: BillingCycle.yearly, startDate: DateTime(2025, 9, 10)),
      ];

      expect(
        subscriptionsChargedInMonth(subscriptions: yearly, month: september),
        12000,
        reason: 'September is the anniversary month',
      );
      expect(
        subscriptionsChargedInMonth(subscriptions: yearly, month: DateTime(2026, 10, 5)),
        0,
        reason: 'the other eleven months are free of it',
      );
    });

    test('a quarterly plan bills only in the months it falls', () {
      final quarterly = [
        _sub(amount: 3000, cycle: BillingCycle.quarterly, startDate: DateTime(2026, 3, 10)),
      ];

      expect(subscriptionsChargedInMonth(subscriptions: quarterly, month: DateTime(2026, 9, 1)), 3000);
      expect(subscriptionsChargedInMonth(subscriptions: quarterly, month: DateTime(2026, 8, 1)), 0);
    });

    test('a weekly plan bills on each of its dates inside the month', () {
      // From 1 September: the 1st, 8th, 15th, 22nd and 29th.
      expect(
        subscriptionsChargedInMonth(
          subscriptions: [_sub(amount: 100, cycle: BillingCycle.weekly, startDate: DateTime(2026, 9, 1))],
          month: september,
        ),
        500,
      );
      // From 31 August the first September date is the 7th, so four.
      expect(
        subscriptionsChargedInMonth(
          subscriptions: [_sub(amount: 100, cycle: BillingCycle.weekly, startDate: DateTime(2026, 8, 31))],
          month: september,
        ),
        400,
      );
    });

    test('a plan that had not started yet bills nothing', () {
      expect(
        subscriptionsChargedInMonth(
          subscriptions: [_sub(startDate: DateTime(2026, 11, 3))],
          month: september,
        ),
        0,
      );
    });

    test('an inactive plan bills nothing', () {
      expect(
        subscriptionsChargedInMonth(
          subscriptions: [_sub(startDate: DateTime(2026, 1, 3), isActive: false)],
          month: september,
        ),
        0,
      );
    });
  });

  group('subscriptionsUnpaidThisMonth', () {
    test('a bill nobody has answered for is owed, even once its date passed', () {
      // Counting only the bills still ahead left it in neither cash nor the
      // month's cost, so the runway read long.
      expect(
        subscriptionsUnpaidThisMonth(
          subscriptions: [_sub(startDate: DateTime(2026, 1, 3))],
          transactions: const [],
          now: september,
        ),
        980,
      );
    });

    test('a confirmed bill is out of cash already, so it is not owed twice', () {
      final confirmed = Transaction(
        id: subscriptionChargeId('sub-1', DateTime(2026, 9, 3)),
        type: TransactionType.subscriptionCharge,
        amount: Money(980),
        date: DateTime(2026, 9, 3),
        createdAt: september,
        updatedAt: september,
      );

      expect(
        subscriptionsUnpaidThisMonth(
          subscriptions: [_sub(startDate: DateTime(2026, 1, 3))],
          transactions: [confirmed],
          now: september,
        ),
        0,
      );
    });

    test('a bill still ahead is owed in full, not pro-rated', () {
      expect(
        subscriptionsUnpaidThisMonth(
          subscriptions: [_sub(startDate: DateTime(2026, 1, 28))],
          transactions: const [],
          now: september,
        ),
        980,
      );
    });

    test('a mistyped start date decades back still bills today', () {
      // The walk used to stop after a fixed number of periods, so a weekly
      // plan starting 40 years ago ran out before reaching this month and
      // then never billed at all.
      expect(
        subscriptionsUnpaidThisMonth(
          subscriptions: [
            _sub(cycle: BillingCycle.weekly, startDate: DateTime(1986, 9, 3)),
          ],
          transactions: const [],
          now: september,
        ),
        greaterThan(0),
      );
      expect(
        nextBillingDateAfter(
          _sub(cycle: BillingCycle.weekly, startDate: DateTime(1986, 9, 3)),
          september,
        ).isAfter(september),
        isTrue,
      );
    });
  });

  group('nextBillingDateAfter', () {
    test('is the first date still ahead, so a countdown cannot stick at zero', () {
      expect(
        nextBillingDateAfter(_sub(startDate: DateTime(2026, 6, 3)), september),
        DateTime(2026, 10, 3),
      );
    });

    test('leaves a date that is already ahead alone', () {
      expect(
        nextBillingDateAfter(_sub(startDate: DateTime(2026, 9, 25)), september),
        DateTime(2026, 9, 25),
      );
    });
  });
}
