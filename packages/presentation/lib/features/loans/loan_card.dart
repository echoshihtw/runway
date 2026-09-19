import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'package:intl/intl.dart';

class LoanCard extends ConsumerWidget {
  final LoanSummary summary;
  final VoidCallback onTap;
  final VoidCallback onRepay;

  const LoanCard({
    super.key,
    required this.summary,
    required this.onTap,
    required this.onRepay,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final nf = NumberFormat('#,##0', 'en_US');
    final loan = summary.loan;
    final pct = (summary.repaidRatio * 100).toStringAsFixed(0);
    // Repaid principal does not mean the payments stopped: with a term set the
    // term governs, and the runway keeps subtracting the installment. Every
    // row below is shown on every card that is listed at all — gating them on
    // this instead took the installment away from a loan past its term whose
    // principal was still outstanding, which is the one state where the owner
    // most needs to see what it costs. Only the caption turns on it.
    final isCosting = loanIsCosting(summary, now: ref.watch(clockProvider)());
    const color = AppColors.textPrimary;

    // Long press, not tap. The only thing this opens is a dialog that removes
    // the loan from the list for good, and the whole card was the target: a
    // mis-tap anywhere on it plus one confirm took the loan away and moved
    // the runway. A deliberate gesture for a decision with no undo.
    return GestureDetector(
      onLongPress: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.panelBorder, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // The name input allows 50 characters. The name is the one
                // thing here that can be shortened without losing meaning,
                // so it yields; the source and the REPAY button never do.
                Flexible(
                  child: Row(
                    children: [
                      Text(
                        loan.source,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          loan.name.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.value.copyWith(color: color),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!summary.isFullyPaid || isCosting)
                  GestureDetector(
                    onTap: onRepay,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.gold),
                      ),
                      child: Text(
                        l10n.repay,
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            _row(
              l10n.remaining,
              summary.isFullyPaid
                  ? l10n.paid
                  : nf.format(summary.remainingBalance),
              color,
            ),

            const SizedBox(height: AppSpacing.xs),
            _row(
              l10n.installment,
              nf.format(loan.monthlyPayment),
              AppColors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.xs),
            _row(
              l10n.paidThisMo,
              summary.paidThisMonth > 0
                  ? nf.format(summary.paidThisMonth)
                  : '—',
              summary.paidThisMonth == 0
                  ? AppColors.textPrimary
                  : summary.isAheadThisMonth
                  ? AppColors.safe
                  // Gold: this is a loan obligation, not a runway status.
                  : AppColors.gold,
            ),
            if (summary.paidThisMonth > loan.monthlyPayment) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '> +${nf.format(summary.paidThisMonth - loan.monthlyPayment)} ${l10n.extra}',
                style: AppTextStyles.small.copyWith(color: AppColors.safe),
              ),
            ],
            const SizedBox(height: AppSpacing.xs),
            _row(
              l10n.monthsLeft,
              '${summary.monthsRemaining} MO',
              AppColors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.sm),
            LayoutBuilder(
              builder: (_, c) {
                final filled = c.maxWidth * summary.repaidRatio;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          width: c.maxWidth,
                          color: AppColors.panelBorder,
                        ),
                        Container(
                          height: 6,
                          width: filled,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text('$pct${l10n.repaid}', style: AppTextStyles.small),
                  ],
                );
              },
            ),
            if (summary.isFullyPaid && isCosting) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.stillPaying,
                style: AppTextStyles.small.copyWith(color: AppColors.gold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, Color valueColor) {
    // Both sides yield. The label can be long once translated, the value can
    // be twelve digits, and at large text sizes either overflows the card.
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
            style: AppTextStyles.value.copyWith(color: valueColor),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
