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
    final cashToGo = runwayGoalCashToGo(
      targetMonths: goal.targetMonths,
      monthlyCost: model.totalMonthlyOutflow,
      currentCash: model.currentCash,
    );
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
                style: AppTextStyles.body.copyWith(
                  color: SC.numberPrimary,
                ),
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
            Text(
              achieved ? l10n.goalReached : l10n.monthsToGoal(monthsLeft),
              style: AppTextStyles.caption.copyWith(color: color),
            ),
            Text(
              '$percent%',
              style: AppTextStyles.caption.copyWith(color: SC.captionColor),
            ),
          ],
        ),
        if (cashTarget != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _CashRow(label: l10n.goalCashTarget, value: money(cashTarget)),
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
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.metricCaption.copyWith(
              color: color ?? SC.numberPrimary,
            ),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
