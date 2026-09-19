import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../subscription_form.dart';

/// Asks before recording a subscription charge.
///
/// The reminder knows what should have billed; only the owner knows what
/// actually left the account. So the app asks, and records only the answer —
/// it never asserts a payment on the owner's behalf.
class SubscriptionPromptCard extends ConsumerStatefulWidget {
  const SubscriptionPromptCard({super.key});

  @override
  ConsumerState<SubscriptionPromptCard> createState() =>
      _SubscriptionPromptCardState();
}

class _SubscriptionPromptCardState
    extends ConsumerState<SubscriptionPromptCard> {
  /// Set once the owner asks to see the charges one at a time.
  bool _reviewEach = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dismissed = ref.watch(dismissedSubscriptionPromptsProvider);
    final pending = ref
        .watch(pendingSubscriptionChargesProvider)
        .where((charge) => !dismissed.contains(charge.id))
        .toList();
    if (pending.isEmpty) return const SizedBox.shrink();

    // Most subscriptions are on a card that deducts automatically, so the
    // answer is almost always yes. Asking once for the lot beats asking a
    // dozen times — and a returning owner meets a queue, not one question.
    if (pending.length > 1 && !_reviewEach) return _batch(context, pending);

    final charge = pending.first;
    final subscription = _subscriptionFor(charge);
    if (subscription == null) return const SizedBox.shrink();

    final symbol = ref.watch(currencyProvider).value?.symbol ?? '¥';
    final amount = '$symbol ${NumberFormat('#,##0', 'en_US').format(charge.amount.value)}';
    final date = DateFormat('d MMM').format(charge.date);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      child: NeoCard(
        accentColor: SC.subscr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.subscriptionPaidQuestion(amount, subscription.name, date),
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: NeoButton(
                    label: l10n.subscriptionPaidYes,
                    variant: NeoButtonVariant.primary,
                    fullWidth: true,
                    onPressed: () => _confirm(charge),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: NeoButton(
                    label: l10n.subscriptionPaidNo,
                    variant: NeoButtonVariant.ghost,
                    fullWidth: true,
                    onPressed: () => _askWhy(context, charge, subscription),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// One question for the whole queue. Confirming writes every charge; the
  /// owner can still take them one at a time.
  Widget _batch(BuildContext context, List<Transaction> pending) {
    final l10n = context.l10n;
    final symbol = ref.watch(currencyProvider).value?.symbol ?? '¥';
    final total = pending.fold<double>(0, (sum, c) => sum + c.amount.value);
    final amount = '$symbol ${NumberFormat('#,##0', 'en_US').format(total)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      child: NeoCard(
        accentColor: SC.subscr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.subscriptionChargesDue(pending.length, amount),
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: NeoButton(
                    label: l10n.subscriptionConfirmAll,
                    variant: NeoButtonVariant.primary,
                    fullWidth: true,
                    onPressed: () => _confirmAll(pending),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: NeoButton(
                    label: l10n.subscriptionReviewEach,
                    variant: NeoButtonVariant.ghost,
                    fullWidth: true,
                    onPressed: () => setState(() => _reviewEach = true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAll(List<Transaction> pending) async {
    await _write(() async {
      for (final charge in pending) {
        await ref.read(addTransactionUseCaseProvider).execute(charge);
      }
    });
  }

  /// Records entries, and says so when it cannot.
  ///
  /// A silent failure is the worst outcome here: the entry is missing, the
  /// prompt returns every launch, and the button appears to do nothing. An
  /// amount of zero does exactly that, because AddTransactionUseCase rejects
  /// it. The guard also stops a second tap racing the ledger stream.
  Future<void> _write(Future<void> Function() record) async {
    if (_writing) return;
    // No Pro gate here. A confirmed charge does not count against the free
    // allowance, so it must not be blocked by it either — the owner is
    // answering a question the app asked, not logging an entry of their own.
    _writing = true;
    try {
      await record();
    } catch (_) {
      if (!mounted) return;
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.subscriptionChargeFailed),
          backgroundColor: AppColors.surfaceHigh,
        ),
      );
    } finally {
      _writing = false;
    }
  }

  /// The charge id carries its subscription, so the two stay linked without a
  /// column on the table.
  Subscription? _subscriptionFor(Transaction charge) {
    for (final s in ref.watch(subscriptionsProvider).value ?? const <Subscription>[]) {
      if (charge.id.startsWith('subchg-${s.id}-')) return s;
    }
    return null;
  }

  /// Guards against a second tap landing before the ledger stream catches up.
  /// A duplicate would collide with the derived id's primary key, and a failure
  /// must not be mistaken for success.
  bool _writing = false;

  Future<void> _confirm(Transaction charge) async {
    await _write(() async {
      await ref.read(addTransactionUseCaseProvider).execute(charge);
    });
  }

  Future<void> _askWhy(
    BuildContext context,
    Transaction charge,
    Subscription subscription,
  ) async {
    final l10n = context.l10n;
    final reason = await showModalBottomSheet<_NotPaidReason>(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.subscriptionWhatHappened, style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.md),
              NeoButton(
                label: l10n.subscriptionReasonCancelled,
                fullWidth: true,
                onPressed: () =>
                    Navigator.of(sheetContext).pop(_NotPaidReason.cancelled),
              ),
              const SizedBox(height: AppSpacing.sm),
              NeoButton(
                label: l10n.subscriptionReasonPriceChanged,
                fullWidth: true,
                onPressed: () =>
                    Navigator.of(sheetContext).pop(_NotPaidReason.priceChanged),
              ),
              const SizedBox(height: AppSpacing.sm),
              NeoButton(
                label: l10n.subscriptionReasonNotPaid,
                variant: NeoButtonVariant.ghost,
                fullWidth: true,
                onPressed: () =>
                    Navigator.of(sheetContext).pop(_NotPaidReason.notPaid),
              ),
            ],
          ),
        ),
      ),
    );
    if (reason == null) return;

    switch (reason) {
      case _NotPaidReason.cancelled:
        // Stops future prompts. The entries already confirmed stay, because
        // those payments happened.
        await ref.read(editSubscriptionUseCaseProvider).execute(
          subscription.copyWith(isActive: false, updatedAt: DateTime.now()),
        );
      case _NotPaidReason.priceChanged:
        if (!context.mounted) return;
        await _editSubscription(context, subscription);
      case _NotPaidReason.notPaid:
        // Nothing is written. The question is unresolved, so it comes back
        // next launch rather than being answered on the owner's behalf.
        ref
            .read(dismissedSubscriptionPromptsProvider.notifier)
            .dismiss(charge.id);
    }
  }

  Future<void> _editSubscription(
    BuildContext context,
    Subscription subscription,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      builder: (_) => SubscriptionForm(
        existing: subscription,
        onSubmit: (name, category, amount, cycle, startDate, note) async {
          await ref.read(editSubscriptionUseCaseProvider).execute(
            subscription.copyWith(
              name: name,
              category: category,
              amount: amount,
              cycle: cycle,
              startDate: startDate,
              note: note,
              updatedAt: DateTime.now(),
            ),
          );
          return true;
        },
      ),
    );
  }
}

enum _NotPaidReason { cancelled, priceChanged, notPaid }
