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
          _BudgetRow(
            label: l10n.rentFixed,
            bucket: burn.rent,
            fmt: fmt,
            isFixed: true,
          ),
        if (burn.living.budget > 0)
          _BudgetRow(
            label: l10n.livingExpenses.toUpperCase(),
            bucket: burn.living,
            fmt: fmt,
            onTap: () => showLivingSheet(context),
          ),
        // The one rule the whole number rests on, said where the rule applies.
        // A budget is a cap that spending uses up, not a cost that spending
        // adds to, so logging a large expense inside its budget moves nothing
        // — which reads as a broken app to anyone who has not been told. The
        // store listing explains this; until now the product never did.
        if (burn.rent.budget > 0 || burn.living.budget > 0) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.budgetRuleHint, style: AppTextStyles.caption),
        ],
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
          Text(value, style: AppTextStyles.metricSmall.copyWith(color: color)),
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

  /// A fixed cost, where the ratio is not information.
  ///
  /// Rent is its budget. "1,450 / 1,450" and "0 left" say the same thing
  /// twice and neither is a fact anyone acts on, unlike living expenses where
  /// what is left is the whole point and opens a daily figure.
  ///
  /// Going over is the exception: that genuinely adds cost and moves the
  /// runway, so the figures come back exactly when there is something to say.
  final bool isFixed;

  const _BudgetRow({
    required this.label,
    required this.bucket,
    required this.fmt,
    this.onTap,
    this.isFixed = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final over = bucket.spentThisMonth - bucket.budget;
    final showProgress = !isFixed || over > 0;

    /// What a fixed cost says, which depends on how much of it has been
    /// logged. Its amount never changes, so the figure alone cannot
    /// acknowledge that anything happened — and until this, logging rent in
    /// full moved cash, OUT and NET while this row, the one being looked at,
    /// said nothing at all.
    ///
    /// Silence when nothing is logged, never "unpaid": the runway counts rent
    /// whether it is logged or not, because the budget is a floor, so most
    /// people never log it. Reporting the absence of an entry as the absence
    /// of a payment would be a claim the app cannot make.
    String fixedValue() {
      if (bucket.spentThisMonth <= 0) return fmt(bucket.budget);
      if (bucket.spentThisMonth < bucket.budget) {
        return l10n.spentOfBudget(
          fmt(bucket.spentThisMonth),
          fmt(bucket.budget),
        );
      }
      return l10n.budgetPaid(fmt(bucket.budget));
    }

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
                // The answer leads. Mid-month nobody is asking what their
                // budget was, they are asking what is left of it — and that
                // figure was the 11pt caption under a 15pt ratio, so it had
                // to be read past to be found.
                //
                // It also puts the row's one meaningful colour on its one
                // meaningful number: the remainder is mint under budget and
                // pink over, and it was the small one.
                Text(
                  showProgress
                      ? (over > 0
                            ? l10n.budgetOver(fmt(over))
                            : l10n.budgetLeft(fmt(bucket.leftThisMonth)))
                      : fixedValue(),
                  style: AppTextStyles.metricSmall.copyWith(
                    color: !showProgress
                        ? AppColors.textPrimary
                        : over > 0
                        ? SC.cost
                        : SC.life,
                  ),
                ),
                // The working, but only where there is nowhere else to put
                // it. The living row opens a sheet that already states the
                // spend against the budget, draws it as a bar and turns it
                // into a daily figure, so repeating it here was the card
                // answering a question its own chevron answers better.
                //
                // Rent has no sheet, so on the one occasion it has something
                // to show — going over — it shows it inline.
                if (showProgress && onTap == null)
                  Text(
                    l10n.spentOfBudget(
                      fmt(bucket.spentThisMonth),
                      fmt(bucket.budget),
                    ),
                    style: AppTextStyles.metricCaption,
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
          child: Icon(Icons.calendar_today_rounded, color: SC.chrome, size: 18),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(l10n.noActivityThisMonth, style: AppTextStyles.bodySmall),
        ),
      ],
    );
  }
}
