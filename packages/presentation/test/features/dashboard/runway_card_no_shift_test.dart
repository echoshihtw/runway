import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/dashboard/widgets/runway_card.dart';

/// The run out line holds its height before there is a month to name, so
/// entering a balance does not add a line to the card. The status badge still
/// mounts on the same transition, so the card does grow, by that much and no
/// more.
ModelState _model({required bool stated}) => ModelState(
  currentCash: stated ? 600000 : 0,
  burnRate: 50000,
  effectiveBurnRate: 50000,
  monthlyPayment: 0,
  subscriptionMonthlyCost: 0,
  runwayMonths: stated ? 12 : 0,
  runwayDays: stated ? 360 : 0,
  runOutMonth: DateTime(2027, 9, 1),
  cashIsStated: stated,
);

Future<void> _pump(WidgetTester tester, {required bool stated}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: RunwayCard(model: _model(stated: stated)),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _runOutLine() => find.byKey(const Key('run-out-line'));

void main() {
  testWidgets('the run out line keeps its place before a balance is entered', (
    tester,
  ) async {
    await _pump(tester, stated: false);
    expect(_runOutLine(), findsOneWidget, reason: 'still drawn, so no shift');
    expect(
      tester.widget<Text>(_runOutLine()).data,
      isEmpty,
      reason: 'there is no month to name yet',
    );
  });

  testWidgets('and names the month once there is one', (tester) async {
    await _pump(tester, stated: true);
    expect(tester.widget<Text>(_runOutLine()).data, contains('2027'));
  });
}
