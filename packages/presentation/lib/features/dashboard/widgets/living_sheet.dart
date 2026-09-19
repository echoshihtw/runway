import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

void showLivingSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.cardRadius),
      ),
    ),
    builder: (_) => const LivingSheet(),
  );
}

/// This month's living spending: spent against the living budget, what is
/// left per remaining day, and every living expense logged this month.
class LivingSheet extends ConsumerWidget {
  const LivingSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final burn = ref.watch(monthlyBurnProvider);
    final living = burn.living;
    final symbol = ref.watch(currencyProvider).value?.symbol ?? '¥';
    final nf = NumberFormat('#,##0', 'en_US');
    String fmt(double v) => '$symbol ${nf.format(v.abs())}';

    final expenses =
        (ref.watch(transactionsProvider).value ?? const <Transaction>[])
            .where((t) => countsAsLiving(t) && t.month == burn.month)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    final over = living.spentThisMonth - living.budget;
    final days = burn.daysLeftThisMonth;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.livingExpenses, style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.md),
            Text(
              '${fmt(living.spentThisMonth)} / ${fmt(living.budget)}',
              style: AppTextStyles.metric,
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: living.budget > 0
                    ? (living.spentThisMonth / living.budget).clamp(0.0, 1.0)
                    : 0,
                minHeight: 4,
                backgroundColor: AppColors.cardBorder,
                valueColor: AlwaysStoppedAnimation(
                  over > 0 ? SC.cost : SC.life,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              over > 0
                  ? l10n.budgetOver(fmt(over))
                  : l10n.budgetLeft(fmt(living.leftThisMonth)),
              style: AppTextStyles.metricCaption.copyWith(
                color: over > 0 ? SC.cost : SC.life,
              ),
            ),
            if (living.leftThisMonth > 0 && days > 0) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.dailyAllowance(fmt(living.leftThisMonth / days), days),
                style: AppTextStyles.metricSmall,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            if (expenses.isEmpty)
              Text(
                l10n.noLivingExpensesThisMonth,
                style: AppTextStyles.bodySmall,
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final t in expenses)
                      _ExpenseLine(transaction: t, fmt: fmt),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseLine extends StatelessWidget {
  final Transaction transaction;
  final String Function(double) fmt;

  const _ExpenseLine({required this.transaction, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final label =
        transaction.note ??
        transaction.category?.label ??
        context.l10n.typeExpense;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              DateFormat('dd MMM').format(transaction.date).toUpperCase(),
              style: AppTextStyles.caption,
            ),
          ),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '-${fmt(transaction.amount.value)}',
            style: AppTextStyles.metricSmall.copyWith(color: SC.cost),
          ),
        ],
      ),
    );
  }
}
