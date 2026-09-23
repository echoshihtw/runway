// Captures the subscription question on a real device, in both languages.
//
// The question only appears once a billing date has passed without the charge
// being recorded, which on a real phone means waiting for one to arrive. Here
// the clock is fixed and the data seeded so a charge is already due, and the
// prompt is on screen the moment the dashboard loads.
//
//   SCREENSHOT_DIR=<dir> flutter drive \
//     --driver=test_driver/screenshots.dart \
//     --target=integration_test/subscription_prompt_shots_test.dart -d <id>
import 'package:data/data.dart'
    show
        AppDatabase,
        DriftFinancialSettingsRepository,
        DriftSubscriptionRepository,
        DriftTransactionRepository;
import 'package:domain/domain.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_app.dart';

final _capturedAt = DateTime(2026, 9, 15, 10, 30);

/// Seeds an opening balance, a budget, and subscriptions whose billing dates
/// have already passed. A charge is only ever written from the latest of the
/// subscription's start, the date the app learned about it, and the opening
/// balance, so all three sit before the billing dates below.
Future<void> _seed(AppDatabase db, {required int subscriptions}) async {
  final transactions = DriftTransactionRepository(db);
  final subs = DriftSubscriptionRepository(db);
  final settings = DriftFinancialSettingsRepository(db);

  await settings.saveBudget(const Budget(rent: 1450, living: 1100));
  await transactions.add(
    Transaction(
      id: 'opening',
      type: TransactionType.openingBalance,
      amount: Money(34000),
      date: DateTime(2026, 9, 1),
      note: 'Opening balance',
      createdAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    ),
  );

  const plans = [
    ('Spotify', 10.99, 3),
    ('iCloud', 2.99, 8),
    ('Netflix', 15.49, 12),
  ];
  for (var i = 0; i < subscriptions; i++) {
    final (name, amount, day) = plans[i];
    await subs.add(
      Subscription(
        id: 'sub-$i',
        name: name,
        category: SubscriptionCategory.personal,
        amount: amount,
        cycle: BillingCycle.monthly,
        startDate: DateTime(2026, 9, day),
        nextBillingDate: DateTime(2026, 10, day),
        isActive: true,
        createdAt: DateTime(2026, 9, 1),
        updatedAt: DateTime(2026, 9, 1),
      ),
    );
  }
}

Future<void> _run(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding, {
  required String locale,
  required String label,
  required int subscriptions,
}) async {
  SharedPreferences.setMockInitialValues({
    'onboarding_done': true,
    'getting_started_dismissed': true,
    'review_requested': true,
    'selected_currency': 'USD',
    'selected_locale': locale,
  });
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  await _seed(database, subscriptions: subscriptions);
  await tester.pumpWidget(buildTestApp(database: database, now: _capturedAt));
  await pumpRealTime(tester, seconds: 7);
  await binding.takeScreenshot(label);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  for (final locale in ['en', 'zh']) {
    testWidgets('one charge due [$locale]', (tester) async {
      await _run(
        tester,
        binding,
        locale: locale,
        label: 'prompt-one-$locale',
        subscriptions: 1,
      );
    });

    testWidgets('a queue of three [$locale]', (tester) async {
      await _run(
        tester,
        binding,
        locale: locale,
        label: 'prompt-queue-$locale',
        subscriptions: 3,
      );
    });
  }
}
