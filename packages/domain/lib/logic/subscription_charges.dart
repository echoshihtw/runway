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
/// Compared by day, because a billing date is a day and not an instant.
///
/// createdAt is a timestamp. A billing date is midnight. Someone adding a
/// subscription at half past two whose bill falls today was therefore compared
/// as "midnight is before half past two" and the charge was dropped, so the
/// question never came. Whether it came at all depended on something invisible:
/// leaving the date field alone kept DateTime.now(), which carried the time and
/// slipped past, while opening the picker and choosing the same day returned
/// midnight and did not.
DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

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
    for (final date in billingDatesInRange(s, from: earliest, to: endOfToday)) {
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
