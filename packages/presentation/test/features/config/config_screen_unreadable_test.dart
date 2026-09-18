import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/config/config_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A settings read that failed used to render as "Not set" beside an EDIT or
/// SET button. Tapping it seeded empty fields, and saving wrote those empties
/// over the real values on disk. The screen must not offer to edit what it
/// could not read — and Riverpod retries a failing read for about 38 seconds
/// before it errors, so "still loading" has to be treated the same way.
class _Unreadable implements FinancialSettingsRepository {
  @override
  Future<Budget> getBudget() async => throw Exception('database is locked');

  @override
  Future<FinancialAssumptions> getFinancialAssumptions() async =>
      throw Exception('database is locked');

  @override
  Future<RunwayGoal?> getRunwayGoal() async =>
      throw Exception('database is locked');

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

/// Settings that read fine: a living budget and an active cost assumption.
class _Readable extends _Unreadable {
  @override
  Future<Budget> getBudget() async => const Budget(living: 1100);

  @override
  Future<FinancialAssumptions> getFinancialAssumptions() async =>
      const FinancialAssumptions(expectedMonthlyBurnOverride: 2300);

  @override
  Future<RunwayGoal?> getRunwayGoal() async => null;
}

Duration? _noRetry(int retryCount, Object error) => null;

const _failure =
    "Couldn't load these settings. Editing is off so nothing overwrites them.";
const _editAffordances = ['EDIT', 'SET BUDGET', 'SET FORECAST', 'SET GOAL'];

/// [settle] is false for the loading-window case: pumpAndSettle would run the
/// fake clock through every retry and land in the error state instead.
Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required bool retry,
  required bool settle,
  FinancialSettingsRepository? settings,
}) async {
  SharedPreferences.setMockInitialValues({});
  final container = ProviderContainer(
    retry: retry ? null : _noRetry,
    overrides: [
      financialSettingsRepositoryProvider.overrideWithValue(
        settings ?? _Unreadable(),
      ),
      subscriptionRepositoryProvider.overrideWithValue(_NoSubscriptions()),
      loanRepositoryProvider.overrideWithValue(_NoLoans()),
      transactionRepositoryProvider.overrideWithValue(_NoTransactions()),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: ConfigScreen()),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump();
  }
  return container;
}

void main() {
  testWidgets('a read that failed says so, and offers nothing to edit', (
    tester,
  ) async {
    final container = await _pump(tester, retry: false, settle: true);
    addTearDown(container.dispose);

    expect(
      find.text(_failure),
      findsNWidgets(3),
      reason: 'each of the three settings cards owns its own read',
    );
    for (final label in _editAffordances) {
      expect(
        find.text(label),
        findsNothing,
        reason: '$label would open a form seeded with nothing, and saving '
            'that form writes nothing over the real values',
      );
    }
    expect(find.text('Not set'), findsNothing,
        reason: 'unknown is not the same as unset');
  });

  testWidgets('while the read is still running, nothing can be edited either', (
    tester,
  ) async {
    final container = await _pump(tester, retry: true, settle: false);

    expect(find.text('LOADING...'), findsNWidgets(3));
    for (final label in _editAffordances) {
      expect(find.text(label), findsNothing, reason: '$label during loading');
    }
    expect(find.text('Not set'), findsNothing);

    // Dispose now, before the test ends, so the pending retry timers are
    // cancelled rather than reported as leaked.
    container.dispose();
    await tester.pump();
  });

  testWidgets('while an assumption is active, the computed cost stays visible', (
    tester,
  ) async {
    // #87: the assumption replaces the computed figure in the runway, so the
    // one place the owner can compare them is here. It used to show only the
    // assumption.
    final container = await _pump(
      tester,
      retry: false,
      settle: true,
      settings: _Readable(),
    );
    addTearDown(container.dispose);

    expect(find.textContaining('2,300'), findsOneWidget, reason: 'the assumption');
    expect(
      find.textContaining('Computed'),
      findsOneWidget,
      reason: 'and what the budget and log actually come to',
    );
  });
}
