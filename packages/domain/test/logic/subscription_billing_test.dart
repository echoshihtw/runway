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
  _monthEnd();
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
        _sub(
          amount: 12000,
          cycle: BillingCycle.yearly,
          startDate: DateTime(2025, 9, 10),
        ),
      ];

      expect(
        subscriptionsChargedInMonth(subscriptions: yearly, month: september),
        12000,
        reason: 'September is the anniversary month',
      );
      expect(
        subscriptionsChargedInMonth(
          subscriptions: yearly,
          month: DateTime(2026, 10, 5),
        ),
        0,
        reason: 'the other eleven months are free of it',
      );
    });

    test('a quarterly plan bills only in the months it falls', () {
      final quarterly = [
        _sub(
          amount: 3000,
          cycle: BillingCycle.quarterly,
          startDate: DateTime(2026, 3, 10),
        ),
      ];

      expect(
        subscriptionsChargedInMonth(
          subscriptions: quarterly,
          month: DateTime(2026, 9, 1),
        ),
        3000,
      );
      expect(
        subscriptionsChargedInMonth(
          subscriptions: quarterly,
          month: DateTime(2026, 8, 1),
        ),
        0,
      );
    });

    test('a weekly plan bills on each of its dates inside the month', () {
      // From 1 September: the 1st, 8th, 15th, 22nd and 29th.
      expect(
        subscriptionsChargedInMonth(
          subscriptions: [
            _sub(
              amount: 100,
              cycle: BillingCycle.weekly,
              startDate: DateTime(2026, 9, 1),
            ),
          ],
          month: september,
        ),
        500,
      );
      // From 31 August the first September date is the 7th, so four.
      expect(
        subscriptionsChargedInMonth(
          subscriptions: [
            _sub(
              amount: 100,
              cycle: BillingCycle.weekly,
              startDate: DateTime(2026, 8, 31),
            ),
          ],
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
          subscriptions: [
            _sub(startDate: DateTime(2026, 1, 3), isActive: false),
          ],
          month: september,
        ),
        0,
      );
    });
  });

  group('subscriptionsUnpaidThisMonth', () {
    test(
      'a bill nobody has answered for is owed, even once its date passed',
      () {
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
      },
    );

    test(
      'a confirmed bill is out of cash already, so it is not owed twice',
      () {
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
      },
    );

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
          DateTime(1986, 9, 3),
          BillingCycle.weekly,
          september,
        ).isAfter(september),
        isTrue,
      );
    });
  });

  group('weekly across a daylight saving change', () {
    // Duration is absolute time; a billing date is a calendar day. Under
    // TZ=Europe/Paris the old `start.add(Duration(days: 7))` returned
    // 31 October 23:00 for a plan starting midnight on the 25th, which is the
    // wrong day and so the wrong charge id. This holds whatever zone the suite
    // runs in: the assertion is on the shape of the answer, not on one zone.
    test('every period keeps the time of day it started at', () {
      final start = DateTime(2026, 10, 25);
      for (var period = 0; period <= 12; period++) {
        final date = billingDateAt(start, BillingCycle.weekly, period);
        expect(
          [date.hour, date.minute, date.second],
          [start.hour, start.minute, start.second],
          reason: 'period $period slipped off midnight, so its id changed',
        );
      }
    });

    test('every period is a whole number of weeks after the start', () {
      final start = DateTime(2026, 10, 25);
      for (var period = 0; period <= 12; period++) {
        final date = billingDateAt(start, BillingCycle.weekly, period);
        final calendarDays = DateTime(
          date.year,
          date.month,
          date.day,
        ).difference(DateTime(start.year, start.month, start.day)).inDays;
        expect(
          calendarDays,
          7 * period,
          reason: 'period $period is $calendarDays days out, not ${7 * period}',
        );
      }
    });
  });

  group('nextBillingDateAfter', () {
    // now is a parameter, so these say what day it is instead of asking. They
    // used to read DateTime.now() four times in one test and compare results
    // against it, which meant the assertions moved with the day they ran and
    // nothing here could ever exercise a month end.
    final now = DateTime(2026, 9, 23, 14, 30);

    test('a date still ahead is returned unchanged', () {
      final future = DateTime(2026, 10, 3);
      expect(nextBillingDateAfter(future, BillingCycle.monthly, now), future);
    });

    test('weekly: six days ago advances by one week', () {
      final sixDaysAgo = DateTime(2026, 9, 17, 14, 30);
      expect(
        nextBillingDateAfter(sixDaysAgo, BillingCycle.weekly, now),
        DateTime(2026, 9, 24, 14, 30),
      );
    });

    test('monthly: lands on the first date not yet past', () {
      expect(
        nextBillingDateAfter(DateTime(2020, 1, 15), BillingCycle.monthly, now),
        DateTime(2026, 10, 15),
      );
    });

    test('yearly: lands on the next anniversary', () {
      expect(
        nextBillingDateAfter(DateTime(2015, 3, 15), BillingCycle.yearly, now),
        DateTime(2027, 3, 15),
      );
    });

    test('a month end clamps to the month it lands in', () {
      // From 31 January: 31 Jan, 28 Feb, 31 Mar, 30 Apr, 31 May, 30 Jun,
      // 31 Jul, 31 Aug, 30 Sep. September has thirty days, so the 31st clamps
      // to the 30th, and that is the first date not yet past on the 23rd.
      //
      // The old walk stepped date by date, so 31 January became 3 March and
      // every answer after it was wrong by the same three days.
      expect(
        nextBillingDateAfter(DateTime(2026, 1, 31), BillingCycle.monthly, now),
        DateTime(2026, 9, 30),
      );
    });

    test('and October gives the 31st back', () {
      expect(
        nextBillingDateAfter(
          DateTime(2026, 1, 31),
          BillingCycle.monthly,
          DateTime(2026, 10, 1),
        ),
        DateTime(2026, 10, 31),
        reason: 'a clamp in a short month must not be permanent',
      );
    });
    test(
      'is the first date still ahead, so a countdown cannot stick at zero',
      () {
        expect(
          nextBillingDateAfter(
            DateTime(2026, 6, 3),
            BillingCycle.monthly,
            september,
          ),
          DateTime(2026, 10, 3),
        );
      },
    );

    test('leaves a date that is already ahead alone', () {
      expect(
        nextBillingDateAfter(
          DateTime(2026, 9, 25),
          BillingCycle.monthly,
          september,
        ),
        DateTime(2026, 9, 25),
      );
    });
  });

  _countdownTests();
}

