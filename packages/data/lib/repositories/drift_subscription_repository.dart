import 'package:domain/domain.dart' as domain;
import '../database/app_database.dart';
import '../mappers/subscription_mapper.dart';

class DriftSubscriptionRepository implements domain.SubscriptionRepository {
  final AppDatabase _db;
  const DriftSubscriptionRepository(this._db);

  @override
  Stream<List<domain.Subscription>> watchAll() => _db.subscriptionDao
      .watchAll()
      .map((rows) => rows.map((r) => r.toDomain()).toList());

  @override
  Future<List<domain.Subscription>> getAll() async =>
      (await _db.subscriptionDao.getAll()).map((r) => r.toDomain()).toList();

  @override
  Future<void> add(domain.Subscription subscription) =>
      _db.subscriptionDao.insertSubscription(subscription.toCompanion());

  @override
  Future<void> update(domain.Subscription subscription) =>
      _db.subscriptionDao.updateSubscription(subscription.toCompanion());

  @override
  Future<void> delete(String id) => _db.subscriptionDao.deleteSubscription(id);

}
