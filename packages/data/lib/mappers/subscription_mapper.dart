import 'package:drift/drift.dart';
import 'package:domain/domain.dart' as domain;
import '../database/app_database.dart';

extension SubscriptionRowMapper on Subscription {
  domain.Subscription toDomain() => domain.Subscription(
    id: id,
    name: name,
    category: domain.SubscriptionCategory.values.byName(category),
    amount: amount,
    cycle: domain.BillingCycle.values.byName(cycle),
    startDate: startDate,
    note: note,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension SubscriptionDomainMapper on domain.Subscription {
  SubscriptionsCompanion toCompanion() => SubscriptionsCompanion(
    id: Value(id),
    name: Value(name),
    category: Value(category.name),
    amount: Value(amount),
    cycle: Value(cycle.name),
    startDate: Value(startDate),
    note: Value(note),
    isActive: Value(isActive),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
  );
}
