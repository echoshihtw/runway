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
  testWidgets('onboarding is one screen: the promise, the price, the ask', (
    tester,
  ) async {
    await _pumpOnboarding(tester);

    // No baked line break: at 36pt mono "Stop guessing how long" does not fit,
    // so the \n after "long" wrapped and then broke, orphaning the word.
    expect(
      find.text('Stop guessing how long your money lasts.'),
      findsOneWidget,
    );
    expect(
      find.text('Enter your cash. That is the whole setup.'),
      findsOneWidget,
      reason: 'the ask is on the same screen as the promise now',
    );
    expect(find.text('CASH'), findsOneWidget);
    expect(find.text('RUNWAY'), findsOneWidget);
    expect(find.text('ADD MY BALANCE'), findsOneWidget);
    expect(find.text('SKIP'), findsOneWidget);
  });

  testWidgets('it keeps the two claims that decide whether to type a balance', (
    tester,
  ) async {
    await _pumpOnboarding(tester);

    expect(find.text('No account. No bank connection.'), findsOneWidget);
    expect(find.text('Encrypted on device'), findsOneWidget);
  });

  testWidgets('the pages it replaced are gone, and so are their buttons', (
    tester,
  ) async {
    await _pumpOnboarding(tester);

    for (final gone in const [
      'Your data,\nyour device.',
      'One number and\nyou are set up.',
      'Stop guessing how long\nyour money lasts.',
      'There is no server, so there is nothing to leak.',
      'Numbers stay on your device',
      'Hidden when you switch apps',
      'Delete anytime',
      'GET STARTED',
      'I UNDERSTAND',
      'Three steps\nto clarity.',
      'Lock it\ndown.',
    ]) {
      expect(find.text(gone), findsNothing, reason: '$gone should be gone');
    }
  });

  testWidgets('the first run speaks the device language, not English', (
    tester,
  ) async {
    await _pumpOnboarding(tester, locale: const Locale('ja'));

    expect(find.text('ADD MY BALANCE'), findsNothing);
    expect(find.text('SKIP'), findsNothing);
    expect(find.text('スキップ'), findsOneWidget);
    expect(find.text('残高を入力'), findsOneWidget);
  });
}
