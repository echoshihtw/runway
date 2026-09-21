import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/dashboard/dashboard_screen.dart';

/// The badge is meant to breathe slowly on a long runway and quicken as it
/// shortens, and the Design Award submission says so. It did not: `repeat()`
/// bakes its period in when it starts, so the later write to `duration` was
/// inert and every band pulsed at the calm rate. Nothing tested the rate,
/// which is how it shipped.
///
/// Lives in `app/` because the badge draws the launcher icon, and the asset
/// bundle that resolves it belongs to this package.
ModelState _model({required double cash, required double burn}) => ModelState(
  currentCash: cash,
  burnRate: burn,
  effectiveBurnRate: burn,
  monthlyPayment: 0,
  subscriptionMonthlyCost: 0,
  runwayMonths: burn <= 0 ? 0 : (cash / burn).floor(),
  runwayDays: 0,
  hasCostBasis: burn > 0,
);

Future<void> _pump(
  WidgetTester tester,
  ModelState state, {
  bool reduceMotion = false,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [modelProvider.overrideWithValue(state)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: const Scaffold(body: Center(child: RunwayBadge())),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// The alpha of the badge's glow, which is what the pulse animates.
double _glow(WidgetTester tester) {
  final box = tester.widget<Container>(find.byType(Container));
  final shadow = (box.decoration! as BoxDecoration).boxShadow!.single;
  return shadow.color.a;
}

Color _border(WidgetTester tester) {
  final box = tester.widget<Container>(find.byType(Container));
  return (box.decoration! as BoxDecoration).border!.top.color;
}

void main() {
  testWidgets('a short runway pulses faster than a long one', (tester) async {
    // Half of critical's 1100ms period, so it is at its brightest, while
    // stable is a third of the way into a 2800ms one.
    const halfOfCritical = Duration(milliseconds: 550);

    await _pump(tester, _model(cash: 1000, burn: 1000)); // 1 month, critical
    await tester.pump(halfOfCritical);
    final critical = _glow(tester);

    // A fresh mount, or the element is reused and the controller keeps the
    // position it reached on the critical badge.
    await tester.pumpWidget(const SizedBox.shrink());
    await _pump(tester, _model(cash: 24000, burn: 2000)); // 12 months, stable
    await tester.pump(halfOfCritical);
    final stable = _glow(tester);

    expect(
      critical,
      greaterThan(stable + 0.15),
      reason: 'both bands were pulsing at the same rate and depth',
    );
  });

  testWidgets('with no runway to state it holds still, and stays neutral', (
    tester,
  ) async {
    // An empty ledger reads as critical months, so the colour has to come
    // from whether the runway is known, not from the band.
    await _pump(tester, _model(cash: 0, burn: 0));

    expect(_border(tester), AppColors.textSecondary.withAlpha(80));
    expect(
      tester.binding.transientCallbackCount,
      0,
      reason: 'the ticker is running with nothing to say',
    );
  });

  testWidgets('reduce motion stops the ticker, not just the repaint', (
    tester,
  ) async {
    await _pump(tester, _model(cash: 1000, burn: 1000), reduceMotion: true);

    expect(
      tester.binding.transientCallbackCount,
      0,
      reason: 'animating a value nobody draws, on the setting that asked for '
          'less motion',
    );
  });
}
