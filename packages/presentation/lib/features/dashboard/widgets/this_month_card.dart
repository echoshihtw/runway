import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'package:intl/intl.dart';
import 'living_sheet.dart';

class ThisMonthCard extends ConsumerWidget {
  const ThisMonthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final flow = ref.watch(thisMonthFlowProvider);
    final burn = ref.watch(monthlyBurnProvider);
    final symbol = ref.watch(currencyProvider).value?.symbol ?? '¥';
    final nf = NumberFormat('#,##0', 'en_US');

    String fmt(double v) => '$symbol ${nf.format(v.abs())}';

    final netColor = flow.net >= 0 ? SC.life : SC.cost;
    final netPrefix = flow.net >= 0 ? '+' : '-';

    final flowSummary = flow.isEmpty
        ? _EmptyState(l10n: l10n)
        : Column(
            children: [
              _Row(label: l10n.cashIn, value: fmt(flow.income), color: SC.life),
              _Row(
                label: l10n.cashOut,
                value: fmt(flow.expenses),
                color: SC.cost,
              ),
              _Row(
                label: l10n.netLabel,
                value: '$netPrefix${fmt(flow.net)}',
                color: netColor,
                isLast: true,
              ),
            ],
          );

    final summary = Column(
      children: [
        flowSummary,
        if (burn.rent.budget > 0)
          _BudgetRow(label: l10n.rentFixed, bucket: burn.rent, fmt: fmt),
        if (burn.living.budget > 0)
          _BudgetRow(
            label: l10n.livingExpenses,
            bucket: burn.living,
            fmt: fmt,
            onTap: () => showLivingSheet(context),
          ),
      ],
    );

    return NeoExpandableCard(
      title: l10n.thisMonth,
      accentColor: SC.chrome,
      summary: summary,
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isLast;

  const _Row({
    required this.label,
    required this.value,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.label),
          Text(
            value,
            style: AppTextStyles.metricSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// Spending against one budget this month, e.g. "$ 210 / $ 30,000" with
/// "$ 29,790 left" underneath.
class _BudgetRow extends StatelessWidget {
  final String label;
  final BudgetBucket bucket;
  final String Function(double) fmt;
  final VoidCallback? onTap;

  const _BudgetRow({
    required this.label,
    required this.bucket,
    required this.fmt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final over = bucket.spentThisMonth - bucket.budget;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(label, style: AppTextStyles.label)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${fmt(bucket.spentThisMonth)} / ${fmt(bucket.budget)}',
                  style: AppTextStyles.metricSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  over > 0
                      ? l10n.budgetOver(fmt(over))
                      : l10n.budgetLeft(fmt(bucket.leftThisMonth)),
                  style: AppTextStyles.caption.copyWith(
                    color: over > 0 ? SC.cost : SC.life,
                  ),
                ),
              ],
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textDim,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: SC.chrome.withAlpha(16),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: SC.chrome.withAlpha(45)),
          ),
          child: Icon(
            Icons.calendar_today_rounded,
            color: SC.chrome,
            size: 18,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            l10n.noActivityThisMonth,
            style: AppTextStyles.bodySmall,
          ),
        ),
      ],
    );
  }
}