void _countdownTests() {
  final now = DateTime(2026, 9, 17, 10);

  group('daysUntilNextBilling', () {
    test('a stored date long past still counts forward', () {
      // The whole of #85: nothing advances nextBillingDate, so reading it left
      // the countdown clamped at 0 for ever once its date went by.
      final stale = Subscription(
        id: 'sub-1',
        name: 'Music',
        category: SubscriptionCategory.personal,
        amount: 980,
        cycle: BillingCycle.monthly,
        startDate: DateTime(2026, 1, 3),
        nextBillingDate: DateTime(2026, 1, 3),
        createdAt: DateTime(2026, 1, 3),
        updatedAt: DateTime(2026, 1, 3),
      );

      // The next 3rd after 17 September is 3 October: 16 days.
      expect(daysUntilNextBilling(stale, now), 16);
    });

    test('counts calendar days, not a floored part-day', () {
      final sub = Subscription(
        id: 'sub-1',
        name: 'Music',
        category: SubscriptionCategory.personal,
        amount: 980,
        cycle: BillingCycle.monthly,
        startDate: DateTime(2026, 1, 25),
        nextBillingDate: DateTime(2026, 1, 25),
        createdAt: DateTime(2026, 1, 25),
        updatedAt: DateTime(2026, 1, 25),
      );

      // 17th at 10:00 to the 25th is 8 days, not 7.
      expect(daysUntilNextBilling(sub, now), 8);
    });
  });
}

