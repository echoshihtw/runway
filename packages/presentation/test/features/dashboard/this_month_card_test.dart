import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/dashboard/widgets/this_month_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

MonthlyBurn _burn({required BudgetBucket rent, required BudgetBucket living}) =>
    MonthlyBurn(
      month: LedgerMonth(DateTime(2026, 9)),
      fractionOfMonthLeft: 0.5,
      rent: rent,
      living: living,
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
          const ThisMonthFlow(income: 0, expenses: 210),
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
  testWidgets('shows what is spent and left in each budget', (tester) async {
    await _pumpCard(
      tester,
      _burn(
        rent: const BudgetBucket(
          budget: 32000,
          spentThisMonth: 0,
          typicalSpending: 0,
        ),
        living: const BudgetBucket(
          budget: 30000,
          spentThisMonth: 210,
          typicalSpending: 210,
        ),
      ),
    );

    expect(find.text('RENT / FIXED'), findsOneWidget);
    expect(find.text('LIVING EXPENSES'), findsOneWidget);
    // The card states what is left and stops. The spend against the budget
    // is behind the chevron, in a sheet that already draws it as a bar and
    // turns it into a daily figure.
    expect(find.textContaining(RegExp(r'29,790 left$')), findsOneWidget);
    expect(
      find.textContaining(RegExp(r'210 of ')),
      findsNothing,
      reason: 'the living row has a sheet, so the working lives there',
    );
    expect(find.textContaining(RegExp(r'210 / ')), findsNothing);

    // Rent states its amount and stops. One tenancy is paid once, so
    // "32,000 / 32,000" and "32,000 left" say the same thing twice and
    // neither is a fact anyone acts on.
    expect(find.textContaining(RegExp(r'32,000 left$')), findsNothing);
    expect(find.textContaining(RegExp(r'32,000 / ')), findsNothing);
  });

  testWidgets('rent shows the figures again once it is exceeded', (
    tester,
  ) async {
    // Going over is the exception: it genuinely adds cost and moves the
    // runway, so the ratio comes back exactly when there is something to say.
    await _pumpCard(
      tester,
      _burn(
        rent: const BudgetBucket(
          budget: 32000,
          spentThisMonth: 33000,
          typicalSpending: 33000,
        ),
        living: const BudgetBucket(
          budget: 0,
          spentThisMonth: 0,
          typicalSpending: 0,
        ),
      ),
    );

    expect(find.textContaining(RegExp(r'1,000 over budget$')), findsOneWidget);
    expect(find.textContaining(RegExp(r'33,000 of .*32,000')), findsOneWidget);
  });

  testWidgets('shows how far spending is over budget', (tester) async {
    await _pumpCard(
      tester,
      _burn(
        rent: const BudgetBucket(
          budget: 0,
          spentThisMonth: 0,
          typicalSpending: 0,
        ),
        living: const BudgetBucket(
          budget: 30000,
          spentThisMonth: 31500,
          typicalSpending: 31500,
        ),
      ),
    );

    expect(find.textContaining(RegExp(r'1,500 over budget$')), findsOneWidget);
    expect(find.text('RENT / FIXED'), findsNothing);
  });

  testWidgets('hides budget rows when no budget is set', (tester) async {
    await _pumpCard(
      tester,
      _burn(
        rent: const BudgetBucket(
          budget: 0,
          spentThisMonth: 0,
          typicalSpending: 0,
        ),
        living: const BudgetBucket(
          budget: 0,
          spentThisMonth: 210,
          typicalSpending: 210,
        ),
      ),
    );

    expect(find.text('LIVING EXPENSES'), findsNothing);
  });

  testWidgets('tapping the living budget opens the living sheet', (
    tester,
  ) async {
    await _pumpCard(
      tester,
      _burn(
        rent: const BudgetBucket(
          budget: 32000,
          spentThisMonth: 0,
          typicalSpending: 0,
        ),
        living: const BudgetBucket(
          budget: 30000,
          spentThisMonth: 210,
          typicalSpending: 210,
        ),
      ),
    );

    await tester.tap(find.text('LIVING EXPENSES'));
    await tester.pumpAndSettle();

    expect(find.text('No living expenses logged this month'), findsOneWidget);
  });
}
