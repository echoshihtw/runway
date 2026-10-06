import 'package:test/test.dart';
import 'package:domain/domain.dart';
import 'package:data/data.dart' hide Transaction, Loan, Subscription;
import 'db_helper.dart';

void main() {
  late AppDatabase db;
  late DriftSubscriptionRepository repo;

  setUp(() {
    db = openTestDatabase();
    repo = DriftSubscriptionRepository(db);
  });

  tearDown(() => db.close());

  group('DriftSubscriptionRepository', () {
    test('getAll returns empty list on fresh database', () async {
      expect(await repo.getAll(), isEmpty);
    });

    test('add then getAll round-trips a monthly subscription', () async {
      await repo.add(_sub(id: 'sub-1', amount: 980, cycle: BillingCycle.monthly));
      final all = await repo.getAll();
      expect(all.length, 1);
      expect(all.first.id, 'sub-1');
      expect(all.first.amount, 980);
      expect(all.first.cycle, BillingCycle.monthly);
    });

    test('yearly subscription has correct monthly equivalent', () async {
      await repo.add(_sub(id: 'sub-1', amount: 12_000, cycle: BillingCycle.yearly));
      final all = await repo.getAll();
      expect(all.first.monthlyEquivalent, closeTo(1_000, 1));
    });

    test('update modifies amount', () async {
      await repo.add(_sub(id: 'sub-1', amount: 980));
      await repo.update(_sub(id: 'sub-1', amount: 1_200));
      final all = await repo.getAll();
      expect(all.first.amount, 1_200);
    });

    test('delete removes subscription', () async {
      await repo.add(_sub(id: 'sub-1', amount: 980));
      await repo.delete('sub-1');
      expect(await repo.getAll(), isEmpty);
    });

    test('personal and business subscriptions coexist', () async {
      await repo.add(_sub(id: 'sub-1', amount: 980, category: SubscriptionCategory.personal));
      await repo.add(_sub(id: 'sub-2', amount: 2_000, category: SubscriptionCategory.business));
      final all = await repo.getAll();
      expect(all.length, 2);
      expect(all.map((s) => s.category).toSet(), {
        SubscriptionCategory.personal,
        SubscriptionCategory.business,
      });
    });

    test('watchAll emits updated list after add', () async {
      final stream = repo.watchAll();
      await repo.add(_sub(id: 'sub-1', amount: 980));
      final snapshot = await stream.first;
      expect(snapshot.length, 1);
      expect(snapshot.first.id, 'sub-1');
    });

    test('watchAll emits updated list after delete', () async {
      await repo.add(_sub(id: 'sub-1', amount: 980));
      await repo.add(_sub(id: 'sub-2', amount: 500));
      final stream = repo.watchAll();
      await repo.delete('sub-1');
      final snapshot = await stream.first;
      expect(snapshot.length, 1);
      expect(snapshot.first.id, 'sub-2');
    });

    test('round-trips all Subscription fields including isActive and note', () async {
      final start = DateTime(2024, 1, 1);
      final now = DateTime(2025, 1, 1);
      final sub = Subscription(
        id: 'sub-full',
        name: 'Netflix',
        category: SubscriptionCategory.personal,
        amount: 490,
        cycle: BillingCycle.monthly,
        startDate: start,
        note: 'family plan',
        isActive: false,
        createdAt: now,
        updatedAt: now,
      );
      await repo.add(sub);
      final fetched = (await repo.getAll()).first;
      expect(fetched.name, 'Netflix');
      expect(fetched.note, 'family plan');
      expect(fetched.isActive, false);
      expect(fetched.cycle, BillingCycle.monthly);
    });

    test('all four billing cycles survive round-trip', () async {
      for (final cycle in BillingCycle.values) {
        final id = 'sub-${cycle.name}';
        await repo.add(_sub(id: id, amount: 100, cycle: cycle));
      }
      final all = await repo.getAll();
      expect(all.length, BillingCycle.values.length);
      expect(
        all.map((s) => s.cycle).toSet(),
        BillingCycle.values.toSet(),
      );
    });
  });
}

Subscription _sub({
  required String id,
  required double amount,
  BillingCycle cycle = BillingCycle.monthly,
  SubscriptionCategory category = SubscriptionCategory.personal,
}) {
  final now = DateTime(2025, 1, 1);
  return Subscription(
    id: id,
    name: 'TEST SERVICE',
    category: category,
    amount: amount,
    cycle: cycle,
    startDate: now,
    createdAt: now,
    updatedAt: now,
  );
}
