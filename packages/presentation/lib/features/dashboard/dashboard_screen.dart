import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'widgets/this_month_card.dart';
import 'widgets/goal_card.dart';
import 'widgets/runway_card.dart';
import 'widgets/getting_started_card.dart';
import '../config/config_screen.dart';
import '../loans/liabilities_panel.dart';
import '../subscriptions/subscriptions_panel.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _showConfig(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final media = MediaQuery.of(ctx);
        final topGap = media.padding.top + 8;
        return Padding(
          padding: EdgeInsets.only(top: topGap),
          child: SizedBox(
            height: media.size.height - topGap,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.cardRadius),
                ),
              ),
              child: const ConfigScreen(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(modelProvider);

    return GradientScaffold(
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          bottom: AppSpacing.xxxl + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          children: [
            _DashboardHeader(onConfig: () => _showConfig(context)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  // Runway is always the hero, center-top (CONTRACTS.md §4.3).
                  RunwayCard(model: model),
                  const SizedBox(height: AppSpacing.cardGap),
                  // Adds its own bottom gap, and none once dismissed.
                  const GettingStartedCard(),
                  GoalCard(model: model),
                  const SizedBox(height: AppSpacing.cardGap),
                  const ThisMonthCard(),
                  const SizedBox(height: AppSpacing.cardGap),
                  const LiabilitiesPanel(),
                  const SizedBox(height: AppSpacing.cardGap),
                  const SubscriptionsPanel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final VoidCallback onConfig;
  const _DashboardHeader({required this.onConfig});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _RunwayBadge(),
          const SizedBox(width: AppSpacing.sm),
          const Spacer(),
          GestureDetector(
            onTap: onConfig,
            child: const Icon(
              Icons.tune_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _RunwayBadge extends ConsumerStatefulWidget {
  const _RunwayBadge();

  @override
  ConsumerState<_RunwayBadge> createState() => _RunwayBadgeState();
}

class _RunwayBadgeState extends ConsumerState<_RunwayBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glow;

  static Duration _durationFor(SurvivalStatus s) => switch (s) {
    SurvivalStatus.stable   => const Duration(milliseconds: 2800),
    SurvivalStatus.caution  => const Duration(milliseconds: 1400),
    SurvivalStatus.critical => const Duration(milliseconds: 650),
  };

  static Color _colorFor(SurvivalStatus s) => switch (s) {
    SurvivalStatus.stable   => AppColors.neonGreen,
    SurvivalStatus.caution  => AppColors.gold,
    SurvivalStatus.critical => AppColors.red,
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.10, end: 0.45).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(modelProvider).survivalStatus;
    final targetDuration = _durationFor(status);
    if (_controller.duration != targetDuration) {
      _controller.duration = targetDuration;
    }
    final color = _colorFor(status);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations) return _BadgeFrame(glow: 0.18, color: color);
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, __) => _BadgeFrame(glow: _glow.value, color: color),
    );
  }
}

class _BadgeFrame extends StatelessWidget {
  final double glow;
  final Color color;
  const _BadgeFrame({required this.glow, required this.color});

  @override
  Widget build(BuildContext context) {
    final glowAlpha = (glow * 255).round();
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(80), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(glowAlpha),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/brand/runway-icon-1024.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