/// A billing day at the end of a month used to be lost for good.
///
/// The walk stepped from each date to the next with DateTime(y, m + 1, d), and
/// DateTime(2026, 2, 31) is 3 March. So a plan starting 31 January billed
/// 31 Jan, 3 Mar, 3 Apr, and the 3rd for ever: February charged nothing while
/// the flat monthly run rate kept charging, the day never came back, and the
/// charge id is built from the date, so a charge already confirmed under the
/// old date stopped matching.
///
/// Dates are counted from the start date now, so a short month clamps and the
/// next long one restores the original day.
void _monthEnd() {
  Subscription plan(int day, BillingCycle cycle) => Subscription(
    id: 'sub-1',
    name: 'Music',
    category: SubscriptionCategory.personal,
    amount: 10,
    cycle: cycle,
    startDate: DateTime(2026, 1, day),
    nextBillingDate: DateTime(2026, 1, day),
    createdAt: DateTime(2026, 1, day),
    updatedAt: DateTime(2026, 1, day),
  );

  group('a billing day past the end of a short month', () {
    test('clamps to that month and returns to its own day after', () {
      final dates = billingDatesUpTo(
        plan(31, BillingCycle.monthly),
        DateTime(2026, 5, 31),
      );
      expect(dates.map((d) => '${d.month}-${d.day}').toList(), [
        '1-31',
        '2-28',
        '3-31',
        '4-30',
        '5-31',
      ]);
    });

    test('never skips a month, for any day or cycle', () {
      // The old walk skipped February outright. Nothing may be missing.
      for (final day in [28, 29, 30, 31]) {
        final dates = billingDatesUpTo(
          plan(day, BillingCycle.monthly),
          DateTime(2027, 1, 1),
        );
        expect(
          dates.map((d) => d.month).toList(),
          [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
          reason: 'a plan billing on the ${day}th missed a month',
        );
      }
    });

    test('the day never drifts away from the start date', () {
      // The property the old code broke. Every date is either the start day or
      // the last day of a month too short to hold it.
      for (final day in [29, 30, 31]) {
        for (final cycle in [
          BillingCycle.monthly,
          BillingCycle.quarterly,
          BillingCycle.yearly,
        ]) {
          for (final d in billingDatesUpTo(
            plan(day, cycle),
            DateTime(2030, 1, 1),
          )) {
            final lastOfMonth = DateTime(d.year, d.month + 1, 0).day;
            expect(
              d.day,
              day <= lastOfMonth ? day : lastOfMonth,
              reason:
                  '$cycle on the ${day}th drifted to ${d.year}-${d.month}-${d.day}',
            );
          }
        }
      }
    });

    test('a leap year gives February the 29th back', () {
      final dates = billingDatesUpTo(
        plan(29, BillingCycle.yearly),
        DateTime(2029, 1, 1),
      );
      expect(dates.map((d) => '${d.year}-${d.month}-${d.day}').toList(), [
        '2026-1-29',
        '2027-1-29',
        '2028-1-29',
      ]);
      final feb = billingDatesUpTo(
        Subscription(
          id: 's',
          name: 'n',
          category: SubscriptionCategory.personal,
          amount: 1,
          cycle: BillingCycle.yearly,
          startDate: DateTime(2028, 2, 29),
          nextBillingDate: DateTime(2028, 2, 29),
          createdAt: DateTime(2028, 2, 29),
          updatedAt: DateTime(2028, 2, 29),
        ),
        DateTime(2033, 1, 1),
      );
      expect(feb.map((d) => '${d.year}-${d.month}-${d.day}').toList(), [
        '2028-2-29',
        '2029-2-28',
        '2030-2-28',
        '2031-2-28',
        '2032-2-29',
      ]);
    });
  });
}
