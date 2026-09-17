import '../entities/subscription.dart';
import '../entities/transaction.dart';
import '../enums/transaction_type.dart';
import '../value_objects/money.dart';
import 'subscription_billing.dart';

/// A subscription is a reminder. On its payment date it leaves an entry for the
/// amount the reminder states, and that entry is the record of the charge.
///
/// Writing it on the day is what makes history immutable: the September entry
/// holds what the plan cost in September, so upgrading later changes the next
/// entry and never an earlier one. No price history has to be stored, because
/// each entry carries its own amount.

/// A charge's id is derived from its subscription and payment date, so a second
/// copy collides with the primary key. Opening the app twice cannot double
/// charge even if two passes race.
String subscriptionChargeId(String subscriptionId, DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return 'subchg-$subscriptionId-${date.year}$month$day';
}

/// The earliest payment date an entry may be written for.
///
/// - An opening balance is a stated truth at its date, so charges before it are
///   already inside it and writing them would take the money twice.
/// - Before the app knew the subscription, nothing is known: a plan started in
///   2019 must not suddenly produce six years of rows.
/// - Before the last edit, the amount is no longer knowable. 390 ended when it
///   became 490, and writing 490 for a period that cost 390 would bake a wrong
///   history into the ledger permanently, which is worse than not writing it.
DateTime _earliestWritableDate(Subscription s, DateTime? openingBalanceDate) {
  var earliest = s.startDate.isAfter(s.createdAt) ? s.startDate : s.createdAt;
  if (s.updatedAt.isAfter(earliest)) earliest = s.updatedAt;
  if (openingBalanceDate != null && openingBalanceDate.isAfter(earliest)) {
    earliest = openingBalanceDate;
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

  final openingBalanceDate = transactions
      .where((t) => t.type == TransactionType.openingBalance)
      .fold<DateTime?>(
        null,
        (latest, t) => latest == null || t.date.isAfter(latest) ? t.date : latest,
      );

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
