import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/dashboard/widgets/goal_card.dart';

/// The card drew a progress bar whose unfilled half had no size, and called
/// the remainder "months to go", which reads as time that has to pass rather
/// than cover that has to be built.
class _FixedGoal extends RunwayGoalNotifier {
  _FixedGoal(this.goal);
  final RunwayGoal? goal;

  @override
  Future<RunwayGoal?> build() async => goal;
}

ModelState _model({
  double cash = 34336,
  double cost = 2803,
  int months = 12,
  bool cashIsKnown = true,
}) => ModelState(
  cashIsKnown: cashIsKnown,
  currentCash: cash,
  burnRate: cost,
  effectiveBurnRate: cost,
  monthlyPayment: 0,
  subscriptionMonthlyCost: 0,
  runwayMonths: months,
  runwayDays: months * 30,
);

/// What a month really costs, which is what the goal is measured against.
///
/// Deliberately separate from [ModelState.effectiveBurnRate]: that one
/// resolves to the Forecast card's expected-cost override when there is one,
/// and a savings target must not move because somebody typed a guess three
/// cards away.
MonthlyBurn _burn(double cost) => MonthlyBurn(
  month: LedgerMonth(DateTime(2026, 9, 15)),
  fractionOfMonthLeft: 1,
  rent: const BudgetBucket(budget: 0, spentThisMonth: 0, typicalSpending: 0),
  living: BudgetBucket(budget: cost, spentThisMonth: 0, typicalSpending: 0),
  subscriptions: 0,
  loanPayments: 0,
  loanPaymentsLeftThisMonth: 0,
  subscriptionsUnpaid: 0,
);

/// The dashboard lays every card inside a horizontal padding of
/// AppSpacing.lg a side, so a card on a 390-point phone is 32 points narrower
/// than the screen. Testing the card against a bare width hid an overflow
/// that every iPhone under about 415 points showed at the default text size.
Future<void> _pump(
  WidgetTester tester,
  ModelState model, {
  int targetMonths = 24,
  double screenWidth = 390,
  double scale = 1.0,
  Locale locale = const Locale('en'),
  double? realMonthlyCost,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        monthlyBurnProvider.overrideWithValue(
          _burn(realMonthlyCost ?? model.effectiveBurnRate),
        ),
        runwayGoalProvider.overrideWith(
          () => _FixedGoal(
            RunwayGoal(
              id: 'demo-goal',
              name: 'Safety net',
              targetMonths: targetMonths,
            ),
          ),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(
          body: SizedBox(
            width: screenWidth,
            child: SingleChildScrollView(
              // Exactly what dashboard_screen.dart wraps every card in.
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: GoalCard(model: model),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the card says what the target is worth and what is left', (
    tester,
  ) async {
    await _pump(tester, _model());

    expect(find.text('Target cash'), findsOneWidget);
    expect(find.textContaining('67,272'), findsOneWidget);
    expect(find.text('Still to go'), findsOneWidget);
    expect(find.textContaining('32,936'), findsOneWidget);
  });

  testWidgets('the months line is cover to build, not time to wait', (
    tester,
  ) async {
    await _pump(tester, _model());
    expect(find.text('12 months of cover to build'), findsOneWidget);
  });

  testWidgets('a reached goal has a target but nothing left to go', (
    tester,
  ) async {
    await _pump(tester, _model(months: 30), targetMonths: 24);

    expect(find.text('Target cash'), findsOneWidget);
    expect(find.text('Still to go'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('with no monthly cost it states no cash at all', (tester) async {
    // A target times nothing is a confident zero for something nobody knows.
    await _pump(tester, _model(cost: 0));

    expect(find.text('Target cash'), findsNothing);
    expect(find.text('Still to go'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('it fits the phones people actually hold', (tester) async {
    for (final width in [320.0, 375.0, 390.0, 430.0]) {
      await _pump(tester, _model(), screenWidth: width);
      expect(
        tester.takeException(),
        isNull,
        reason: 'overflowed inside the dashboard padding at ${width}pt',
      );
    }
  });

  testWidgets('and with the text size turned up', (tester) async {
    await _pump(tester, _model(), screenWidth: 320, scale: 1.5);
    expect(tester.takeException(), isNull);
  });

  testWidgets('and in the longest language it ships', (tester) async {
    // French runs longest: "12 mois de couverture à constituer".
    await _pump(tester, _model(), screenWidth: 320, locale: const Locale('fr'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('what is still to go waits for a cash balance', (tester) async {
    // The target is months times cost and does not need a balance, so it
    // stands. What is left to save does, and currentCash is 0 while the
    // ledger has not loaded — which is not a balance anyone entered.
    await _pump(tester, _model(cash: 0, cashIsKnown: false));
    expect(find.text('Target cash'), findsOneWidget);
    expect(find.text('Still to go'), findsNothing);
  });

  testWidgets('the target does not follow a forecast assumption', (
    tester,
  ) async {
    // The target was targetMonths x model.totalMonthlyOutflow, which resolves
    // to the expected-cost override when the Forecast card has one. So typing
    // a guess three cards away silently rewrote a savings target: 12 months
    // against real costs of 2,803 asks for 33,636, and an assumption of 2,000
    // dropped it to 24,000 with nobody touching the goal.
    //
    // "Still to go" is money someone is actually setting aside. It follows
    // what a month costs, not what they wondered it might cost.
    await _pump(
      tester,
      // What the dashboard is running on: an assumption of 2,000.
      _model(cash: 0, cost: 2000),
      targetMonths: 12,
      // What a month really costs.
      realMonthlyCost: 2803,
    );

    expect(
      find.textContaining('33,636'),
      findsOneWidget,
      reason: '12 x 2,803 is the target; the guess does not decide it',
    );
    expect(
      find.textContaining('24,000'),
      findsNothing,
      reason: 'that figure is 12 x the assumption',
    );
    expect(
      find.textContaining('2,803'),
      findsOneWidget,
      reason: 'the arithmetic caption shows the cost it actually used',
    );
  });
}
