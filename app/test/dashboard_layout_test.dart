import 'package:application/application.dart';
import 'package:data/data.dart' hide Transaction;
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/dashboard/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MemoryStore implements UsageCountStore {
  final counts = <String, int>{};

  @override
  Future<int> read(String key) async => counts[key] ?? 0;

  @override
  Future<void> write(String key, int count) async => counts[key] = count;
}

/// A 6.1-inch iPhone: 390 x 844 points, 47 pt status bar, 34 pt home indicator.
const _screen = Size(390, 844);
const _bottomInset = 34.0;

Transaction _tx(String id, TransactionType type, double amount) => Transaction(
  id: id,
  date: DateTime(2026, 9, 1),
  type: type,
  amount: Money(amount),
  createdAt: DateTime(2026, 9, 1),
  updatedAt: DateTime(2026, 9, 1),
);

Future<void> _pumpDashboard(
  WidgetTester tester, {
  List<Transaction> seed = const [],
}) async {
  tester.view.physicalSize = _screen * 3;
  tester.view.devicePixelRatio = 3;
  tester.view.padding = const FakeViewPadding(top: 47 * 3, bottom: _bottomInset * 3);
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});

  final db = AppDatabase.forTesting(NativeDatabase.memory());
  final transactions = DriftTransactionRepository(db);
  for (final tx in seed) {
    await transactions.add(tx);
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        analyticsProvider.overrideWithValue(const NoOpAnalytics()),
        transactionRepositoryProvider.overrideWithValue(transactions),
        loanRepositoryProvider.overrideWithValue(DriftLoanRepository(db)),
        subscriptionRepositoryProvider.overrideWithValue(
          DriftSubscriptionRepository(db),
        ),
        usageCountStoreProvider.overrideWithValue(_MemoryStore()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DashboardScreen(),
      ),
    ),
  );
  // The header badge animates forever, so pump frames instead of settling.
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  addTearDown(db.close);
}

/// Unmounts the dashboard so Drift's stream-query timers finish before the
/// test binding checks for pending timers.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}

Finder get _runwayNumber => find.byWidgetPredicate(
  (w) => w is Text && w.style?.fontSize == 72,
);

void main() {
  testWidgets('the runway number is fully above the fold with Getting Started visible', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    expect(find.text('GETTING STARTED'), findsOneWidget);
    final number = tester.getRect(_runwayNumber);
    expect(number.bottom, lessThan(_screen.height - _bottomInset));
    expect(number.bottom, lessThan(tester.getRect(find.text('GETTING STARTED')).top));
    await _unmount(tester);
  });

  testWidgets('completed tasks share one line instead of a row each', (
    tester,
  ) async {
    await _pumpDashboard(
      tester,
      seed: [
        _tx('balance', TransactionType.openingBalance, 5000),
        _tx('rent', TransactionType.expense, 1200),
      ],
    );

    expect(find.text('Done: Cash balance · First expense'), findsOneWidget);
    expect(find.text('Add your cash balance'), findsNothing);
    expect(find.text('Log your first expense'), findsNothing);
    expect(find.text('Set your monthly budget'), findsOneWidget);
    expect(find.text('Try the simulator'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('a fresh user sees every task as its own row', (tester) async {
    await _pumpDashboard(tester);

    expect(find.textContaining('Done:'), findsNothing);
    expect(find.text('Add your cash balance'), findsOneWidget);
    expect(find.text('Set your monthly budget'), findsOneWidget);
    expect(find.text('Log your first expense'), findsOneWidget);
    expect(find.text('Try the simulator'), findsOneWidget);
    await _unmount(tester);
  });
}
