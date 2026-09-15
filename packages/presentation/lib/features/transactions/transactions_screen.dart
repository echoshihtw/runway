import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'widgets/transaction_row.dart';
import 'widgets/transaction_form.dart';
import 'widgets/loan_wizard.dart';
import '../subscriptions/subscription_form.dart';
import '../paywall/paywall_screen.dart';
import '../../shared/speed_dial_fab.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  final bool openAddOnLoad;
  final String? firstTransactionType;
  const TransactionsScreen({
    super.key,
    this.openAddOnLoad = false,
    this.firstTransactionType,
  });

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _fabKey = GlobalKey<SpeedDialFabState>();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final asyncTxs = ref.watch(transactionsProvider);
    final symbol = ref.watch(currencyProvider).value?.symbol ?? '¥';

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: SpeedDialFab(
        key: _fabKey,
        onEntry: () => _showForm(context, ref, null),
        onLoan: () => _showLoanWizard(context, ref),
        onSubscription: () => _showSubscriptionForm(context, ref),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: GestureDetector(
        onTap: () => _fabKey.currentState?.close(),
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
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
                          onTap: () => _showFormWithType(
                            context,
                            ref,
                            TransactionType.openingBalance,
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
                            onEdit: () => _showForm(context, ref, tx),
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
      ),
    );
  }

  String _monthKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  Future<void> _showLoanWizard(BuildContext context, WidgetRef ref) async {
    final isPro =
        FeatureFlags.devProEntitlement ||
        (ref.read(entitlementProvider).value?.isPro ?? false);
    if (!isPro) {
      final loans = await ref.read(loansProvider.future);
      final transactions = await ref.read(transactionsProvider.future);
      if (!context.mounted) return;
      if (hasActiveLoan(loans: loans, transactions: transactions)) {
        showPaywall(context, trigger: 'loan_limit');
        return;
      }
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      builder: (_) => LoanWizard(
        onSubmit: (loanAmount, monthlyPayment, termMonths, date, note) async {
          final now = DateTime.now();
          final loanId = const Uuid().v4();
          final parts = (note ?? '').split(' — ');
          final source = parts.isNotEmpty
              ? parts[0].replaceAll(' LOAN', '')
              : 'OTHER';
          final name = parts.length > 1 ? parts[1] : 'LOAN';

          final loan = Loan(
            id: loanId,
            name: name,
            source: source,
            originalAmount: loanAmount,
            monthlyPayment: monthlyPayment,
            originalTermMonths: termMonths,
            startDate: date,
            createdAt: now,
            updatedAt: now,
          );
          await ref.read(addLoanUseCaseProvider).execute(loan);

          final tx = Transaction(
            id: const Uuid().v4(),
            date: date,
            type: TransactionType.loan,
            amount: Money(loanAmount),
            note: note,
            loanId: loanId,
            createdAt: now,
            updatedAt: now,
          );
          await ref.read(addTransactionUseCaseProvider).execute(tx);
        },
      ),
    );
  }

  void _showSubscriptionForm(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      builder: (_) => SubscriptionForm(
        onSubmit: (name, category, amount, cycle, startDate, note) async {
          final now = DateTime.now();
          await ref
              .read(addSubscriptionUseCaseProvider)
              .execute(
                Subscription(
                  id: const Uuid().v4(),
                  name: name,
                  category: category,
                  amount: amount,
                  cycle: cycle,
                  startDate: startDate,
                  nextBillingDate: computeNextBillingDate(startDate, cycle),
                  note: note,
                  createdAt: now,
                  updatedAt: now,
                ),
              );
          return true;
        },
      ),
    );
  }

  void _showFormWithType(
    BuildContext context,
    WidgetRef ref,
    TransactionType preselectedType,
  ) {
    final loans = _loanChoices(ref);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      builder: (_) => TransactionForm(
        existing: null,
        preselectedType: preselectedType,
        loans: loans,
        onSubmit: (type, amount, date, note, category, loanId) async {
          final now = DateTime.now();
          final tx = Transaction(
            id: const Uuid().v4(),
            date: date,
            type: type,
            amount: Money(amount),
            note: note,
            loanId: type == TransactionType.repayment ? loanId : null,
            category: category,
            createdAt: now,
            updatedAt: now,
          );
          await ref.read(addTransactionUseCaseProvider).execute(tx);
        },
      ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref, Transaction? existing) {
    final loans = _loanChoices(ref, existing: existing);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      builder: (_) => TransactionForm(
        existing: existing,
        loans: loans,
        onSubmit: (type, amount, date, note, category, loanId) async {
          final now = DateTime.now();
          if (existing == null) {
            final tx = Transaction(
              id: const Uuid().v4(),
              date: date,
              type: type,
              amount: Money(amount),
              note: note,
              loanId: type == TransactionType.repayment ? loanId : null,
              category: category,
              createdAt: now,
              updatedAt: now,
            );
            await ref.read(addTransactionUseCaseProvider).execute(tx);
          } else {
            final tx = existing.copyWith(
              date: date,
              type: type,
              amount: Money(amount),
              note: note,
              loanId: type == TransactionType.repayment ? loanId : null,
              clearLoanId: type != TransactionType.repayment,
              category: category,
              clearCategory: category == null,
              updatedAt: now,
            );
            await ref.read(editTransactionUseCaseProvider).execute(tx);
          }
        },
      ),
    );
  }

  List<Loan> _loanChoices(WidgetRef ref, {Transaction? existing}) {
    final summaries = ref.read(loanSummariesProvider);
    final loans = activeLoanSummaries(
      summaries,
    ).map((summary) => summary.loan).toList();
    final existingLoanId = existing?.loanId;
    if (existingLoanId != null &&
        !loans.any((loan) => loan.id == existingLoanId)) {
      LoanSummary? existingSummary;
      for (final summary in summaries) {
        if (summary.loan.id == existingLoanId) {
          existingSummary = summary;
          break;
        }
      }
      if (existingSummary != null) loans.add(existingSummary.loan);
    }
    loans.sort((a, b) {
      if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
      return a.name.compareTo(b.name);
    });
    return loans;
  }

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
          Text(
            '$sign$symbol $amount',
            style: AppTextStyles.metricSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

