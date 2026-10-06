// A device that answered its bills before the billing schedule was fixed.
//
// The schedule used to step date to date, so a clamp into a short month became
// permanent: a plan starting 31 January billed 31 Jan, then the 3rd of every
// month. Those charges are on real devices, under ids the corrected schedule
// no longer derives. The version 7 migration renames them; if it did not, the
// app would ask again and answering would write a second row.
//
// schema_v7_migration_test.dart proves the rename on plain SQLite. This proves
// it on the real SQLCipher database, through to the dashboard, on a simulator.
//
//   flutter test integration_test/drifted_charge_ids_test.dart -d <id>
import 'package:data/data.dart'
    show
        AppDatabase,
        DriftFinancialSettingsRepository,
        DriftSubscriptionRepository,
        DriftTransactionRepository;
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_app.dart';

final _now = DateTime(2026, 9, 23, 10, 30);

/// Bills on the 31st, which is the start day that drifts.
final _startDate = DateTime(2026, 1, 31);

/// What the stepping walk produced, written out rather than derived, so
/// this states what is on a device instead of trusting the code under test.
/// DateTime(2026, 2, 31) is 3 March, and the 3rd never went back to the 31st.
final _steppedDates = <DateTime>[
  DateTime(2026, 1, 31),
  DateTime(2026, 3, 3),
  DateTime(2026, 4, 3),
  DateTime(2026, 5, 3),
  DateTime(2026, 6, 3),
  DateTime(2026, 7, 3),
  DateTime(2026, 8, 3),
  DateTime(2026, 9, 3),
];

/// What the corrected schedule derives for the same eight periods. Every one
/// is a different day from the stepped date beside it except the first.
final _correctedDates = <DateTime>[
  DateTime(2026, 1, 31),
  DateTime(2026, 2, 28),
  DateTime(2026, 3, 31),
  DateTime(2026, 4, 30),
  DateTime(2026, 5, 31),
  DateTime(2026, 6, 30),
  DateTime(2026, 7, 31),
  DateTime(2026, 8, 31),
];

final _subscription = Subscription(
  id: 'gym',
  name: 'Gym',
  category: SubscriptionCategory.personal,
  amount: 300,
  cycle: BillingCycle.monthly,
  startDate: _startDate,
  isActive: true,
  // Before the first bill, so nothing is bounded out by the writable date.
  createdAt: _startDate,
  updatedAt: _startDate,
);

Future<void> _seed(AppDatabase db, {required bool alreadyPaid}) async {
  await DriftFinancialSettingsRepository(
    db,
  ).saveBudget(const Budget(rent: 1450, living: 1100));
  final transactions = DriftTransactionRepository(db);
  await transactions.add(
    Transaction(
      id: 'opening',
      type: TransactionType.openingBalance,
      amount: Money(34000),
      // On the start date, so it covers nothing the subscription bills for.
      date: _startDate,
      note: 'Opening balance',
      createdAt: _startDate,
      updatedAt: _startDate,
    ),
  );
  await DriftSubscriptionRepository(db).add(_subscription);
  if (!alreadyPaid) return;
  for (final date in _steppedDates) {
    await transactions.add(
      Transaction(
        id: subscriptionChargeId(_subscription.id, date),
        type: TransactionType.subscriptionCharge,
        amount: Money(_subscription.amount),
        date: date,
        note: _subscription.name,
        createdAt: date,
        updatedAt: date,
      ),
    );
  }
}

Future<AppDatabase> _boot(
  WidgetTester tester, {
  required bool alreadyPaid,
}) async {
  SharedPreferences.setMockInitialValues({
    'onboarding_done': true,
    'getting_started_dismissed': true,
    'review_requested': true,
    'selected_currency': 'USD',
    'selected_locale': 'en',
  });
  // The real encrypted database, not an in-memory one: this is about rows that
  // are already on a device.
  final seeded = AppDatabase();
  await seeded.customStatement('DELETE FROM transactions;');
  await seeded.customStatement('DELETE FROM subscriptions;');
  await _seed(seeded, alreadyPaid: alreadyPaid);
  // Back to version 6, so reopening runs the migration a device would.
  await seeded.customStatement(
    'ALTER TABLE subscriptions ADD COLUMN next_billing_date INTEGER NOT NULL DEFAULT 0;',
  );
  await seeded.customStatement('PRAGMA user_version = 6;');
  await seeded.close();
  final database = AppDatabase();
  await tester.pumpWidget(buildTestApp(database: database, now: _now));
  await pumpRealTime(tester, seconds: 7);
  return database;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the seed really does carry drifted ids', (tester) async {
    // If the two schedules agreed, both tests below would pass for the wrong
    // reason. Seven of the eight have to differ.
    var differ = 0;
    for (var i = 0; i < _steppedDates.length; i++) {
      if (_steppedDates[i] != _correctedDates[i]) differ++;
    }
    expect(differ, 7, reason: 'the drift this test exists for is not present');
  });

  testWidgets('a bill paid under its old id is not asked about again', (
    tester,
  ) async {
    final db = await _boot(tester, alreadyPaid: true);
    addTearDown(db.close);

    expect(
      find.text('Confirm all'),
      findsNothing,
      reason: 'the owner is being asked to pay eight bills a second time',
    );
    expect(find.text('Yes, log it'), findsNothing);

    // Each moved to its corrected id, and nothing was written on top.
    final rows = await DriftTransactionRepository(db).getAll();
    final charges = rows
        .where((t) => t.type == TransactionType.subscriptionCharge)
        .toList();
    expect(
      charges,
      hasLength(_steppedDates.length),
      reason: 'a duplicate row means the same money left the account twice',
    );
    expect(charges.map((c) => c.id).toSet(), {
      for (final d in _correctedDates) subscriptionChargeId('gym', d),
    });
  });

  testWidgets('a bill that was never paid is still asked about', (
    tester,
  ) async {
    // The control. Without it, a dashboard that silently failed to render
    // would pass the test above.
    final db = await _boot(tester, alreadyPaid: false);
    addTearDown(db.close);

    expect(
      find.text('Confirm all'),
      findsOneWidget,
      reason: 'the migration must not suppress a real question',
    );
  });
}
