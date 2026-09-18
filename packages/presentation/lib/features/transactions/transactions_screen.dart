import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'widgets/transaction_row.dart';
import 'daily_spend_sheet.dart';
import 'show_entry_sheet.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final asyncTxs = ref.watch(transactionsProvider);
    final symbol = ref.watch(currencyProvider).value?.symbol ?? '¥';

    return Scaffold(
      backgroundColor: AppColors.background,
      // One button, one job: ask what was bought. Loans and subscriptions
      // are created from the cards that own them.
      floatingActionButton: GestureDetector(
        key: const Key('add-fab'),
        onTap: () => showDailySpendSheet(context, ref),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.neonGreen,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.neonGreen.withAlpha(80),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            color: AppColors.background,
            size: 26,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: asyncTxs.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.green,
                    strokeWidth: 1.5,
                  ),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'ERROR: $e',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.red,
                    ),
                  ),
                ),
                data: (txs) {
                  if (txs.isEmpty) {
                    return Center(
                      child: GestureDetector(
                        onTap: () => showEntrySheet(
                          context,
                          ref,
                          preselectedType: TransactionType.openingBalance,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.receipt_long_outlined,
                              color: AppColors.textDim,
                              size: 40,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              l10n.noEntries,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.neonGreen,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                '+ ADD OPENING BALANCE',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.background,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final sorted = [...txs]
                    ..sort((a, b) => b.date.compareTo(a.date));

                  final grouped = <String, List<Transaction>>{};
                  for (final tx in sorted) {
                    grouped
                        .putIfAbsent(_monthKey(tx.date), () => [])
                        .add(tx);
                  }
                  final monthKeys = grouped.keys.toList()
                    ..sort((a, b) => b.compareTo(a));

                  final items = <_ListItem>[];
                  for (final key in monthKeys) {
                    items.add(_MonthItem(key, grouped[key]!));
                    for (final tx in grouped[key]!) {
                      items.add(_TxItem(tx));
                    }
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final item = items[i];
                      if (item is _MonthItem) {
                        return _MonthSectionHeader(
                          monthKey: item.key,
                          transactions: item.txs,
                          symbol: symbol,
                        );
                      }
                      final tx = (item as _TxItem).tx;
                      return Dismissible(
                        key: Key(tx.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(
                            right: AppSpacing.lg,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.hotPink.withAlpha(30),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.cardRadius,
                            ),
                          ),
                          child: const Icon(
                            Icons.delete_rounded,
                            color: AppColors.hotPink,
                            size: 22,
                          ),
                        ),
                        confirmDismiss: (_) async {
                          _confirmDelete(context, ref, tx);
                          return false;
                        },
                        child: TransactionRow(
                          transaction: tx,
                          onEdit: () => showEntrySheet(
                            context,
                            ref,
                            existing: tx,
                          ),
                          onDelete: () => _confirmDelete(context, ref, tx),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  void _confirmDelete(BuildContext context, WidgetRef ref, Transaction tx) {
    final l10n = context.l10n;
    final symbol = ref.read(currencyProvider).value?.symbol ?? '¥';
    final amount = NumberFormat('#,##0', 'en_US').format(tx.amount.value);
    final sign = tx.type.isInflow ? '+' : '-';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        title: Text(l10n.purgeEntry, style: AppTextStyles.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tx.type.label.toUpperCase(), style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xs),
            Text('$sign$symbol $amount', style: AppTextStyles.metric),
            if (tx.note != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(tx.note!, style: AppTextStyles.bodySmall),
            ],
            if (tx.type == TransactionType.loan) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.willRemoveLoan,
                style: AppTextStyles.caption.copyWith(color: AppColors.gold),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel, style: AppTextStyles.body),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(deleteTransactionUseCaseProvider)
                  .execute(tx.id);
              if (tx.type == TransactionType.loan && tx.loanId != null) {
                await ref
                    .read(deleteLoanUseCaseProvider)
                    .execute(tx.loanId!);
              }
            },
            child: Text(
              l10n.delete,
              style: AppTextStyles.body.copyWith(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// ── List item model ──────────────────────────────────────────────────────────

sealed class _ListItem {
  const _ListItem();
}

class _MonthItem extends _ListItem {
  final String key;
  final List<Transaction> txs;
  const _MonthItem(this.key, this.txs);
}

class _TxItem extends _ListItem {
  final Transaction tx;
  const _TxItem(this.tx);
}

// ── Month section header ─────────────────────────────────────────────────────

class _MonthSectionHeader extends StatelessWidget {
  final String monthKey; // 'YYYY-MM'
  final List<Transaction> transactions;
  final String symbol;

  const _MonthSectionHeader({
    required this.monthKey,
    required this.transactions,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    final parts = monthKey.split('-');
    final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    final label = DateFormat('MMM yyyy').format(dt).toUpperCase();

    final net = transactions.fold(0.0, (sum, t) => sum + t.signedAmount);
    final isPositive = net >= 0;
    final color = isPositive ? SC.txIncome : SC.txExpense;
    final sign = isPositive ? '+' : '-';
    final amount = NumberFormat('#,##0').format(net.abs());

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.sectionTitle),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(context.l10n.netLabel, style: AppTextStyles.caption),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '$sign$symbol $amount',
                style: AppTextStyles.metricSmall.copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

