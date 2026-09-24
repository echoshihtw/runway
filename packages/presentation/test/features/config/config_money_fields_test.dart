import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/config/config_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The four money fields on this screen carried no inputType at all, so they
/// fell back to the text filter and accepted letters. `_saveBudget` then read
/// them with `double.tryParse(...) ?? 0`, so a stray character silently set
/// the budget to zero — which moves the runway.
class _Settings implements FinancialSettingsRepository {
  @override
  Future<Budget> getBudget() async => const Budget(rent: 1450, living: 1100.5);

  @override
  Future<FinancialAssumptions> getFinancialAssumptions() async =>
      const FinancialAssumptions();

  @override
  Future<RunwayGoal?> getRunwayGoal() async => null;

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _NoSubs implements SubscriptionRepository {
  @override
  Stream<List<Subscription>> watchAll() => Stream.value(const []);
  @override
  Future<List<Subscription>> getAll() async => const [];
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _NoLoans implements LoanRepository {
  @override
  Stream<List<Loan>> watchAll() => Stream.value(const []);
  @override
  Future<List<Loan>> getAll() async => const [];
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _NoTx implements TransactionRepository {
  @override
  Stream<List<Transaction>> watchAll() => Stream.value(const []);
  @override
  Future<List<Transaction>> getAll() async => const [];
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Future<void> _pump(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        financialSettingsRepositoryProvider.overrideWithValue(_Settings()),
        subscriptionRepositoryProvider.overrideWithValue(_NoSubs()),
        loanRepositoryProvider.overrideWithValue(_NoLoans()),
        transactionRepositoryProvider.overrideWithValue(_NoTx()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: ConfigScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a budget field refuses letters', (tester) async {
    await _pump(tester);
    // A budget exists, so its card offers EDIT rather than SET BUDGET.
    final editBudget = find.text('EDIT').last;
    await tester.ensureVisible(editBudget);
    await tester.tap(editBudget);
    await tester.pumpAndSettle();

    final rent = find.byType(TextField).first;
    await tester.enterText(rent, 'abc');
    await tester.pump();

    expect(
      tester.widget<TextField>(rent).controller!.text,
      isEmpty,
      reason: 'letters used to be accepted, then parsed to 0 and saved',
    );
  });

  testWidgets('a budget with cents opens with its cents', (tester) async {
    await _pump(tester);
    // A budget exists, so its card offers EDIT rather than SET BUDGET.
    final editBudget = find.text('EDIT').last;
    await tester.ensureVisible(editBudget);
    await tester.tap(editBudget);
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    expect(tester.widget<TextField>(fields.at(0)).controller!.text, '1450');
    expect(
      tester.widget<TextField>(fields.at(1)).controller!.text,
      '1100.50',
      reason: 'toStringAsFixed(0) used to show 1101 and save it back',
    );
  });
}
