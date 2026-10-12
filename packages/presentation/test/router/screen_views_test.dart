import 'package:application/application.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:presentation/router/app_router.dart';

class _Analytics extends NoOpAnalytics {
  final screens = <String>[];

  @override
  Future<void> logScreen(String name) async => screens.add(name);
}

void main() {
  testWidgets('every move between screens and tabs is one screen view', (
    tester,
  ) async {
    // The tabs are a StatefulShellRoute: going back to a tab already built
    // pushes no route, so a NavigatorObserver would miss it.
    late StatefulNavigationShell shell;
    final router = GoRouter(
      initialLocation: '/start',
      routes: [
        GoRoute(path: '/start', builder: (_, _) => const Text('start')),
        StatefulShellRoute.indexedStack(
          builder: (_, _, s) => shell = s,
          branches: [
            StatefulShellBranch(
              routes: [GoRoute(path: '/a', builder: (_, _) => const Text('a'))],
            ),
            StatefulShellBranch(
              routes: [GoRoute(path: '/b', builder: (_, _) => const Text('b'))],
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    final analytics = _Analytics();
    reportScreenViews(router, analytics);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    router.go('/a');
    await tester.pumpAndSettle();
    shell.goBranch(1);
    await tester.pumpAndSettle();
    shell.goBranch(0);
    await tester.pumpAndSettle();
    // Rebuilding on the same screen is not a new view.
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(analytics.screens, ['/start', '/a', '/b', '/a']);
  });

  test('the app logs route paths, never anything a user typed', () {
    // A path parameter would put a value in the screen name.
    final paths = <String>[];
    void collect(List<RouteBase> routes) {
      for (final route in routes) {
        if (route is GoRoute) paths.add(route.path);
        collect(route.routes);
      }
    }

    collect(appRouter.configuration.routes);
    expect(paths, isNotEmpty);
    expect(paths.where((p) => p.contains(':')), isEmpty);
  });
}
