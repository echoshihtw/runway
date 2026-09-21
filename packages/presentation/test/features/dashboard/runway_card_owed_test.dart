import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/dashboard/widgets/runway_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Borrowing is an inflow. It raises cash and the runway with it, and the
/// card showed only that half: a $18,000 loan took the headline from 7 months
/// to 12 with STABLE still on the badge and the debt nowhere on screen (#202).
ModelState _model() => ModelState(
  currentCash: 34336,
  burnRate: 2800,
  effectiveBurnRate: 2800,
  monthlyPayment: 210,
  subscriptionMonthlyCost: 0,
  runwayMonths: 12,
  runwayDays: 365,
  hasCostBasis: true,
  runOutDate: DateTime(2027, 9, 1),
);

Future<void> _pump(WidgetTester tester, double owed) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [totalOwedProvider.overrideWithValue(owed)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: RunwayCard(model: _model())),
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
  testWidgets('what is owed sits beside the cash it was borrowed into', (
    tester,
  ) async {
    await _pump(tester, 12400);

    expect(find.text('OWED'), findsOneWidget);
    expect(find.textContaining('12,400'), findsOneWidget);

    // Beside, not below: the two balances share a row so the borrow and the
    // debt it created are read in one glance.
    final cash = tester.getCenter(find.text('CASH'));
    final owed = tester.getCenter(find.text('OWED'));
    expect(owed.dy, cash.dy, reason: 'OWED belongs on the CASH row');
    expect(owed.dx, greaterThan(cash.dx));
  });

  testWidgets('the run-out date explains the number it restates', (
    tester,
  ) async {
    // Twelve months from today is a date. As a stat it read as a third
    // independent fact beside two balances, and centred itself under the gap
    // between them, lining up with neither.
    await _pump(tester, 12400);

    expect(find.text('RUN OUT'), findsNothing);
    final date = find.textContaining('Runs out');
    expect(date, findsOneWidget);

    // Above the divider, with the basis line it belongs to — not below it
    // with the balances.
    expect(
      tester.getCenter(date).dy,
      lessThan(tester.getCenter(find.text('CASH')).dy),
      reason: 'the date sits with the number it restates',
    );
  });

  testWidgets('debt is gold, so it is never mistaken for cash', (tester) async {
    // Nothing invites subtracting one from the other: gold is debt's colour
    // throughout the app and mint is cash's, so the pair reads as two facts.
    await _pump(tester, 12400);

    expect(_colourOf(tester, '12,400'), SC.accentCost);
    expect(_colourOf(tester, '34,336'), SC.numberLife);
  });

  testWidgets('with nothing borrowed the card is unchanged', (tester) async {
    // A row reading "$ 0" would be a liability the owner does not have.
    await _pump(tester, 0);

    expect(find.text('OWED'), findsNothing);

    // The row holds balances, and there is one. A second reading $ 0 would
    // be a liability the owner does not have.
    expect(find.textContaining('Runs out'), findsOneWidget);
  });
}
