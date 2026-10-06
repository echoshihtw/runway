import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/dashboard/widgets/every_month_card.dart';

/// The growth half of the product had no surface. The figure existed and
/// showed only as one caption under the status badge, once the forecast sheet
/// had been filled in, so the app said plenty about money leaving and nothing
/// about money arriving.
ModelState _model({
  double? expectedInflow,
  bool hasCostBasis = true,
  RunwayBasis basis = RunwayBasis.budget,
}) => ModelState(
  basis: basis,
  hasCostBasis: hasCostBasis,
  currentCash: 34000,
  burnRate: 2800,
  effectiveBurnRate: 2800,
  monthlyPayment: 0,
  subscriptionMonthlyCost: 0,
  expectedMonthlyInflow: expectedInflow,
  runwayMonths: 12,
  runwayDays: 365,
);

Future<void> _pump(
  WidgetTester tester,
  ModelState model, {
  VoidCallback? onSetUp,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: EveryMonthCard(model: model, onSetUp: onSetUp ?? () {}),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('with income set it states both sides and what is left', (
    tester,
  ) async {
    await _pump(tester, _model(expectedInflow: 4200));

    expect(find.text('Expected income'), findsOneWidget);
    expect(find.text('Monthly costs'), findsOneWidget);
    expect(find.text('Surplus'), findsOneWidget);
    expect(find.textContaining('4,200'), findsOneWidget);
    expect(find.textContaining('2,800'), findsOneWidget);
    expect(find.textContaining('1,400'), findsOneWidget);
  });

  testWidgets('income below costs reads as a deficit, without alarm', (
    tester,
  ) async {
    await _pump(tester, _model(expectedInflow: 1800));

    expect(find.text('Deficit'), findsOneWidget);
    expect(find.text('Surplus'), findsNothing);
    expect(find.textContaining('1,000'), findsOneWidget);
  });

  testWidgets('with no income set it offers one way to set it and no more', (
    tester,
  ) async {
    var opened = 0;
    await _pump(tester, _model(), onSetUp: () => opened++);

    expect(find.text('Set expected income'), findsOneWidget);
    expect(find.text('Expected income'), findsNothing);
    expect(find.text('Surplus'), findsNothing);
    expect(find.text('Deficit'), findsNothing);

    await tester.tap(find.text('Set expected income'));
    await tester.pumpAndSettle();
    expect(opened, 1);
  });

  testWidgets('it says nothing while no cost is known', (tester) async {
    // Without a budget, a loan or a subscription the monthly cost is not
    // zero, it is unknown — which is why the runway card beside this one
    // prints a dash. "Monthly costs 0, Surplus everything" is a confident
    // wrong answer.
    await _pump(tester, _model(expectedInflow: 4200, hasCostBasis: false));

    expect(find.text('Monthly costs'), findsNothing);
    expect(find.text('Surplus'), findsNothing);
    expect(find.text('Set expected income'), findsOneWidget);
  });

  test('the runway still ignores expected income', () {
    // CONTRACTS.md §3.2: the runway is what the cash covers if income stopped
    // today. This card says whether the month adds to that; it must not
    // change it.
    final withIncome = _model(expectedInflow: 4200);
    final without = _model();

    expect(withIncome.runwayMonths, without.runwayMonths);
    expect(withIncome.sustainableNetMonthlyFlow, 1400);
    expect(without.hasSustainableProjection, isFalse);
  });

  testWidgets('the costs caption is absent on an assumption', (tester) async {
    // Monthly costs is normally the budget plus subscriptions plus loan
    // payments, and the caption says so. On an expected-cost assumption it is
    // a number somebody typed and includes nothing, so the caption would be
    // false in exactly the state where its reader is least sure where the
    // figure came from.
    await _pump(tester, _model(expectedInflow: 3200));
    expect(
      find.text('Includes subscriptions and loan payments'),
      findsOneWidget,
      reason: 'a computed figure does have parts',
    );

    await _pump(
      tester,
      _model(expectedInflow: 3200, basis: RunwayBasis.assumption),
    );
    expect(
      find.text('Includes subscriptions and loan payments'),
      findsNothing,
      reason: 'a typed assumption includes nothing',
    );
  });
}
