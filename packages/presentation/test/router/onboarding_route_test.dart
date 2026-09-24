import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:presentation/features/onboarding/onboarding_screen.dart';
import 'package:presentation/router/app_router.dart';

/// Onboarding used to be pushed onto the navigator with `pushReplacement`
/// while go_router's match list still held only `/boot`. An iOS back swipe
/// then popped a page go_router did not own, emptying `currentConfiguration`
/// and tripping an assertion. It has to stay a route it owns.
void main() {
  test('onboarding is a route in the table', () {
    final paths = appRouter.configuration.routes
        .whereType<GoRoute>()
        .map((route) => route.path)
        .toList();

    expect(paths, contains('/onboarding'));
  });

  test('boot screen never pushes onboarding imperatively', () {
    // Source guard: the declarative route is the only way in.
    final source = File(
      'lib/features/boot/boot_screen.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('pushReplacement')));
    expect(source, contains("context.go("));
  });

  testWidgets('onboarding renders as a route without an owning push', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (_, _) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (_, _) => const Placeholder(),
        ),
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
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    // The page cannot be popped away, so no swipe can empty the stack.
    expect(router.routerDelegate.currentConfiguration, isNotEmpty);
    expect(tester.takeException(), isNull);
  });
}
