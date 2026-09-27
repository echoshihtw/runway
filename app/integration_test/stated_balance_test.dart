import 'package:data/data.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'test_app.dart';

/// The two scenarios, on a device: a commitment entered before any balance
/// must not make the runway answer.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({'onboarding_done': true}));

  String hero(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .firstWhere((t) => t.style?.fontSize == 72)
      .data!;

  testWidgets('a subscription before any balance', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db
        .into(db.subscriptions)
        .insert(
          SubscriptionsCompanion.insert(
            id: 's1',
            name: 'plan',
            amount: 1000,
            cycle: 'monthly',
            category: 'personal',
            startDate: DateTime.now().subtract(const Duration(days: 40)),
            nextBillingDate: DateTime.now().add(const Duration(days: 20)),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

    await tester.pumpWidget(buildTestApp(database: db));
    await pumpRealTime(tester, seconds: 7);

    expect(hero(tester), '—', reason: 'it used to read 0');
    expect(find.text('CRITICAL'), findsNothing);
    expect(
      find.text('Add your balance to see your runway'),
      findsOneWidget,
    );
  });

  testWidgets('a balance answers it', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final now = DateTime.now();
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 't1',
            date: now.subtract(const Duration(days: 5)),
            type: 'openingBalance',
            amount: 600000,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.subscriptions)
        .insert(
          SubscriptionsCompanion.insert(
            id: 's1',
            name: 'plan',
            amount: 1000,
            cycle: 'monthly',
            category: 'personal',
            startDate: now.subtract(const Duration(days: 40)),
            nextBillingDate: now.add(const Duration(days: 20)),
            createdAt: now,
            updatedAt: now,
          ),
        );

    await tester.pumpWidget(buildTestApp(database: db));
    await pumpRealTime(tester, seconds: 7);

    expect(hero(tester), isNot('—'));
    expect(find.text('Add your balance to see your runway'), findsNothing);
  });
}
