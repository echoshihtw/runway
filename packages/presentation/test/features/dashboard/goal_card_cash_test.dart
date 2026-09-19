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

ModelState _model({double cash = 34336, double cost = 2803, int months = 12}) =>
    ModelState(
      currentCash: cash,
      burnRate: cost,
      effectiveBurnRate: cost,
      monthlyPayment: 0,
      subscriptionMonthlyCost: 0,
      runwayMonths: months,
      runwayDays: months * 30,
    );

Future<void> _pump(
  WidgetTester tester,
  ModelState model, {
  int targetMonths = 24,
  double width = 400,
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
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: width,
            child: SingleChildScrollView(child: GoalCard(model: model)),
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

  testWidgets('it fits 400 points', (tester) async {
    await _pump(tester, _model());
    expect(tester.takeException(), isNull);
  });
}
