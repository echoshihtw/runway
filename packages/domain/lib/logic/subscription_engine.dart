import '../enums/billing_cycle.dart';
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
  active.sort(
    (a, b) => nextBillingDateAfter(a, now).compareTo(nextBillingDateAfter(b, now)),
  );
  return active;
}

/// Compute next billing date from start date and cycle
DateTime computeNextBillingDate(DateTime from, BillingCycle cycle) {
  final now = DateTime.now();
  DateTime next = from;
  while (next.isBefore(now)) {
    next = switch (cycle) {
      BillingCycle.weekly => next.add(const Duration(days: 7)),
      BillingCycle.monthly => DateTime(next.year, next.month + 1, next.day),
      BillingCycle.quarterly => DateTime(next.year, next.month + 3, next.day),
      BillingCycle.yearly => DateTime(next.year + 1, next.month, next.day),
    };
  }
  return next;
}
