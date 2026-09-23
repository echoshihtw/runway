import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'widgets/this_month_card.dart';
import 'widgets/every_month_card.dart';
import 'widgets/goal_card.dart';
import 'widgets/runway_card.dart';
import 'widgets/getting_started_card.dart';
import 'widgets/review_prompt_trigger.dart';
import '../../shared/status_color.dart';
import '../config/config_screen.dart';
import '../loans/liabilities_panel.dart';
import '../subscriptions/subscriptions_panel.dart';
import '../subscriptions/widgets/subscription_prompt_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _showConfig(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
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
                  // Asks for an App Store rating at the right moment. Renders nothing.
                  const ReviewPromptTrigger(),
                  // Runway is always the hero, center-top (CONTRACTS.md §4.3).
                  RunwayCard(model: model),
                  const SizedBox(height: AppSpacing.cardGap),
                  // Adds its own bottom gap, and none once dismissed.
                  const GettingStartedCard(),
                  // Asks before any subscription charge is recorded.
                  const SubscriptionPromptCard(),
                  GoalCard(model: model),
                  const SizedBox(height: AppSpacing.cardGap),
                  // The income side, directly above the spending side, so the
                  // pair reads as what you expect each month and then what
                  // actually happened this one.
                  EveryMonthCard(
                    model: model,
                    onSetUp: () => _showConfig(context),
                  ),
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
          const RunwayBadge(),
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

/// The app mark, glowing with the runway's status.
///
/// Public only so the pulse can be tested on its own: the rate is the whole
/// point of it and nothing checked the rate, which is how it shipped inert.
class RunwayBadge extends ConsumerStatefulWidget {
  const RunwayBadge({super.key});

  @override
  ConsumerState<RunwayBadge> createState() => RunwayBadgeState();
}

class RunwayBadgeState extends ConsumerState<RunwayBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curve;

  /// The band the ticker is currently running for, so a change can restart it.
  RunwayStatus? _band;

  /// How fast and how deep the badge breathes. Rate and depth carry the same
  /// meaning, so the state reads without being explained.
  ///
  /// Critical is 1100 ms, about a resting heart rate. The first draft used
  /// 650 ms, nearer ninety beats a minute, which is uncomfortable to sit with
  /// on a screen somebody opens when they are already worried. It is the same
  /// restraint that removed the rank labels: the owner of a one-month runway
  /// knows, and the app's job is to be honest rather than to press on it.
  static ({Duration period, double low, double high}) _pulseFor(
    RunwayStatus s,
  ) => switch (s) {
    RunwayStatus.stable => (
      period: const Duration(milliseconds: 2800),
      low: 0.10,
      high: 0.32,
    ),
    RunwayStatus.caution => (
      period: const Duration(milliseconds: 1700),
      low: 0.10,
      high: 0.42,
    ),
    RunwayStatus.critical => (
      period: const Duration(milliseconds: 1100),
      low: 0.10,
      high: 0.55,
    ),
  };

  @override
  void initState() {
    super.initState();
    // Not started here. build decides whether there is anything to say, and
    // at what rate, and starting at a guessed period is what hid the bug.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(modelProvider);
    final known = model.runwayIsKnown;
    final status = model.runwayStatus;

    // An empty ledger has runwayMonths 0, which the status switch reads as
    // critical. Taking that colour meant a fresh install glowed pink before
    // the owner had typed anything, beside a card correctly showing an em
    // dash. The card's rule applies here too: with no runway to state, the
    // badge must not borrow the confidence of a status colour.
    final color = known ? statusColor(status) : SC.unknown;

    // Nothing to signal, or the owner asked for less motion. Hold still, and
    // stop the ticker rather than leave it advancing a value nobody draws —
    // that cost fell on exactly the people who asked for less motion.
    if (!known || MediaQuery.disableAnimationsOf(context)) {
      if (_controller.isAnimating) _controller.stop();
      _band = null;
      return _BadgeFrame(glow: 0.18, color: color);
    }

    final pulse = _pulseFor(status);
    // repeat() bakes its period into the simulation when it starts, so the
    // later write to `duration` was inert and every band pulsed at the calm
    // rate. Restarting is the only thing that changes it.
    if (_band != status || !_controller.isAnimating) {
      _band = status;
      _controller
        ..stop()
        ..repeat(reverse: true, period: pulse.period);
    }

    return AnimatedBuilder(
      animation: _curve,
      builder: (_, _) => _BadgeFrame(
        glow: pulse.low + (pulse.high - pulse.low) * _curve.value,
        color: color,
      ),
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
