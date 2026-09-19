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
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
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
}
