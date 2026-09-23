import 'package:domain/domain.dart';
import 'package:test/test.dart';

/// A subscription was a commitment record only: nothing turned its charge into
/// a transaction, so cash never fell for it while burn already counted it.
///
/// The entry is written on the billing day at the price stated then, which is
/// what makes history immutable: the 3 September row holds 390 for ever, and an
/// upgrade on the 10th only shows up in the next one.
Subscription _sub({
  String id = 'sub-1',
  String name = 'Spotify',
  double amount = 980,
  BillingCycle cycle = BillingCycle.monthly,
  required DateTime startDate,
  DateTime? createdAt,
  DateTime? updatedAt,
  bool isActive = true,
}) => Subscription(
  id: id,
  name: name,
  category: SubscriptionCategory.personal,
  amount: amount,
  cycle: cycle,
  startDate: startDate,
  nextBillingDate: startDate,
  isActive: isActive,
  createdAt: createdAt ?? startDate,
  updatedAt: updatedAt ?? createdAt ?? startDate,
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
  group('a charge confirmed before the drift fix', () {
    // The old schedule stepped date to date, so a plan starting on the 31st
    // billed the 3rd for ever after. Those charges are on devices now, under
    // ids the corrected schedule no longer produces.
    List<DateTime> oldWalk(DateTime start, DateTime to, int monthStep) {
      final dates = <DateTime>[];
      var d = start;
      while (!d.isAfter(to)) {
        dates.add(d);
        d = DateTime(d.year, d.month + monthStep, d.day);
      }
      return dates;
    }

    test('is not asked about again, so it cannot be paid twice', () {
      final now = DateTime(2026, 9, 23);
      final s = _sub(
        cycle: BillingCycle.quarterly,
        startDate: DateTime(2025, 1, 31),
      );
      final confirmed = [
        for (final date in oldWalk(s.startDate, now, 3))
          Transaction(
            id: subscriptionChargeId(s.id, date),
            type: TransactionType.subscriptionCharge,
            amount: Money(s.amount),
            date: date,
            createdAt: now,
            updatedAt: now,
          ),
      ];

      expect(
        dueSubscriptionCharges(
          subscriptions: [s],
          transactions: confirmed,
          now: now,
        ),
        isEmpty,
        reason: 'every one of these was already answered and paid',
      );
      expect(
        subscriptionsUnpaidThisMonth(
          subscriptions: [s],
          transactions: confirmed,
          now: now,
        ),
        0,
      );
    });

    test('a genuinely unpaid bill is still asked about', () {
      final now = DateTime(2026, 9, 23);
      final s = _sub(
        cycle: BillingCycle.monthly,
        startDate: DateTime(2026, 7, 31),
      );
      expect(
        dueSubscriptionCharges(
          subscriptions: [s],
          transactions: const [],
          now: now,
        ),
        isNotEmpty,
        reason: 'recognising old ids must not suppress real questions',
      );
    });
  });

  final now = DateTime(2026, 9, 17, 10);
  final opening = _tx(
    'open',
    TransactionType.openingBalance,
    100000,
    DateTime(2026, 9, 1),
  );

  group('dueSubscriptionCharges', () {
    test('writes one entry per billing day that has passed', () {
      final charges = dueSubscriptionCharges(
        subscriptions: [_sub(startDate: DateTime(2026, 9, 3))],
        transactions: [opening],
        now: now,
      );

      expect(charges, hasLength(1));
      final charge = charges.single;
      expect(charge.date, DateTime(2026, 9, 3));
      expect(charge.amount.value, 980);
      expect(charge.type, TransactionType.subscriptionCharge);
      expect(charge.note, 'Spotify');
      // Derived from the subscription and the date, so the database itself
      // rejects a second copy.
      expect(charge.id, 'subchg-sub-1-20260903');
    });

    test('added today, billing today, asks today whatever the clock said', () {
      // createdAt is a timestamp; a billing date is midnight. Comparing the two
      // as instants meant a subscription added at half past two whose bill falls
      // today was dropped, because midnight is before half past two.
      //
      // Whether it happened at all depended on something invisible. The form
      // defaults the start date to DateTime.now(), which carries the time and
      // slipped past the comparison, but opening the date picker and choosing
      // the same day returns midnight and did not. Same day, opposite outcome.
      final createdAt = DateTime(2026, 9, 23, 14, 30);
      final now = DateTime(2026, 9, 23, 14, 31);

      for (final (label, startDate) in [
        ('left on the default, carrying the time', createdAt),
        ('picked from the date picker, at midnight', DateTime(2026, 9, 23)),
      ]) {
        final due = dueSubscriptionCharges(
          subscriptions: [_sub(startDate: startDate, createdAt: createdAt)],
          transactions: const [],
          now: now,
        );
        expect(due, hasLength(1), reason: label);
        // Asserted by day. The charge keeps whatever time the start date had,
        // because the charge id is derived from that date and normalising it
        // would stop already-recorded charges matching, so they would all be
        // asked again. That is a migration, not a fix for this.
        final date = due.single.date;
        expect(
          DateTime(date.year, date.month, date.day),
          DateTime(2026, 9, 23),
          reason: label,
        );
      }
    });

    test('a billing day still ahead is not written yet', () {
      expect(
        dueSubscriptionCharges(
          subscriptions: [_sub(startDate: DateTime(2026, 9, 28))],
          transactions: [opening],
          now: now,
        ),
        isEmpty,
      );
    });

    test('opening the app twice cannot double-charge', () {
      final sub = _sub(startDate: DateTime(2026, 9, 3));
      final first = dueSubscriptionCharges(
        subscriptions: [sub],
        transactions: [opening],
        now: now,
      );
      expect(first, hasLength(1));

      expect(
        dueSubscriptionCharges(
          subscriptions: [sub],
          transactions: [opening, ...first],
          now: now,
        ),
        isEmpty,
      );
    });

    test('catches up several periods in one pass', () {
      final charges = dueSubscriptionCharges(
        subscriptions: [
          _sub(
            startDate: DateTime(2026, 6, 3),
            createdAt: DateTime(2026, 6, 3),
          ),
        ],
        transactions: [
          _tx(
            'open',
            TransactionType.openingBalance,
            100000,
            DateTime(2026, 6, 1),
          ),
        ],
        now: now,
      );

      expect(charges.map((c) => c.date), [
        DateTime(2026, 6, 3),
        DateTime(2026, 7, 3),
        DateTime(2026, 8, 3),
        DateTime(2026, 9, 3),
      ]);
    });

    test('never writes a period from before the opening balance', () {
      // The balance is a stated truth at its date, so charges before it are
      // already inside it and writing them would take the money twice.
      final charges = dueSubscriptionCharges(
        subscriptions: [
          _sub(
            startDate: DateTime(2020, 1, 3),
            createdAt: DateTime(2020, 1, 3),
          ),
        ],
        transactions: [opening],
        now: now,
      );

      expect(charges.map((c) => c.date), [DateTime(2026, 9, 3)]);
    });

    test('never writes a period from before the app knew the subscription', () {
      final charges = dueSubscriptionCharges(
        subscriptions: [
          _sub(
            startDate: DateTime(2019, 5, 3),
            createdAt: DateTime(2026, 9, 1),
          ),
        ],
        transactions: const [],
        now: now,
      );

      expect(charges.map((c) => c.date), [DateTime(2026, 9, 3)]);
    });

    test('an edit does not drop the charges already waiting to be asked', () {
      // updatedAt moves on any edit, including a rename. Using it as a bound
      // silently destroyed every unanswered charge; the question itself is the
      // safeguard now, because the owner reads the amount before confirming.
      final charges = dueSubscriptionCharges(
        subscriptions: [
          _sub(
            amount: 490,
            startDate: DateTime(2026, 7, 3),
            createdAt: DateTime(2026, 7, 3),
            updatedAt: DateTime(2026, 9, 17, 9),
          ),
        ],
        transactions: [
          _tx(
            'open',
            TransactionType.openingBalance,
            100000,
            DateTime(2026, 7, 1),
          ),
        ],
        now: now,
      );

      expect(charges.map((c) => c.date), [
        DateTime(2026, 7, 3),
        DateTime(2026, 8, 3),
        DateTime(2026, 9, 3),
      ]);
    });

    test('an edit from before the period still writes it', () {
      final charges = dueSubscriptionCharges(
        subscriptions: [
          _sub(
            startDate: DateTime(2026, 9, 3),
            createdAt: DateTime(2026, 8, 1),
            updatedAt: DateTime(2026, 8, 20),
          ),
        ],
        transactions: [opening],
        now: now,
      );

      expect(charges.map((c) => c.date), [DateTime(2026, 9, 3)]);
    });

    test('an inactive subscription writes nothing', () {
      expect(
        dueSubscriptionCharges(
          subscriptions: [
            _sub(startDate: DateTime(2026, 9, 3), isActive: false),
          ],
          transactions: [opening],
          now: now,
        ),
        isEmpty,
      );
    });

    test('yearly and quarterly bills land on their own dates', () {
      final charges = dueSubscriptionCharges(
        subscriptions: [
          _sub(
            id: 'yearly',
            amount: 12000,
            cycle: BillingCycle.yearly,
            startDate: DateTime(2026, 9, 10),
            createdAt: DateTime(2026, 9, 1),
          ),
          _sub(
            id: 'quarterly',
            amount: 3000,
            cycle: BillingCycle.quarterly,
            startDate: DateTime(2026, 9, 5),
            createdAt: DateTime(2026, 9, 1),
          ),
        ],
        transactions: [opening],
        now: now,
      );

      expect(charges.map((c) => c.id), [
        'subchg-quarterly-20260905',
        'subchg-yearly-20260910',
      ]);
    });

    test('a charge is an outflow, and not an expense against a budget', () {
      final charge = dueSubscriptionCharges(
        subscriptions: [_sub(startDate: DateTime(2026, 9, 3))],
        transactions: [opening],
        now: now,
      ).single;

      expect(charge.type.isInflow, isFalse);
      expect(
        countsAsLiving(charge),
        isFalse,
        reason: 'burn counts subscriptions separately',
      );
      expect(countsAsRent(charge), isFalse);
    });
  });
}
