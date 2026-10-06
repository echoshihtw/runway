import 'dart:async';

import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/config/config_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Every save and clear handler on this screen ended in setState and a
/// FocusScope lookup after an await, with no mounted check (#95 item 1).
/// Tap SAVE, swipe the sheet down before the write lands, and the
/// continuation runs against a disposed State.
class _Slow implements FinancialSettingsRepository {
  _Slow({this.seeded = const FinancialAssumptions()});

  /// Seeded so CLEAR has something to clear; empty for the SAVE path.
  final FinancialAssumptions seeded;
  final saved = Completer<void>();

  @override
  Future<Budget> getBudget() async => const Budget();

  @override
  Future<FinancialAssumptions> getFinancialAssumptions() async => seeded;

  @override
  Future<RunwayGoal?> getRunwayGoal() async => null;

  @override
  Future<void> saveFinancialAssumptions(FinancialAssumptions a) =>
      saved.future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoSubscriptions implements SubscriptionRepository {
  @override
  Stream<List<Subscription>> watchAll() => Stream.value(const []);

  @override
  Future<List<Subscription>> getAll() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoLoans implements LoanRepository {
  @override
  Stream<List<Loan>> watchAll() => Stream.value(const []);

  @override
  Future<List<Loan>> getAll() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoTransactions implements TransactionRepository {
  @override
  Stream<List<Transaction>> watchAll() => Stream.value(const []);

  @override
  Future<List<Transaction>> getAll() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Dismissing the sheet disposes the screen, not the app's providers, so the
/// container outlives the widget here too.
Widget _app(ProviderContainer container, Widget home) =>
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );

Future<(ProviderContainer, _Slow)> _pump(
  WidgetTester tester, {
  FinancialAssumptions seeded = const FinancialAssumptions(),
}) async {
  SharedPreferences.setMockInitialValues({});
  final settings = _Slow(seeded: seeded);
  final container = ProviderContainer(
    overrides: [
      financialSettingsRepositoryProvider.overrideWithValue(settings),
      subscriptionRepositoryProvider.overrideWithValue(_NoSubscriptions()),
      loanRepositoryProvider.overrideWithValue(_NoLoans()),
      transactionRepositoryProvider.overrideWithValue(_NoTransactions()),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(_app(container, const Scaffold(body: ConfigScreen())));
  await tester.pumpAndSettle();
  return (container, settings);
}

void main() {
  testWidgets('a save that lands after the screen is gone does nothing', (
    tester,
  ) async {
    final (container, settings) = await _pump(tester);

    await tester.ensureVisible(find.text('SET FORECAST'));
    await tester.tap(find.text('SET FORECAST'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '5000');
    await tester.ensureVisible(find.text('SAVE'));
    await tester.tap(find.text('SAVE'));
    await tester.pump();

    // The sheet is swiped away while the write is still in flight.
    await tester.pumpWidget(_app(container, const SizedBox()));
    settings.saved.complete();
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('a clear that lands after the screen is gone does nothing', (
    tester,
  ) async {
    // The guard has to sit above the controller mutations, not below them:
    // dispose() has already disposed the controllers, and clear() notifies a
    // disposed notifier. With the guard below, this fails with
    // "A TextEditingController was used after being disposed."
    final (container, settings) = await _pump(
      tester,
      seeded: const FinancialAssumptions(expectedMonthlyInflow: 5000),
    );

    await tester.ensureVisible(find.text('CLEAR').first);
    await tester.tap(find.text('CLEAR').first);
    await tester.pump();

    await tester.pumpWidget(_app(container, const SizedBox()));
    settings.saved.complete();
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
