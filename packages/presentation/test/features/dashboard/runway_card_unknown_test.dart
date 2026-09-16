import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/dashboard/widgets/runway_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Entering only a cash balance — exactly what onboarding instructs — gave a
/// monthly cost of zero, which the engine turned into an unlimited runway. The
/// card printed the infinity glyph and a mint STABLE badge, telling a new user
/// their money lasts for ever.
ModelState model({required bool hasCostBasis, int runwayMonths = 9999}) =>
    ModelState(
      currentCash: 34000,
      burnRate: 0,
      effectiveBurnRate: 0,
      monthlyPayment: 0,
      subscriptionMonthlyCost: 0,
      runwayMonths: runwayMonths,
      runwayDays: runwayMonths * 30,
      hasCostBasis: hasCostBasis,
    );

Future<void> pumpCard(WidgetTester tester, ModelState state) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: RunwayCard(model: state)),
      ),
    ),
  );
  await tester.pump();
}

/// The RUN OUT stat renders its own em dash when there is no date, so the
/// number has to be read off the 72pt hero rather than found anywhere on card.
String heroText(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .firstWhere((t) => t.style?.fontSize == 72)
    .data!;

void main() {
  testWidgets('with no cost known the number is withheld', (tester) async {
    await pumpCard(tester, model(hasCostBasis: false));

    expect(heroText(tester), '—');
    expect(find.text('∞'), findsNothing);
    expect(find.text('Set your monthly costs to see your runway'), findsOneWidget);
    // No status may be claimed about a number that is not known.
    expect(find.byType(PixelBadge), findsNothing);
    expect(find.text('STABLE'), findsNothing);
  });

  testWidgets('a known runway still states itself and its status', (
    tester,
  ) async {
    await pumpCard(tester, model(hasCostBasis: true, runwayMonths: 12));

    expect(heroText(tester), '12');
    expect(find.text('If income paused today'), findsOneWidget);
    expect(find.byType(PixelBadge), findsOneWidget);
  });

  testWidgets('a genuinely unlimited runway keeps the infinity glyph', (
    tester,
  ) async {
    await pumpCard(tester, model(hasCostBasis: true));

    expect(heroText(tester), '∞');
    expect(find.byType(PixelBadge), findsOneWidget);
  });
}
