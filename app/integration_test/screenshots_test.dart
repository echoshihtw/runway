// Captures the bare app screens for the App Store slides, from the real app
// running on an in-memory database seeded with the demo figures below. The
// slides around them are made locally, outside the repo (assets/marketing).
//
//   SCREENSHOT_DIR=<dir> flutter drive \
//     --driver=test_driver/screenshots.dart \
//     --target=integration_test/screenshots_test.dart -d <simulator id>
import 'package:data/data.dart'
    show
        AppDatabase,
        DriftFinancialSettingsRepository,
        DriftLoanRepository,
        DriftSubscriptionRepository,
        DriftTransactionRepository;
import 'package:domain/domain.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:presentation/router/page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_app.dart';

/// Demo figures. Cash is set so the runway reads twelve months against a
/// monthly cost of rent 1,450 + living 1,100 + subscriptions + loan 210.
/// The instant every captured frame is taken at.
final _capturedAt = DateTime(2026, 9, 15, 10, 30);

const _openingBalance = 34000.0;
const _rentBudget = 1450.0;
const _livingBudget = 1100.0;

/// The monthly cost to try on the plan screen, below the real one.
const _plannedMonthlyCost = '2300';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // A tap that lands on nothing otherwise only prints a warning, and the run
  // still captures a stale frame.
  WidgetController.hitTestWarningShouldBeFatal = true;

  testWidgets('captures the store screenshots', (tester) async {
    SharedPreferences.setMockInitialValues({
      // Start on the dashboard, with no onboarding, nag card or rating prompt.
      'onboarding_done': true,
      'getting_started_dismissed': true,
      'review_requested': true,
      // The listing is English and the US storefront, so show dollars.
      'selected_currency': 'USD',
    });

    final database = AppDatabase.forTesting(NativeDatabase.memory());
    await _seed(database);

    await tester.pumpWidget(
      // Reduce-motion for the whole captured tree. The dashboard's one looping
      // animation sits still under it, so two captures of a frame match.
      MediaQuery(
        data: MediaQueryData.fromView(
          tester.view,
        ).copyWith(disableAnimations: true),
        child: buildTestApp(database: database, now: _capturedAt),
      ),
    );
    // The boot sequence runs on real timers, then routes to the dashboard.
    await pumpRealTime(tester, seconds: 7);

    Future<void> capture(String name) async {
      await pumpRealTime(tester, seconds: 1);
      await binding.takeScreenshot(name);
    }

    await capture('01-runway');

    await tester.scrollUntilVisible(
      find.text('LIVING EXPENSES'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpRealTime(tester, seconds: 1);
    await tester.tap(find.text('LIVING EXPENSES'));
    await pumpRealTime(tester, seconds: 2);
    await capture('02-living');
    // Dismiss the sheet by tapping outside it.
    await _dismissSheet(tester);
    await pumpRealTime(tester, seconds: 2);

    await _tapNav(tester, 'LOG');
    // With the sheet open: the presets are what make logging fast.
    await tester.tap(find.byKey(const Key('add-fab')));
    await pumpRealTime(tester, seconds: 2);
    await capture('03-log');
    await _dismissSheet(tester);
    await pumpRealTime(tester, seconds: 2);

    await _tapNav(tester, 'PLAN');
    await tester.enterText(
      find.byType(EditableText).first,
      _plannedMonthlyCost,
    );
    await pumpRealTime(tester, seconds: 1);
    // Put the keyboard away, so it doesn't cover the result.
    FocusManager.instance.primaryFocus?.unfocus();
    await pumpRealTime(tester, seconds: 1);
    await tester.tap(find.text('RUN SIMULATION'));
    await pumpRealTime(tester, seconds: 2);
    await capture('04-plan');
  });
}

Future<void> _dismissSheet(WidgetTester tester) async {
  tester.state<NavigatorState>(find.byType(Navigator).first).pop();
  await pumpRealTime(tester, seconds: 1);
}

Future<void> _tapNav(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(PageIndicator), matching: find.text(label)),
  );
  await pumpRealTime(tester, seconds: 2);
}

