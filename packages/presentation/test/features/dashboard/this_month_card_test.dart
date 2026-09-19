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
        home: const Scaffold(body: SingleChildScrollView(child: ThisMonthCard())),
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
        rent: const BudgetBucket(budget: 32000, spentThisMonth: 0, typicalSpending: 0),
        living: const BudgetBucket(budget: 30000, spentThisMonth: 210, typicalSpending: 210),
      ),
    );

    expect(find.text('RENT / FIXED'), findsOneWidget);
    expect(find.text('LIVING EXPENSES'), findsOneWidget);
    expect(find.textContaining(RegExp(r'210 / .*30,000')), findsOneWidget);
    expect(find.textContaining(RegExp(r'29,790 left$')), findsOneWidget);
    expect(find.textContaining(RegExp(r'32,000 left$')), findsOneWidget);
  });

  testWidgets('shows how far spending is over budget', (tester) async {
    await _pumpCard(
      tester,
      _burn(
        rent: const BudgetBucket(budget: 0, spentThisMonth: 0, typicalSpending: 0),
        living: const BudgetBucket(budget: 30000, spentThisMonth: 31500, typicalSpending: 31500),
      ),
    );

    expect(find.textContaining(RegExp(r'1,500 over budget$')), findsOneWidget);
    expect(find.text('RENT / FIXED'), findsNothing);
  });

  testWidgets('hides budget rows when no budget is set', (tester) async {
    await _pumpCard(
      tester,
      _burn(
        rent: const BudgetBucket(budget: 0, spentThisMonth: 0, typicalSpending: 0),
        living: const BudgetBucket(budget: 0, spentThisMonth: 210, typicalSpending: 210),
      ),
    );

    expect(find.text('LIVING EXPENSES'), findsNothing);
  });

  testWidgets('tapping the living budget opens the living sheet', (tester) async {
    await _pumpCard(
      tester,
      _burn(
        rent: const BudgetBucket(budget: 32000, spentThisMonth: 0, typicalSpending: 0),
        living: const BudgetBucket(budget: 30000, spentThisMonth: 210, typicalSpending: 210),
      ),
    );

    await tester.tap(find.text('LIVING EXPENSES'));
    await tester.pumpAndSettle();

    expect(find.text('No living expenses logged this month'), findsOneWidget);
  });
}
