import 'package:domain/domain.dart';
import 'package:test/test.dart';

/// Burn counts subscriptions; cash never did. So the balance the runway is
/// divided into floated above the bank by the subscription total every month,
/// and the error compounded. Nothing is written to fix it: the charges that
/// have fallen due are subtracted at read time.
Subscription _sub({
  String id = 'sub-1',
  double amount = 980,
  BillingCycle cycle = BillingCycle.monthly,
  required DateTime startDate,
  DateTime? createdAt,
  bool isActive = true,
}) => Subscription(
  id: id,
  name: 'Spotify',
  category: SubscriptionCategory.personal,
  amount: amount,
  cycle: cycle,
  startDate: startDate,
  nextBillingDate: startDate,
  isActive: isActive,
  createdAt: createdAt ?? startDate,
  updatedAt: createdAt ?? startDate,
);

Transaction _tx(
  String id,
  TransactionType type,
  double amount,
  DateTime date,
) => Transaction(
  id: id,
  type: type,
  amount: Money(amount),
  date: date,
  createdAt: date,
  updatedAt: date,
);

void main() {
  final now = DateTime(2026, 9, 17, 10);
  final opening = _tx('open', TransactionType.openingBalance, 100000, DateTime(2026, 9, 1));

  group('accruedSubscriptionCharges', () {
    test('a bill that has fallen due is money already gone', () {
      expect(
        accruedSubscriptionCharges(
          subscriptions: [_sub(startDate: DateTime(2026, 9, 3))],
          transactions: [opening],
          now: now,
        ),
        980,
      );
    });

    test('a bill still ahead has not been taken yet', () {
      expect(
        accruedSubscriptionCharges(
          subscriptions: [_sub(startDate: DateTime(2026, 9, 28))],
          transactions: [opening],
          now: now,
        ),
        0,
      );
    });

    test('bills before the opening balance are already inside it', () {
      // The balance is a stated truth at its date. Subtracting charges from
      // before it would take the same money twice.
      expect(
        accruedSubscriptionCharges(
          subscriptions: [
            _sub(startDate: DateTime(2020, 1, 3), createdAt: DateTime(2020, 1, 3)),
          ],
          transactions: [opening],
          now: now,
        ),
        980,
      );
    });

    test('a payment logged by hand for the same amount is not counted twice', () {
      // "Log everything except subscriptions" is not a rule anyone can keep,
      // so a matching payment in the billing month wins over the derived one.
      expect(
        accruedSubscriptionCharges(
          subscriptions: [_sub(startDate: DateTime(2026, 9, 3))],
          transactions: [opening, _tx('sp', TransactionType.expense, 980, DateTime(2026, 9, 5))],
          now: now,
        ),
        0,
      );
    });

    test('an unrelated expense of a different amount suppresses nothing', () {
      expect(
        accruedSubscriptionCharges(
          subscriptions: [_sub(startDate: DateTime(2026, 9, 3))],
          transactions: [opening, _tx('lunch', TransactionType.expense, 500, DateTime(2026, 9, 5))],
          now: now,
        ),
        980,
      );
    });

    test('two subscriptions at the same price need two logged payments', () {
      expect(
        accruedSubscriptionCharges(
          subscriptions: [
            _sub(id: 'a', startDate: DateTime(2026, 9, 3)),
            _sub(id: 'b', startDate: DateTime(2026, 9, 4)),
          ],
          transactions: [opening, _tx('one', TransactionType.expense, 980, DateTime(2026, 9, 5))],
          now: now,
        ),
        980,
        reason: 'one logged payment covers one of the two charges',
      );
    });

    test('a yearly bill accrues only in its anniversary month', () {
      expect(
        accruedSubscriptionCharges(
          subscriptions: [
            _sub(amount: 12000, cycle: BillingCycle.yearly, startDate: DateTime(2026, 9, 10)),
          ],
          transactions: [opening],
          now: now,
        ),
        12000,
      );
      expect(
        accruedSubscriptionCharges(
          subscriptions: [
            _sub(amount: 12000, cycle: BillingCycle.yearly, startDate: DateTime(2026, 8, 10)),
          ],
          transactions: [opening],
          now: now,
        ),
        0,
        reason: 'August is before the opening balance, so it is already inside it',
      );
    });

    test('a bill from a previous month is not accrued', () {
      // Nothing stores what the amount used to be, so pricing August from
      // today's amount would restate it. Only this month is accrued.
      expect(
        accruedSubscriptionCharges(
          subscriptions: [
            _sub(startDate: DateTime(2026, 8, 3), createdAt: DateTime(2026, 8, 3)),
          ],
          transactions: [
            _tx('open', TransactionType.openingBalance, 100000, DateTime(2026, 8, 1)),
          ],
          now: now,
        ),
        980,
        reason: 'the 3 September bill only, not August as well',
      );
    });

    test('a price change cannot restate an earlier month', () {
      // Three bills have fallen due since July, but only September is accrued,
      // so a raised price applies to one bill instead of rewriting two others.
      expect(
        accruedSubscriptionCharges(
          subscriptions: [
            _sub(amount: 1200, startDate: DateTime(2026, 7, 3), createdAt: DateTime(2026, 7, 3)),
          ],
          transactions: [
            _tx('open', TransactionType.openingBalance, 100000, DateTime(2026, 7, 1)),
          ],
          now: now,
        ),
        1200,
      );
    });

    test('an inactive subscription accrues nothing', () {
      expect(
        accruedSubscriptionCharges(
          subscriptions: [_sub(startDate: DateTime(2026, 9, 3), isActive: false)],
          transactions: [opening],
          now: now,
        ),
        0,
      );
    });
  });

  group('cashAsOf', () {
    test('cash is the ledger balance less what subscriptions have taken', () {
      expect(
        cashAsOf(
          transactions: [opening],
          subscriptions: [_sub(startDate: DateTime(2026, 9, 3))],
          now: now,
        ),
        100000 - 980,
      );
    });

    test('with no subscriptions it is exactly the ledger balance', () {
      expect(
        cashAsOf(transactions: [opening], subscriptions: const [], now: now),
        currentCashAsOf(transactions: [opening], now: now),
      );
    });

    test('a future-dated entry still does not move cash', () {
      final planned = _tx('plan', TransactionType.expense, 5000, DateTime(2026, 9, 28));
      expect(
        cashAsOf(
          transactions: [opening, planned],
          subscriptions: const [],
          now: now,
        ),
        100000,
      );
    });
  });
}
