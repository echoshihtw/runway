import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:intl/intl.dart';

class LoanCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final nf = NumberFormat('#,##0', 'en_US');
    final loan = summary.loan;
    final pct = (summary.repaidRatio * 100).toStringAsFixed(0);
    final color = summary.isFullyPaid ? AppColors.textPrimary : AppColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
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
                if (!summary.isFullyPaid)
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
              summary.isFullyPaid ? l10n.paid : nf.format(summary.remainingBalance),
              color,
            ),

            if (!summary.isFullyPaid) ...[
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
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.label),
        Text(value, style: AppTextStyles.value.copyWith(color: valueColor)),
      ],
    );
  }
}
