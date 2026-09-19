import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'package:intl/intl.dart';
import '../../shared/add_strip.dart';
import '../../shared/ledger_glyphs.dart';
import '../../shared/pro_gate.dart';
import '../../shared/money_field.dart';
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
                    color: SC.accentCost.withAlpha(16),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SC.accentCost.withAlpha(45)),
                  ),
                  // One glyph per concept: loans wear account_balance
                  // everywhere, card and empty state alike.
                  child: const Icon(
                    LedgerGlyphs.lender,
                    color: SC.accentCost,
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
                    style: AppTextStyles.label.copyWith(color: SC.accentCost),
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
                        color: SC.accentCost,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                        color: SC.captionColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                    onTap: () => _confirmSettled(context, ref, s),
                    onRepay: () => _showRepay(context, ref, s),
                  ),
                ),
              ),
              AddStrip(
                label: l10n.newLoan,
                color: SC.accentCost,
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

  /// The only way to say a loan is over.
  ///
  /// Nothing else in the app ever sets a loan inactive, so a loan settled
  /// early sat on this list charging the runway until its term ran out, and a
  /// loan whose entry lost its id could not be reached by the delete path at
  /// all. The card's tap did nothing until now.
  ///
  /// Settling leaves every entry alone. It is the commitment that ends, not
  /// the history of what was paid.
  Future<void> _confirmSettled(
    BuildContext context,
    WidgetRef ref,
    LoanSummary summary,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.markSettled, style: AppTextStyles.label),
        content: Text(l10n.markSettledExplain, style: AppTextStyles.bodySmall),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.abort, style: AppTextStyles.label),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.markSettled,
              style: AppTextStyles.label.copyWith(color: SC.cost),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(editLoanUseCaseProvider)
        .execute(
          summary.loan.copyWith(isActive: false, updatedAt: DateTime.now()),
        );
  }

  void _showRepay(BuildContext context, WidgetRef ref, LoanSummary summary) {
    if (!allowsNewEntry(context, ref)) return;
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
      builder: (_) => _RepaySheet(summary: summary),
    );
  }
}

/// Owns the amount controller, so it is disposed with the sheet. It used to
/// be created in [_showRepay] and handed to a StatelessWidget that could not
/// dispose it: one leaked controller per REPAY (#95).
class _RepaySheet extends ConsumerStatefulWidget {
  final LoanSummary summary;
  const _RepaySheet({required this.summary});

  @override
  ConsumerState<_RepaySheet> createState() => _RepaySheetState();
}

class _RepaySheetState extends ConsumerState<_RepaySheet> {
  late final _amountCtrl = TextEditingController(
    text: moneyField(widget.summary.loan.monthlyPayment),
  );

  /// CONFIRM used to be live on an empty field while the handler returned
  /// early, so tapping it did nothing and the sheet sat there — the same
  /// fault the subscription sheet had before #168.
  bool get _valid => (double.tryParse(_amountCtrl.text.trim()) ?? 0) > 0;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final summary = widget.summary;
    return Container(
      // Capped and scrollable, as the subscription sheet is since #168: the
      // button row overflowed at 320pt with large text.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
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
              controller: _amountCtrl,
              // Without this the field takes letters, and CONFIRM then parses
              // null and silently does nothing.
              inputType: NeoInputType.decimal,
              keyboardType: TextInputType.number,
              hint: moneyField(summary.loan.monthlyPayment),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: NeoButton(
                    label: l10n.confirm,
                    variant: NeoButtonVariant.primary,
                    color: SC.accentCost,
                    fullWidth: true,
                    onPressed: !_valid
                        ? null
                        : () async {
                            final amount = double.tryParse(
                              _amountCtrl.text.trim(),
                            );
                            if (amount == null || amount <= 0) return;
                            Navigator.of(context).pop();
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
                            await ref
                                .read(addTransactionUseCaseProvider)
                                .execute(tx);
                          },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: NeoButton(
                    label: l10n.cancel,
                    variant: NeoButtonVariant.ghost,
                    fullWidth: true,
                    onPressed: () => Navigator.of(context).pop(),
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
