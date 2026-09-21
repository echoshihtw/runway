import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:intl/intl.dart';
import 'package:domain/domain.dart';
import 'package:application/application.dart';

class GoalCard extends ConsumerWidget {
  const GoalCard({super.key, required this.model});

  final ModelState model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(runwayGoalProvider).value;
    if (goal == null) return const SizedBox.shrink();

    final l10n = context.l10n;
    final runway = model.runwayMonths.toDouble();
    final progress = calculateRunwayGoalProgress(
      runwayMonths: runway,
      targetMonths: goal.targetMonths,
    );
    final percent = calculateRunwayGoalProgressPercent(
      runwayMonths: runway,
      targetMonths: goal.targetMonths,
    );
    final achieved = progress >= 1.0;
    final color = achieved ? SC.life : SC.accentCost;
    final monthsLeft = (goal.targetMonths - runway.floor()).clamp(0, 9999);

    // A target in months is also a sum of cash, and the card never said how
    // much, so the unfilled half of the bar had no size anybody could act on.
    // Both are null when a month costs nothing, which is unknowable rather
    // than zero — the same reason the runway itself reads as unknown without
    // a cost basis.
    final symbol = ref.watch(currencyProvider).value?.symbol ?? '¥';
    final nf = NumberFormat('#,##0', 'en_US');
    final cashTarget = runwayGoalCashTarget(
      targetMonths: goal.targetMonths,
      monthlyCost: model.totalMonthlyOutflow,
    );
    // What is still to go is measured against the cash on hand, so it cannot
    // be stated while the ledger has not loaded: currentCash is 0 then, and
    // the card would print a confident figure directly beneath a runway card
    // correctly showing cash as unknown.
    final cashToGo = model.cashIsKnown
        ? runwayGoalCashToGo(
            targetMonths: goal.targetMonths,
            monthlyCost: model.totalMonthlyOutflow,
            currentCash: model.currentCash,
          )
        : null;
    String money(double v) => '$symbol ${nf.format(v)}';

    final summary = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                goal.name.toUpperCase(),
                style: AppTextStyles.body.copyWith(color: SC.numberPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${model.runwayMonths} / ${goal.targetMonths} mo',
              style: AppTextStyles.metricSmall.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        PixelBar(
          value: progress,
          color: color,
          segments: goal.targetMonths.clamp(4, 36),
          height: 5,
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // The caption is the long side and the only one that can yield:
            // "12 months of cover to build" needs 304 points where "12 months
            // to go" needed 169, and the card is 32 points narrower than the
            // screen. Unbounded, it overflowed on every iPhone below about
            // 415 points at the default text size, in English.
            Flexible(
              child: Text(
                achieved ? l10n.goalReached : l10n.monthsToGoal(monthsLeft),
                style: AppTextStyles.caption.copyWith(color: color),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$percent%',
              style: AppTextStyles.caption.copyWith(color: SC.captionColor),
            ),
          ],
        ),
        if (cashTarget != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _CashRow(label: l10n.goalCashTarget, value: money(cashTarget)),
          // The target is the goal in months times the monthly cost, and
          // nobody typed it. Unstated, an unround figure nobody entered
          // reads as arbitrary — so the card shows its own arithmetic, the
          // way the budget card in settings does.
          const SizedBox(height: AppSpacing.xxs),
          Text(
            l10n.goalCashTargetFrom(
              goal.targetMonths,
              money(model.totalMonthlyOutflow),
            ),
            style: AppTextStyles.caption,
          ),
          if (!achieved && cashToGo != null && cashToGo > 0) ...[
            const SizedBox(height: AppSpacing.xxs),
            _CashRow(
              label: l10n.goalCashToGo,
              value: money(cashToGo),
              color: color,
            ),
          ],
        ],
      ],
    );

    return NeoExpandableCard(
      title: l10n.goal,
      accentColor: color,
      summary: summary,
    );
  }
}

class _CashRow extends StatelessWidget {
  const _CashRow({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    // Both sides yield: the label is long in several languages and the value
    // can be eight digits, and the card is read at 400 points.
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // The label yields, the amount does not. Two Flexibles each capped at
        // half the row cut the money figure mid-number at large text sizes,
        // and a truncated amount is worse than a truncated word for it.
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          value,
          style: AppTextStyles.metricCaption.copyWith(
            color: color ?? SC.numberPrimary,
          ),
          textAlign: TextAlign.right,
          maxLines: 1,
        ),
      ],
    );
  }
}
