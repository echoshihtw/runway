// Captures the subscription question, in both languages.
//
// The question only appears once a billing date has passed without the charge
// being recorded, so on a device you wait for one to arrive. Here the clock is
// fixed and the data seeded so a charge is already due, and the question is on
// screen the moment the dashboard loads.
//
//   SCREENSHOT_DIR=<dir> flutter drive \
//     --driver=test_driver/screenshots.dart \
//     --target=integration_test/subscription_prompt_shots_test.dart -d <id>
//
// It captures rather than asserts. Whether the right charges come due is
// covered by subscription_charges_test.dart, and what the card does with them
// by subscription_prompt_card_test.dart.
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

/// The instant every frame is taken at. Every date below is placed against it.
final _capturedAt = DateTime(2026, 9, 15, 10, 30);

/// Stated before the subscriptions start, because a charge is never written
/// for a date the opening balance already covers.
final _openingBalanceDate = DateTime(2026, 9, 1);

typedef _Plan = ({String name, double amount, int billingDay});

/// Billing days sit between the opening balance and the capture instant, which
/// is what leaves them due and unanswered. [_billingDatesAreDue] holds us to it.
const _plans = <_Plan>[
  (name: 'Spotify', amount: 10.99, billingDay: 3),
  (name: 'iCloud', amount: 2.99, billingDay: 8),
  (name: 'Netflix', amount: 15.49, billingDay: 12),
];

/// The question is driven by the start date walked forward by the cycle, not
/// by the stored nextBillingDate, so the start date is the billing day itself.
Subscription _subscription(int index, _Plan plan) {
  final billedOn = DateTime(_capturedAt.year, _capturedAt.month, plan.billingDay);
  return Subscription(
    id: 'sub-$index',
    name: plan.name,
    category: SubscriptionCategory.personal,
    amount: plan.amount,
    cycle: BillingCycle.monthly,
    startDate: billedOn,
    nextBillingDate: DateTime(billedOn.year, billedOn.month + 1, billedOn.day),
    isActive: true,
    createdAt: _openingBalanceDate,
    updatedAt: _openingBalanceDate,
  );
}

/// A charge is only written from the latest of the subscription's start date,
/// the date the app learned about it, and the opening balance. Get any of those
/// wrong and the seed silently produces no question at all, and the frame comes
/// out as an ordinary dashboard rather than a failure.
void _billingDatesAreDue(List<_Plan> plans) {
  for (final plan in plans) {
    final billedOn = DateTime(_capturedAt.year, _capturedAt.month, plan.billingDay);
    if (!billedOn.isAfter(_openingBalanceDate) || billedOn.isAfter(_capturedAt)) {
      throw StateError(
        '${plan.name} bills on $billedOn, which is not between the opening '
        'balance on $_openingBalanceDate and the capture at $_capturedAt, so '
        'nothing would be due and the frame would show no question.',
      );
    }
  }
}

Future<void> _seed(AppDatabase db, List<_Plan> plans) async {
  _billingDatesAreDue(plans);
  await DriftFinancialSettingsRepository(
    db,
  ).saveBudget(const Budget(rent: 1450, living: 1100));
  await DriftTransactionRepository(db).add(
    Transaction(
      id: 'opening',
      type: TransactionType.openingBalance,
      amount: Money(34000),
      date: _openingBalanceDate,
      note: 'Opening balance',
      createdAt: _openingBalanceDate,
      updatedAt: _openingBalanceDate,
    ),
  );
  final subscriptions = DriftSubscriptionRepository(db);
  for (final (index, plan) in plans.indexed) {
    await subscriptions.add(_subscription(index, plan));
  }
}

Future<void> _capture(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding, {
  required String name,
  required String locale,
  required List<_Plan> plans,
}) async {
  SharedPreferences.setMockInitialValues({
    // Straight to the dashboard: no onboarding, nag card or rating prompt.
    'onboarding_done': true,
    'getting_started_dismissed': true,
    'review_requested': true,
    'selected_currency': 'USD',
    'selected_locale': locale,
  });
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  await _seed(database, plans);
  await tester.pumpWidget(buildTestApp(database: database, now: _capturedAt));
  // The boot sequence runs on real timers before routing to the dashboard.
  await pumpRealTime(tester, seconds: 7);
  await binding.takeScreenshot('$name-$locale');
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  for (final locale in ['en', 'zh']) {
    testWidgets('one charge is a question [$locale]', (tester) async {
      await _capture(
        tester,
        binding,
        name: 'prompt-one',
        locale: locale,
        plans: _plans.take(1).toList(),
      );
    });

    // A returning owner meets a queue, which the card asks about once rather
    // than one question at a time.
    testWidgets('three charges are one question [$locale]', (tester) async {
      await _capture(
        tester,
        binding,
        name: 'prompt-queue',
        locale: locale,
        plans: _plans,
      );
    });
  }
}
