import '../enums/billing_cycle.dart';
import '../enums/subscription_category.dart';

class Subscription {
  final String id;
  final String name;
  final SubscriptionCategory category;
  final double amount;
  final BillingCycle cycle;
  final DateTime startDate;
  final DateTime nextBillingDate;
  final String? note;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subscription({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.cycle,
    required this.startDate,
    required this.nextBillingDate,
    this.note,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Normalized monthly cost
  double get monthlyEquivalent => cycle.monthlyEquivalent(amount);

  Subscription copyWith({
    String? id,
    String? name,
    SubscriptionCategory? category,
    double? amount,
    BillingCycle? cycle,
    DateTime? startDate,
    DateTime? nextBillingDate,
    String? note,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      cycle: cycle ?? this.cycle,
      startDate: startDate ?? this.startDate,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      note: note ?? this.note,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
