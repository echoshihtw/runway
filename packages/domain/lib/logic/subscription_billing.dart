import '../entities/subscription.dart';
import '../entities/transaction.dart';
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

/// [months] after [from], with the day taken from [from] every time.
///
/// A short month clamps to its last day and the next long one goes back to the
/// original: the 31st bills on the 31st, the 28th in February, the 31st again
/// in March. That is what every card and bank does with a date that does not
/// exist in the month it lands in.
DateTime _addMonths(DateTime from, int months) {
  final zeroBased = from.month - 1 + months;
  final year = from.year + zeroBased ~/ 12;
  final month = zeroBased % 12 + 1;
  // Day zero of the next month is the last day of this one.
  final lastDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, from.day < lastDay ? from.day : lastDay);
}

/// Calendar days after [from].
///
/// Not a Duration: Duration is absolute time, so seven days across a daylight
/// saving change lands an hour earlier, and at midnight that is the day
/// before. The charge id is built from the day.
DateTime _addDays(DateTime from, int days) =>
    DateTime(from.year, from.month, from.day + days);

/// The [periods]th billing date of a plan starting [start] on [cycle].
/// Period 0 is the start date. Always midnight: a billing date is a calendar
/// day, and a time of day made a bill due at 14:30 read as still ahead at 09:00.
///
/// Counted from the start, never stepped from the date before it. Stepping made
/// a clamp permanent, because DateTime(2026, 2, 31) is 3 March: a plan starting
/// 31 January billed 31 Jan, then the 3rd for ever, skipping February.
DateTime billingDateAt(DateTime start, BillingCycle cycle, int periods) =>
    switch (cycle) {
      BillingCycle.weekly => _addDays(start, 7 * periods),
      BillingCycle.monthly => _addMonths(start, periods),
      BillingCycle.quarterly => _addMonths(start, 3 * periods),
      BillingCycle.yearly => _addMonths(start, 12 * periods),
    };

/// Only a guard against a runaway loop. It has to be far beyond any real
/// start date, because truncating the walk would stop a plan billing at all:
/// a weekly plan whose year was mistyped decades back would run out of
/// iterations before reaching today and then never bill again.
const _maxPeriods = 10000;

/// Billing dates of [s] from its start date up to and including [to].
List<DateTime> billingDatesUpTo(Subscription s, DateTime to) {
  final dates = <DateTime>[];
  for (var periods = 0; periods < _maxPeriods; periods++) {
    final date = billingDateAt(s.startDate, s.cycle, periods);
    if (date.isAfter(to)) break;
    dates.add(date);
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

/// The dates the schedule produced before the drift fix, by period.
///
/// Charges confirmed on a device are recorded under ids derived from those
/// dates. Without them the corrected dates read as unpaid, and answering the
/// prompt again writes a second row for money already spent.
///
/// By period, not by value: the old walk skipped whole months.
///
/// Recognition only, never written. Empty where the dates never moved, which
/// is every weekly plan and every start day up to the 28th. Delete once a
/// migration has rewritten the stored ids.
List<DateTime> legacyBillingDates(Subscription s, DateTime to) {
  if (s.cycle == BillingCycle.weekly || s.startDate.day <= 28) return const [];
  final dates = <DateTime>[];
  var date = s.startDate;
  for (var periods = 0; periods < _maxPeriods && !date.isAfter(to); periods++) {
    dates.add(date);
    date = switch (s.cycle) {
      BillingCycle.weekly => date,
      BillingCycle.monthly => DateTime(date.year, date.month + 1, date.day),
      BillingCycle.quarterly => DateTime(date.year, date.month + 3, date.day),
      BillingCycle.yearly => DateTime(date.year + 1, date.month, date.day),
    };
  }
  return dates;
}

/// Whether [period] of [s] is in [recorded], under the id derived now or the
/// one derived before the drift fix.
bool chargeAlreadyRecorded({
  required Subscription s,
  required int period,
  required DateTime date,
  required List<DateTime> legacy,
  required Set<String> recorded,
}) =>
    recorded.contains(subscriptionChargeId(s.id, date)) ||
    (period < legacy.length &&
        recorded.contains(subscriptionChargeId(s.id, legacy[period])));

/// A charge's id is derived from its subscription and payment date, so a
/// second copy collides with the primary key and a confirmed charge can be
/// recognised without a column linking the two.
String subscriptionChargeId(String subscriptionId, DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return 'subchg-$subscriptionId-${date.year}$month$day';
}

/// What subscriptions still owe this month: every bill dated in it that has no
/// confirmed entry.
///
/// A bill whose date has passed but which the owner has not answered for yet is
/// owed, not invisible. Counting only the bills still ahead left it in neither
/// cash nor the month's cost, which pushed the runway long — the direction this
/// whole correction exists to fix.
///
/// A confirmed charge is already out of cash, so it is not counted again.
double subscriptionsUnpaidThisMonth({
  required List<Subscription> subscriptions,
  required List<Transaction> transactions,
  required DateTime now,
}) {
  final first = DateTime(now.year, now.month);
  final last = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
  final recorded = transactions.map((t) => t.id).toSet();
  var owed = 0.0;
  for (final s in subscriptions.where((s) => s.isActive)) {
    // From period 0, so the index is the period a legacy id matches on.
    final dates = billingDatesUpTo(s, last);
    final legacy = legacyBillingDates(s, last);
    for (var period = 0; period < dates.length; period++) {
      final date = dates[period];
      if (date.isBefore(first)) continue;
      if (chargeAlreadyRecorded(
        s: s,
        period: period,
        date: date,
        legacy: legacy,
        recorded: recorded,
      )) {
        continue;
      }
      owed += s.amount;
    }
  }
  return owed;
}

/// Calendar days until the next bill.
///
/// Derived, because the stored `nextBillingDate` is written once and never
/// advanced: once its date passed, the countdown clamped to 0 and stayed there
/// for good. Measured from the start of today, so a bill eight days away reads
/// as 8 rather than flooring a part-day to 7.
int daysUntilNextBilling(Subscription s, DateTime now) {
  final startOfToday = DateTime(now.year, now.month, now.day);
  return nextBillingDateAfter(
    s.startDate,
    s.cycle,
    now,
  ).difference(startOfToday).inDays.clamp(0, 9999);
}

/// The first billing date of a plan starting [start] on [cycle] that is still
/// ahead of [now].
///
/// The stored `nextBillingDate` is never advanced after creation, so once a
/// date passes it stays in the past and the countdown sticks at 0. Deriving it
/// cannot go stale.
///
/// Takes the two fields the schedule depends on rather than a Subscription, so
/// the sheet that is still building one can ask the same question.
DateTime nextBillingDateAfter(
  DateTime start,
  BillingCycle cycle,
  DateTime now,
) {
  for (var periods = 0; periods < _maxPeriods; periods++) {
    final date = billingDateAt(start, cycle, periods);
    if (date.isAfter(now)) return date;
  }
  return billingDateAt(start, cycle, _maxPeriods);
}
