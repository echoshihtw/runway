import '../entities/subscription.dart';
import 'subscription_billing.dart';
import '../enums/subscription_category.dart';

/// Total monthly cost across all active subscriptions
double totalSubscriptionMonthlyCost(List<Subscription> subscriptions) {
  return subscriptions
      .where((s) => s.isActive)
      .fold(0.0, (sum, s) => sum + s.monthlyEquivalent);
}

/// Monthly cost filtered by category
double subscriptionMonthlyCostByCategory(
  List<Subscription> subscriptions,
  SubscriptionCategory category,
) {
  return subscriptions
      .where((s) => s.isActive && s.category == category)
      .fold(0.0, (sum, s) => sum + s.monthlyEquivalent);
}

/// Yearly cost projection
double totalSubscriptionYearlyCost(List<Subscription> subscriptions) {
  return totalSubscriptionMonthlyCost(subscriptions) * 12;
}

/// Subscriptions sorted by the bill that comes next.
///
/// Ordered by the derived date, not the stored one. Nothing advances
/// `nextBillingDate` after a subscription is created, so sorting by it put the
/// list in the order the plans were first saved and left it there.
List<Subscription> sortedByNextBilling(
  List<Subscription> subscriptions, {
  required DateTime now,
}) {
  final active = subscriptions.where((s) => s.isActive).toList();
  // Keyed once per plan. Deriving a next bill walks the schedule, so doing it
  // inside the comparator walked it O(n log n) times: ten milliseconds for
  // twenty-four plans, on every rebuild of the panel.
  final nextBill = {
    for (final s in active)
      s.id: nextBillingDateAfter(s.startDate, s.cycle, now),
  };
  active.sort((a, b) => nextBill[a.id]!.compareTo(nextBill[b.id]!));
  return active;
}
