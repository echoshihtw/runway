import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:application/application.dart';
import 'package:intl/intl.dart';

class TransactionRow extends ConsumerWidget {
  final Transaction transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionRow({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _typeColor => switch (transaction.type) {
    TransactionType.income => SC.txIncome,
    TransactionType.openingBalance => SC.txOpeningBalance,
    TransactionType.loan => SC.txLoan,
    TransactionType.expense => SC.txExpense,
    TransactionType.repayment => SC.txRepayment,
    _ => SC.txInvestment,
  };

  IconData get _typeIcon => switch (transaction.type) {
    TransactionType.income => Icons.arrow_downward_rounded,
    TransactionType.openingBalance => Icons.account_balance_rounded,
    TransactionType.loan => Icons.credit_score_rounded,
    TransactionType.expense => Icons.arrow_upward_rounded,
    TransactionType.repayment => Icons.replay_rounded,
    _ => Icons.trending_up_rounded,
  };

  String _typeLabel(AppLocalizations l10n) => switch (transaction.type) {
    TransactionType.expense => l10n.typeExpense,
    TransactionType.income => l10n.typeIncome,
    TransactionType.loan => l10n.typeLoan,
    TransactionType.repayment => l10n.typeRepay,
    TransactionType.openingBalance => l10n.typeOpening,
    _ => transaction.type.label,
  };

  bool get _isPlanned => transaction.date.isAfter(DateTime.now());

  /// The note, when there is one, is what the user wrote to recognise the
  /// entry, so it leads. The type is the fallback title.
  String? get _note {
    final note = transaction.note?.trim();
    return note == null || note.isEmpty ? null : note;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final symbol = ref.watch(currencyProvider).value?.symbol ?? '¥';
    final amount = NumberFormat(
      '#,##0',
      'en_US',
    ).format(transaction.amount.value);
    final sign = transaction.type.isInflow ? '+' : '-';
    final dateStr = DateFormat('dd MMM').format(transaction.date).toUpperCase();
    final color = _typeColor;

    return GestureDetector(
      onTap: onEdit,
      onLongPress: onDelete,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.cardBorder, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha(18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withAlpha(40), width: 1),
              ),
              child: Icon(_typeIcon, color: color, size: 18),
            ),
            const SizedBox(width: AppSpacing.md),

            // Label + note + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _note ?? _typeLabel(l10n).toUpperCase(),
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_isPlanned) ...[
                        const SizedBox(width: AppSpacing.xs),
                        PixelBadge(
                          label: l10n.planned,
                          color: AppColors.textDim,
                        ),
                      ],
                    ],
                  ),
                  if (_note != null || transaction.category != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      [
                        if (_note != null) _typeLabel(l10n).toUpperCase(),
                        if (transaction.category != null) ...[
                          transaction.category!.group,
                          transaction.category!.label,
                        ],
                      ].join(' · '),
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Amount + date
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 136),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$sign$symbol $amount',
                      style: AppTextStyles.metricSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(dateStr, style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
