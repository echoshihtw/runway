import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:presentation/features/boot/boot_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The core loop is "open the app, read one number", plausibly daily. Seven
/// lines of faux-terminal narration at 400 ms each stood between launch and
/// that number — 4.3 seconds in which nothing loaded (#117). A returning user
/// goes straight to the number; a first launch gets the wordmark, briefly.
Future<GoRouter> _pump(WidgetTester tester, {required bool onboardingDone}) async {
  SharedPreferences.setMockInitialValues({'onboarding_done': onboardingDone});
  final router = GoRouter(
    initialLocation: '/boot',
    routes: [
      GoRoute(path: '/boot', builder: (_, _) => const BootScreen()),
      GoRoute(path: '/dashboard', builder: (_, _) => const Text('DASHBOARD')),
      GoRoute(path: '/onboarding', builder: (_, _) => const Text('ONBOARDING')),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pump();
  return router;
}

void main() {
  testWidgets('a returning user is at the number within a frame or two', (
    tester,
  ) async {
    await _pump(tester, onboardingDone: true);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('DASHBOARD'), findsOneWidget,
        reason: 'nothing is loading, so nothing should wait');
    expect(find.textContaining('Separating essentials'), findsNothing);
  });

  testWidgets('a first launch holds the wordmark for about a second', (
    tester,
  ) async {
    await _pump(tester, onboardingDone: false);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('RUNWAY'), findsOneWidget, reason: 'the brand moment');
    expect(find.text('ONBOARDING'), findsNothing);

    await tester.pump(const Duration(milliseconds: 1500));
    // The timer fired inside that pump; the new route still needs a frame.
    await tester.pump();
    expect(find.text('ONBOARDING'), findsOneWidget,
        reason: 'well under the old 4.3 seconds');
  });

  testWidgets('the narration is gone from both paths', (tester) async {
    await _pump(tester, onboardingDone: false);
    await tester.pump(const Duration(milliseconds: 3000));

    for (final line in [
      'Checking your runway...',
      'Looking at what changes if income pauses...',
      'Counting the months your money covers...',
      'Separating essentials from noise...',
      'Your financial picture is ready.',
    ]) {
      expect(find.text(line), findsNothing, reason: line);
    }
  });
}
