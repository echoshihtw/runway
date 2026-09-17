import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'package:intl/intl.dart';
import '../../shared/add_strip.dart';
import 'loan_card.dart';
import 'start_loan_creation.dart';

class LiabilitiesPanel extends ConsumerWidget {
  const LiabilitiesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final symbol = ref.watch(currencyProvider).value?.symbol ?? '¥';
    final nf = NumberFormat('#,##0', 'en_US');
    final total = ref.watch(totalMonthlyLoanPaymentProvider);
    final active = ref.watch(activeLoanSummariesProvider);

    final summary = active.isEmpty
        // With nothing borrowed the card has no expanded section, so this row
        // is the only way in. It was inert text, seen exactly when someone
        // does not yet know loans are tracked here at all.
        ? GestureDetector(
            onTap: () => startLoanCreation(context, ref),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withAlpha(16),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gold.withAlpha(45)),
                  ),
                  // One glyph per concept: loans wear account_balance
                  // everywhere, card and empty state alike.
                  child: const Icon(
                    Icons.account_balance_rounded,
                    color: AppColors.gold,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 3,
                  child: Text(
                    l10n.noActiveLoans,
                    style: AppTextStyles.bodySmall,
                  ),
                ),
                // The label is the only thing here that can be shortened
                // without losing meaning, so it takes the smaller share.
                Expanded(
                  flex: 2,
                  child: Text(
                    l10n.newLoan,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ],
            ),
          )
        : Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.loanPerMonth, style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '$symbol ${nf.format(total)}',
                      style: AppTextStyles.metric.copyWith(
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.loans, style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      l10n.activeCount(active.length),
                      style: AppTextStyles.metric.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

    final details = active.isEmpty
        ? null
        : Column(
            children: [
              ...active.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: LoanCard(
                    summary: s,
                    onTap: () {},
                    onRepay: () => _showRepay(context, ref, s),
                  ),
                ),
              ),
              AddStrip(
                label: l10n.newLoan,
                color: AppColors.gold,
                onTap: () => startLoanCreation(context, ref),
              ),
            ],
          );

    return NeoExpandableCard(
      title: l10n.liabilities,
      accentColor: SC.accentCost,
      initiallyExpanded: false,
      summary: summary,
      details: details,
    );
  }

  void _showRepay(BuildContext context, WidgetRef ref, LoanSummary summary) {
    final l10n = context.l10n;
    final amountCtrl = TextEditingController(
      text: summary.loan.monthlyPayment.toStringAsFixed(0),
    );

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
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.repayLoan,
              style: AppTextStyles.title.copyWith(color: SC.numberPrimary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              summary.loan.name.toUpperCase(),
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            NeoInput(
              label: l10n.repaymentAmount,
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              hint: summary.loan.monthlyPayment.toStringAsFixed(0),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: NeoButton(
                    label: l10n.confirm,
                    variant: NeoButtonVariant.primary,
                    color: AppColors.gold,
                    fullWidth: true,
                    onPressed: () async {
                      final amount = double.tryParse(amountCtrl.text.trim());
                      if (amount == null || amount <= 0) return;
                      Navigator.of(ctx).pop();
                      final now = DateTime.now();
                      final tx = Transaction(
                        id: const Uuid().v4(),
                        date: now,
                        type: TransactionType.repayment,
                        amount: Money(amount),
                        loanId: summary.loan.id,
                        note: '${l10n.repay} — ${summary.loan.name}',
                        createdAt: now,
                        updatedAt: now,
                      );
                      await ref.read(addTransactionUseCaseProvider).execute(tx);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: NeoButton(
                    label: l10n.cancel,
                    variant: NeoButtonVariant.ghost,
                    fullWidth: true,
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
