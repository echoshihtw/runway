import '../entities/subscription.dart';
import '../entities/transaction.dart';
import '../enums/transaction_type.dart';
import 'monthly_aggregator.dart';
import 'subscription_billing.dart';

/// Burn counts subscriptions; the cash balance never did. So the figure the
/// runway is divided into floated above the bank by the subscription total
/// every month, and the error compounded.
///
/// This corrects it on the read side. Nothing is written: a derived charge
/// says "the rule says this billed", which is not the same claim as "this was
/// paid", and only a real entry may assert the second.
///
/// The window is the current month, and that bound is deliberate. Nothing
/// stores what a subscription used to cost, so pricing an earlier month from
/// today's amount would restate history: raise Netflix from 390 to 420 and
/// every past month would silently claim 420. A month that is never accrued
/// cannot be repriced. Drift from earlier months is the balance check's job,
/// where an external statement settles it instead of a guess.

/// Charges are never accrued from before this date.
///
/// An opening balance is a stated truth at its date, so charges before it are
/// already inside it and subtracting them would take the money twice. The day
/// the app was told about the subscription bounds it too: a plan started in
/// 2019 must not suddenly remove six years of charges from cash.
DateTime _accrualAnchor(Subscription s, DateTime? openingBalanceDate) {
  var anchor = s.startDate.isAfter(s.createdAt) ? s.startDate : s.createdAt;
  if (openingBalanceDate != null && openingBalanceDate.isAfter(anchor)) {
    anchor = openingBalanceDate;
  }
  return anchor;
}

/// One key per billing month and amount. A logged payment is spent against at
/// most one derived charge, so two subscriptions at the same price need two
/// logged payments before both stop accruing.
String _monthAndAmount(DateTime date, double amount) =>
    '${date.year}-${date.month}@${amount.toStringAsFixed(2)}';

/// What active subscriptions have taken from the account this month but the
/// ledger does not show, up to and including today.
///
/// A payment the user logged by hand for the same amount in the same billing
/// month wins: "log everything except subscriptions" is not a rule anyone can
/// keep, so a matching entry is treated as that charge.
double accruedSubscriptionCharges({
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

  final loggedPayments = <String, int>{};
  for (final t in transactions) {
    if (t.type != TransactionType.expense) continue;
    if (t.date.isAfter(endOfToday)) continue;
    loggedPayments.update(
      _monthAndAmount(t.date, t.amount.value),
      (count) => count + 1,
      ifAbsent: () => 1,
    );
  }

  final startOfMonth = DateTime(now.year, now.month);

  var accrued = 0.0;
  for (final s in subscriptions.where((s) => s.isActive)) {
    final anchor = _accrualAnchor(s, openingBalanceDate);
    final from = anchor.isAfter(startOfMonth) ? anchor : startOfMonth;
    for (final date in billingDatesInRange(s, from: from, to: endOfToday)) {
      final key = _monthAndAmount(date, s.amount);
      final matches = loggedPayments[key] ?? 0;
      if (matches > 0) {
        loggedPayments[key] = matches - 1;
        continue;
      }
      accrued += s.amount;
    }
  }
  return accrued;
}

/// Cash on hand at [now]: the ledger balance, less what subscriptions have
/// taken without leaving an entry.
double cashAsOf({
  required List<Transaction> transactions,
  required List<Subscription> subscriptions,
  required DateTime now,
}) =>
    currentCashAsOf(transactions: transactions, now: now) -
    accruedSubscriptionCharges(
      subscriptions: subscriptions,
      transactions: transactions,
      now: now,
    );
