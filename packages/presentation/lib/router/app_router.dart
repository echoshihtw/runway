import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:design_system/design_system.dart';
import '../features/boot/boot_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/transactions/transactions_screen.dart';
import '../features/scenarios/scenarios_screen.dart';
import 'page_indicator.dart';

// Global keys for coach mark tour

final appRouter = GoRouter(
  initialLocation: '/boot',
  routes: [
    GoRoute(path: '/boot', builder: (_, __) => const BootScreen()),
    // A route, not an imperative push. Pushing it onto the navigator left
    // go_router's match list holding only /boot, so the iOS back swipe popped
    // a page go_router did not own and emptied the configuration.
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _ScaffoldWithNav(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (_, __) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/transactions',
              builder: (_, __) => const TransactionsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/scenarios',
              builder: (_, __) => const ScenariosScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class _ScaffoldWithNav extends ConsumerStatefulWidget {
  final StatefulNavigationShell shell;
  const _ScaffoldWithNav({required this.shell});

  @override
  ConsumerState<_ScaffoldWithNav> createState() => _ScaffoldWithNavState();
}

class _ScaffoldWithNavState extends ConsumerState<_ScaffoldWithNav> {
  void _onHorizontalDragEnd(DragEndDetails details) {
    final v = details.primaryVelocity ?? 0;
    final i = widget.shell.currentIndex;
    // Higher threshold on Android to avoid conflict with system back gesture
    final threshold = Platform.isAndroid ? 800.0 : 500.0;
    if (v < -threshold && i < 2) widget.shell.goBranch(i + 1);
    if (v > threshold && i > 0) widget.shell.goBranch(i - 1);
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final currentIndex = widget.shell.currentIndex;

    return Scaffold(
      backgroundColor: SC.pageGround,
      body: GestureDetector(
        onHorizontalDragEnd: _onHorizontalDragEnd,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            widget.shell,

            // Swipe-up zone — sits above the system safe area so it
            // clears Android's home-gesture zone and iOS home indicator
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomSafe,
              height: 64,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),

            // Labelled page indicator: tap a label or swipe. The scrim fades
            // the page into the background colour behind it. The indicator
            // floats over scrolling content, so without one its labels land on
            // top of whatever happens to be there — on the dashboard at rest,
            // the liabilities figures, which read as a collision rather than a
            // layer. The labels stay where they were: the safe-area inset moves
            // from the Positioned to the padding inside it.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [SC.pageGround.withAlpha(0), SC.pageGround],
                    stops: const [0, 0.55],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: AppSpacing.xxxl,
                    bottom: bottomSafe,
                  ),
                  child: PageIndicator(
                    currentIndex: currentIndex,
                    onSelect: widget.shell.goBranch,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
