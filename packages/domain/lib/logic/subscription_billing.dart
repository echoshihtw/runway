import '../entities/subscription.dart';
import '../enums/billing_cycle.dart';

/// When a subscription actually bills, derived from its start date and cycle
/// rather than averaged.
///
/// The flat monthly equivalent is the right *forward* run rate: a 12,000 yearly
/// plan really does cost 1,000 a month when dividing cash into months of cover.
/// It is the wrong answer for a specific month, where the bill either falls or
/// it does not. Both figures are valid and they must never be added together.
///
/// Nothing here writes a transaction. A derived charge says "the rule says this
/// bills today", not "this was paid", and the two must not be confused.

DateTime _advance(DateTime date, BillingCycle cycle) => switch (cycle) {
  BillingCycle.weekly => date.add(const Duration(days: 7)),
  BillingCycle.monthly => DateTime(date.year, date.month + 1, date.day),
  BillingCycle.quarterly => DateTime(date.year, date.month + 3, date.day),
  BillingCycle.yearly => DateTime(date.year + 1, date.month, date.day),
};

/// Guards against a runaway loop if stored data holds an absurd start date.
const _maxPeriods = 2000;

/// Billing dates of [s] from its start date up to and including [to].
List<DateTime> billingDatesUpTo(Subscription s, DateTime to) {
  final dates = <DateTime>[];
  var date = s.startDate;
  var periods = 0;
  while (!date.isAfter(to) && periods++ < _maxPeriods) {
    dates.add(date);
    date = _advance(date, s.cycle);
  }
  return dates;
}

/// Billing dates of [s] that fall within [from]..[to], inclusive.
List<DateTime> billingDatesInRange(
  Subscription s, {
  required DateTime from,
  required DateTime to,
}) => billingDatesUpTo(s, to).where((d) => !d.isBefore(from)).toList();

/// What active subscriptions bill during the month containing [month].
///
/// A yearly plan lands in its anniversary month and contributes nothing to the
/// other eleven, instead of a twelfth appearing every month.
double subscriptionsChargedInMonth({
  required List<Subscription> subscriptions,
  required DateTime month,
}) {
  final first = DateTime(month.year, month.month);
  final last = DateTime(month.year, month.month + 1, 0, 23, 59, 59, 999);
  var total = 0.0;
  for (final s in subscriptions.where((s) => s.isActive)) {
    total += billingDatesInRange(s, from: first, to: last).length * s.amount;
  }
  return total;
}

/// What subscriptions still bill before this month ends.
///
/// Bills already past are money that has left the account, so charging a
/// pro-rated share of the monthly average on top of them counted it twice.
double subscriptionsDueLaterThisMonth({
  required List<Subscription> subscriptions,
  required DateTime now,
}) {
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  final last = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
  var due = 0.0;
  for (final s in subscriptions.where((s) => s.isActive)) {
    due += billingDatesInRange(s, from: tomorrow, to: last).length * s.amount;
  }
  return due;
}

/// The first billing date still ahead of [now].
///
/// The stored `nextBillingDate` is never advanced after creation, so once a
/// date passes it stays in the past and the countdown sticks at 0. Deriving it
/// cannot go stale.
DateTime nextBillingDateAfter(Subscription s, DateTime now) {
  var date = s.startDate;
  var periods = 0;
  while (!date.isAfter(now) && periods++ < _maxPeriods) {
    date = _advance(date, s.cycle);
  }
  return date;
}
