import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:presentation/features/onboarding/onboarding_screen.dart';
import 'package:presentation/router/page_indicator.dart';

/// Reduce Motion was honoured in one place in the whole app — the runway
/// badge — while eleven other animations ignored it (#113).
///
/// The rule is not "no movement". Motion the viewer did not start stops;
/// motion bounded by their finger stays. These check both directions.
Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  required bool reduced,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Scaffold(body: child),
      ),
    ),
  );
  await tester.pump();
}

Duration _dotDuration(WidgetTester tester) => tester
    .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
    .first
    .duration;

void main() {
  testWidgets('unprompted motion takes no time when the system asks', (
    tester,
  ) async {
    late Duration reduced;
    late Duration normal;

    Widget probe(void Function(Duration) sink) => Builder(
      builder: (context) {
        sink(AppMotion.unprompted(context, const Duration(milliseconds: 350)));
        return const SizedBox.shrink();
      },
    );

    await _pump(tester, probe((d) => reduced = d), reduced: true);
    await _pump(tester, probe((d) => normal = d), reduced: false);

    expect(reduced, Duration.zero);
    expect(
      normal,
      const Duration(milliseconds: 350),
      reason: 'the setting is off, so nothing changes',
    );
  });

  testWidgets('the page indicator stretches its dot instantly', (tester) async {
    // Nobody touched this dot. It widens because the page changed, which is
    // exactly the motion the setting exists to stop.
    await _pump(
      tester,
      PageIndicator(currentIndex: 0, onSelect: (_) {}),
      reduced: true,
    );
    expect(_dotDuration(tester), Duration.zero);
  });

  testWidgets('and animates it normally otherwise', (tester) async {
    await _pump(
      tester,
      PageIndicator(currentIndex: 0, onSelect: (_) {}),
      reduced: false,
    );
    expect(_dotDuration(tester), const Duration(milliseconds: 250));
  });

  testWidgets('onboarding pages arrive rather than travel', (tester) async {
    // A whole screen of content moving sideways is the textbook vestibular
    // trigger, and it is the first thing a new user ever sees.
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    Future<void> open({required bool reduced}) => tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reduced),
            child: const OnboardingScreen(),
          ),
        ),
      ),
    );

    await open(reduced: true);
    await tester.pumpAndSettle();
    await tester.tap(find.text('GET STARTED'));
    // One frame. With a 350ms slide the second page would still be in
    // flight; jumped, it is already here.
    await tester.pump();
    expect(find.text('Your data,\nyour device.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await open(reduced: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('GET STARTED'));
    await tester.pump();
    expect(
      find.text('Stop guessing how long\nyour money lasts.'),
      findsOneWidget,
      reason: 'the setting is off, so the first page is still sliding away',
    );
    await tester.pumpAndSettle();
  });
}
