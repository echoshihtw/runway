import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/dashboard/widgets/runway_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cash was mint whenever it was known, whatever its sign. An overdrawn
/// balance therefore appeared in the colour the app uses for cash and runway,
/// which reads as "you are fine" at the moment that is least true.
ModelState _model(double cash) => ModelState(
  currentCash: cash,
  burnRate: 2000,
  effectiveBurnRate: 2000,
  monthlyPayment: 0,
  subscriptionMonthlyCost: 0,
  runwayMonths: cash <= 0 ? 0 : 2,
  runwayDays: cash <= 0 ? 0 : 60,
  hasCostBasis: true,
);

Future<void> _pump(WidgetTester tester, double cash) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: RunwayCard(model: _model(cash))),
      ),
    ),
  );
  await tester.pump();
}

Color? _colourOf(WidgetTester tester, String fragment) => tester
    .widget<Text>(
      find.byWidgetPredicate(
        (w) => w is Text && (w.data ?? '').contains(fragment),
      ),
    )
    .style
    ?.color;

void main() {
  testWidgets('an overdrawn balance is a cost, not life', (tester) async {
    await _pump(tester, -1200);

    expect(_colourOf(tester, '-1,200'), SC.numberCost);
  });

  testWidgets('a positive balance stays the cash colour', (tester) async {
    await _pump(tester, 4200);

    expect(_colourOf(tester, '4,200'), SC.numberLife);
  });
}
