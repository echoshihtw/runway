import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/features/onboarding/onboarding_screen.dart';

Future<void> _pumpOnboarding(WidgetTester tester, {Locale? locale}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const OnboardingScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('onboarding is welcome, privacy, then first action', (
    tester,
  ) async {
    await _pumpOnboarding(tester);
    expect(
      find.text('Stop guessing how long\nyour money lasts.'),
      findsOneWidget,
    );

    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();
    expect(find.text('Your data,\nyour device.'), findsOneWidget);

    await tester.tap(find.text('I UNDERSTAND'));
    await tester.pumpAndSettle();
    expect(find.text('One number and\nyou are set up.'), findsOneWidget);
    expect(find.text('ADD MY BALANCE'), findsOneWidget);
    expect(find.text('SKIP'), findsNothing);
  });

  testWidgets('the privacy page carries every privacy promise', (tester) async {
    await _pumpOnboarding(tester);
    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();

    expect(find.text('Encrypted on device'), findsOneWidget);
    expect(find.text('Numbers stay on your device'), findsOneWidget);
    expect(find.text('Hidden when you switch apps'), findsOneWidget);
    expect(find.text('Delete anytime'), findsOneWidget);
    expect(find.text('Never sent to servers'), findsNothing);
  });

  testWidgets('the removed pages are gone', (tester) async {
    await _pumpOnboarding(tester);

    for (final cta in ['GET STARTED', 'I UNDERSTAND']) {
      await tester.tap(find.text(cta));
      await tester.pumpAndSettle();
      expect(find.text('Three steps\nto clarity.'), findsNothing);
      expect(find.text('Lock it\ndown.'), findsNothing);
    }
  });

  testWidgets('the first run speaks the device language, not English', (
    tester,
  ) async {
    // #96: every title, body, bullet and button was a Dart literal, so a
    // phone set to 日本語 met an English first run. The paywall's legal links
    // were the only strings on either judged screen that translated.
    await _pumpOnboarding(tester, locale: const Locale('ja'));

    expect(find.text('GET STARTED'), findsNothing);
    expect(find.text('SKIP'), findsNothing);
    expect(find.text('はじめる'), findsOneWidget);
    expect(find.text('スキップ'), findsOneWidget);

    await tester.tap(find.text('はじめる'));
    await tester.pumpAndSettle();
    expect(find.text('Encrypted on device'), findsNothing);
    expect(find.text('端末内で暗号化'), findsOneWidget);
  });
}
