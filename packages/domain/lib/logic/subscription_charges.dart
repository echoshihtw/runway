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
/// `updatedAt` is deliberately not a bound: it moves on any edit, so renaming a
/// plan would drop its unanswered charges. Confirming each charge is the
/// safeguard instead.
///
/// Every date here is compared by day. A billing date is a day, while
/// `createdAt` and `startDate` also carry a time.
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
