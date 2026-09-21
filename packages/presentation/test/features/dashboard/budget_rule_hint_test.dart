import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/dashboard/widgets/this_month_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A budget is a cap that spending uses up, not a cost that spending adds to.
/// The engine implements it and the store listing explains it, but the app
/// said it only in a caption you had to open a settings sheet to read. Someone
/// logging a large expense inside its budget watches the runway not move and
/// concludes the app is broken.
const _rule = 'Spending uses up its budget. Only going over adds cost.';

MonthlyBurn _burn({required double rent, required double living}) =>
    MonthlyBurn(
      month: LedgerMonth(DateTime(2026, 9)),
      fractionOfMonthLeft: 0.5,
      rent: BudgetBucket(budget: rent, spentThisMonth: 0, typicalSpending: 0),
      living: BudgetBucket(
        budget: living,
        spentThisMonth: 500,
        typicalSpending: 500,
      ),
      subscriptions: 0,
      loanPayments: 0,
      loanPaymentsLeftThisMonth: 0,
    );

Future<void> _pumpCard(WidgetTester tester, MonthlyBurn burn) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        thisMonthFlowProvider.overrideWithValue(
          const ThisMonthFlow(income: 0, expenses: 500),
        ),
        monthlyBurnProvider.overrideWithValue(burn),
        transactionsProvider.overrideWith((ref) => Stream.value(const [])),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SingleChildScrollView(child: ThisMonthCard()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the card states the rule its numbers obey', (tester) async {
    await _pumpCard(tester, _burn(rent: 1450, living: 1100));
    expect(find.text(_rule), findsOneWidget);
  });

  testWidgets('one budget is enough for the rule to matter', (tester) async {
    await _pumpCard(tester, _burn(rent: 0, living: 1100));
    expect(find.text(_rule), findsOneWidget);
  });

  testWidgets('with no budget set there is no rule to state', (tester) async {
    await _pumpCard(tester, _burn(rent: 0, living: 0));
    expect(find.textContaining('uses up its budget'), findsNothing);
  });
}
