import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:application/application.dart';
import 'package:intl/intl.dart';

import '../../../shared/ledger_glyphs.dart';

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
    // A starting line, not a category of money: it takes no category colour.
    TransactionType.openingBalance => AppColors.textSecondary,
    TransactionType.loan => SC.txLoan,
    TransactionType.expense => SC.txExpense,
    TransactionType.repayment => SC.txRepayment,
    TransactionType.subscriptionCharge => SC.subscr,
  };

  IconData get _typeIcon => switch (transaction.type) {
    TransactionType.income => LedgerGlyphs.inflow,
    TransactionType.openingBalance => LedgerGlyphs.start,
    // The loan and each payment on it are the same concept, so they wear the
    // same mark as the liabilities card — and colour, not shape, says which
    // commitment a scheduled payment belongs to.
    TransactionType.loan => LedgerGlyphs.lender,
    TransactionType.repayment => LedgerGlyphs.lender,
    TransactionType.expense => LedgerGlyphs.spent,
    TransactionType.subscriptionCharge => LedgerGlyphs.recurring,
  };

  String _typeLabel(AppLocalizations l10n) => switch (transaction.type) {
    TransactionType.expense => l10n.typeExpense,
    TransactionType.income => l10n.typeIncome,
    TransactionType.loan => l10n.typeLoan,
    TransactionType.repayment => l10n.typeRepay,
    TransactionType.openingBalance => l10n.typeOpening,
    TransactionType.subscriptionCharge => l10n.typeSubscription,
  };

  bool _isPlannedAt(DateTime now) => transaction.date.isAfter(now);

  /// The note, when there is one, is what the user wrote to recognise the
  /// entry, so it leads. The type is the fallback title.
  bool get _isExpense => transaction.type == TransactionType.expense;

  String? get _note {
    final note = transaction.note?.trim();
    return note == null || note.isEmpty ? null : note;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isPlanned = _isPlannedAt(ref.watch(clockProvider)());
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
                      if (isPlanned) ...[
                        const SizedBox(width: AppSpacing.xs),
                        PixelBadge(
                          label: l10n.planned,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ],
                  ),
                  if (_note != null || _isExpense) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      [
                        if (_note != null) _typeLabel(l10n).toUpperCase(),
                        // Every expense uses up the rent or the living budget,
                        // so name that, not the category picker's old group.
                        if (_isExpense)
                          if (countsAsRent(transaction)) 'RENT' else 'LIVING',
                        // Older entries carry a finer category. Newer ones
                        // don't, and the bucket above already says enough.
                        if (transaction.category != null &&
                            transaction.category != ExpenseCategory.rent)
                          transaction.category!.label,
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
                        // The opening balance is where counting starts, not
                        // money that moved; it must not sum with the day.
                        color:
                            transaction.type == TransactionType.openingBalance
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
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
