import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The first screen anyone sees, at the smallest size anyone sees it on. The
/// headline is set at 36pt in a fixed Column with no scroll view, so a longer
/// line or a larger text setting has nowhere to go.
Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  required double scale,
  Locale locale = const Locale('en'),
}) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
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
        home: const OnboardingScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the welcome screen fits a small phone', (tester) async {
    await _pump(tester, size: const Size(320, 568), scale: 1.0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('and fits it with the text size turned up', (tester) async {
    await _pump(tester, size: const Size(320, 568), scale: 1.5);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the button still sits at the bottom when there is room', (
    tester,
  ) async {
    // Making the page scroll must not float the call to action up under the
    // text on a screen that has plenty of space.
    await _pump(tester, size: const Size(390, 844), scale: 1.0);

    final button = tester.getRect(find.byType(NeoButton));
    expect(tester.takeException(), isNull);
    expect(
      button.bottom,
      greaterThan(700),
      reason: 'pinned low, not floated up under the subtitle',
    );
  });

  testWidgets('and in the longest language it ships', (tester) async {
    // French runs longest of the seven.
    await _pump(
      tester,
      size: const Size(320, 568),
      scale: 1.0,
      locale: const Locale('fr'),
    );
    expect(tester.takeException(), isNull);
  });
}
