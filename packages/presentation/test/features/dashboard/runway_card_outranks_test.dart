import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/dashboard/widgets/runway_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The most important card on the dashboard was also the plainest (#114).
/// Every card under it gets a solid border, a 3pt accent bar and a divider
/// beneath its title; the hero had a 1pt rim at alpha 40, so the hierarchy
/// rested on font size and nothing else.
const _model = ModelState(
  currentCash: 34336,
  burnRate: 2800,
  effectiveBurnRate: 2800,
  monthlyPayment: 0,
  subscriptionMonthlyCost: 0,
  runwayMonths: 12,
  runwayDays: 365,
  hasCostBasis: true,
);

Future<BoxDecoration> _decoration(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    const ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: RunwayCard(model: _model)),
      ),
    ),
  );
  await tester.pump();
  return tester
          .widget<Container>(
            find
                .descendant(
                  of: find.byType(RunwayCard),
                  matching: find.byType(Container),
                )
                .first,
          )
          .decoration!
      as BoxDecoration;
}

void main() {
  testWidgets('the hero rim outranks a subordinate card border', (
    tester,
  ) async {
    final side = (await _decoration(tester)).border!.top;

    expect(
      side.width,
      greaterThan(1),
      reason: 'a 1pt rim is what every card below the hero already has',
    );
    expect(
      side.color.a,
      greaterThan(0.5),
      reason:
          'at alpha 40 the rim of the most important card was the '
          'faintest line on the screen',
    );
    expect(
      side.color.r,
      SC.numberLife.r,
      reason:
          'the rim carries the status, which is what makes this the one '
          'card whose edge means something',
    );
  });

  testWidgets('the hero has room its children do not get', (tester) async {
    await _decoration(tester);

    final padding = tester
        .widget<Container>(
          find
              .descendant(
                of: find.byType(RunwayCard),
                matching: find.byType(Container),
              )
              .first,
        )
        .padding!
        .resolve(TextDirection.ltr);

    expect(
      padding.top,
      greaterThan(AppSpacing.cardPadding),
      reason: 'the 72pt figure needs air a subordinate card cannot spend',
    );
  });
}
