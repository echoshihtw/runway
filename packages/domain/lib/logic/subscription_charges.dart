import '../entities/subscription.dart';
import '../entities/transaction.dart';
import '../enums/transaction_type.dart';
import '../value_objects/money.dart';
import 'opening_balance.dart';
import 'subscription_billing.dart';

/// A subscription is a reminder. On its payment date it leaves an entry for the
/// amount the reminder states, and that entry is the record of the charge.
///
/// Writing it on the day is what makes history immutable: the September entry
/// holds what the plan cost in September, so upgrading later changes the next
/// entry and never an earlier one. No price history has to be stored, because
/// each entry carries its own amount.

/// Midnight on the day of [d], so a timestamp can be compared with a date.
DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

/// The earliest payment date an entry may be written for.
///
/// - An opening balance is a stated truth at its date, so charges before it are
///   already inside it and writing them would take the money twice.
/// - Before the app knew the subscription, nothing is known: a plan started in
///   2019 must not suddenly produce six years of rows.
///
/// The last edit is deliberately **not** a bound. It was, while charges were
/// written without asking: an amount changed mid-month made the earlier
/// period unknowable, so writing it would have baked a wrong figure into the
/// ledger. Now that every charge is confirmed first, the question itself is
/// the safeguard — the owner reads the amount and says no if it is wrong. As a
/// bound it was actively harmful, because `updatedAt` moves on *any* edit, so
/// correcting a name silently dropped every unanswered charge for good.
///
/// Every bound is compared by day, because a billing date is a day and the
/// dates it is compared against are timestamps. Someone adding a subscription
/// at half past two whose bill falls today was read as "midnight is before half
/// past two" and the charge was dropped, so the question never came. Whether it
/// came at all depended on something invisible: the form leaves the start date
/// at DateTime.now(), which carries the time and slipped past, while opening
/// the date picker and choosing the same day returns midnight, which did not.
DateTime _earliestWritableDate(Subscription s, DateTime? openingBalanceDate) {
  final startDate = _startOfDay(s.startDate);
  final createdAt = _startOfDay(s.createdAt);
  var earliest = startDate.isAfter(createdAt) ? startDate : createdAt;
  if (openingBalanceDate != null) {
    final opening = _startOfDay(openingBalanceDate);
    if (opening.isAfter(earliest)) earliest = opening;
  }
  return earliest;
}

/// Entries for payment dates that have arrived and are not recorded yet,
/// oldest first.
List<Transaction> dueSubscriptionCharges({
  required List<Subscription> subscriptions,
  required List<Transaction> transactions,
  required DateTime now,
}) {
  final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

  final openingBalanceDate = latestOpeningBalanceDate(transactions);

  final recorded = transactions.map((t) => t.id).toSet();

  final charges = <Transaction>[];
  for (final s in subscriptions.where((s) => s.isActive)) {
    final earliest = _earliestWritableDate(s, openingBalanceDate);
    // From period 0, so the index is the period a legacy id matches on.
    final dates = billingDatesUpTo(s, endOfToday);
    final legacy = legacyBillingDates(s, endOfToday);
    for (var period = 0; period < dates.length; period++) {
      final date = dates[period];
      if (date.isBefore(earliest)) continue;
      if (chargeAlreadyRecorded(
        s: s,
        period: period,
        date: date,
        legacy: legacy,
        recorded: recorded,
      )) {
        continue;
      }
      final id = subscriptionChargeId(s.id, date);
      if (!recorded.add(id)) continue;
      charges.add(
        Transaction(
          id: id,
          type: TransactionType.subscriptionCharge,
          amount: Money(s.amount),
          date: date,
          note: s.name,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }
  charges.sort((a, b) => a.date.compareTo(b.date));
  return charges;
}