Future<void> _seed(AppDatabase database) async {
  final transactions = DriftTransactionRepository(database);
  final loans = DriftLoanRepository(database);
  final subscriptions = DriftSubscriptionRepository(database);
  final settings = DriftFinancialSettingsRepository(database);

  // Pinned, not the real clock. The countdown to the next charge and the
  // living sheet's per-day figure move every day, so an unpinned capture made
  // the committed set read stale within a fortnight and turned every rerun
  // into a byte diff (#146). A Tuesday mid-month, mid-morning.
  final now = _capturedAt;
  // Never date an entry in the future, whatever day the capture runs on.
  DateTime day(int d) => DateTime(now.year, now.month, d.clamp(1, now.day));

  const loanId = 'demo-student-loan';
  await loans.add(
    Loan(
      id: loanId,
      name: 'Student loan',
      source: 'Bank',
      originalAmount: 18000,
      monthlyPayment: 210,
      originalTermMonths: 96,
      startDate: DateTime(now.year - 3, 4),
      createdAt: now,
      updatedAt: now,
    ),
  );

  final entries = <Transaction>[
    _entry(
      't1',
      day(1),
      TransactionType.openingBalance,
      _openingBalance,
      note: 'Opening balance',
    ),
    _entry(
      't2',
      day(1),
      TransactionType.expense,
      _rentBudget,
      note: 'Rent',
      category: ExpenseCategory.rent,
    ),
    _entry(
      't3',
      day(2),
      TransactionType.repayment,
      210,
      note: 'Student loan',
      loanId: loanId,
    ),
    // Only rent carries a category, because that is all the form sets.
    _entry('t4', day(3), TransactionType.expense, 44, note: 'Metro pass'),
    _entry('t5', day(4), TransactionType.expense, 62, note: 'Groceries'),
    _entry('t6', day(5), TransactionType.income, 2400, note: 'Client invoice'),
    _entry('t7', day(6), TransactionType.expense, 18, note: 'Lunch'),
    _entry(
      't8',
      day(8),
      TransactionType.expense,
      120,
      note: 'Phone and utilities',
    ),
    _entry('t9', day(9), TransactionType.expense, 35, note: 'Coffee'),
    // A fortnight of ordinary spending, so the figures read like a log
    // somebody keeps rather than one they opened twice. Living stays well
    // inside its budget, which is the state the budget rows are there to show.
    _entry('t10', day(10), TransactionType.expense, 26, note: 'Dinner out'),
    _entry('t11', day(11), TransactionType.expense, 58, note: 'Groceries'),
    _entry('t13', day(14), TransactionType.expense, 41, note: 'Pharmacy'),
  ];
  for (final entry in entries) {
    await transactions.add(entry);
  }

  // Generic names on purpose. A real service name on a store screenshot or in
  // the demo video is a third-party trademark, which both Apple and the
  // Shipaton rules forbid.
  // The last field is the day of the month each one bills on. They differ
  // because real subscriptions do, and a column of identical countdowns reads
  // as a bug.
  final subs = <(String, double, BillingCycle, int)>[
    ('Cloud storage', 2.99, BillingCycle.monthly, 20),
    ('Music', 10.99, BillingCycle.monthly, 28),
    ('Gym', 29.00, BillingCycle.monthly, 1),
  ];
  for (final (index, sub) in subs.indexed) {
    final (name, amount, cycle, billingDay) = sub;
    final startDate = DateTime(now.year - 1, now.month, billingDay);
    await subscriptions.add(
      Subscription(
        id: 'demo-sub-$index',
        name: name,
        category: SubscriptionCategory.personal,
        amount: amount,
        cycle: cycle,
        startDate: startDate,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  await settings.saveBudget(
    const Budget(rent: _rentBudget, living: _livingBudget),
  );

  // Expected income, so the frames show the growth half of the product rather
  // than an empty state asking for it. Retainers and a contract, a little
  // above the monthly cost, which is the position the app is for.
  await settings.saveFinancialAssumptions(
    const FinancialAssumptions(expectedMonthlyInflow: 3200),
  );
}

Transaction _entry(
  String id,
  DateTime date,
  TransactionType type,
  double amount, {
  String? note,
  String? loanId,
  ExpenseCategory? category,
}) => Transaction(
  id: id,
  date: date,
  type: type,
  amount: Money(amount),
  note: note,
  loanId: loanId,
  category: category,
  createdAt: date,
  updatedAt: date,
);
