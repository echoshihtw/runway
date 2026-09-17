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
class SubscriptionPromptCard extends ConsumerWidget {
  const SubscriptionPromptCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final dismissed = ref.watch(dismissedSubscriptionPromptsProvider);
    final pending = ref
        .watch(pendingSubscriptionChargesProvider)
        .where((charge) => !dismissed.contains(charge.id))
        .toList();
    if (pending.isEmpty) return const SizedBox.shrink();

    final charge = pending.first;
    final subscription = _subscriptionFor(ref, charge);
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
                    onPressed: () => _confirm(ref, charge),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: NeoButton(
                    label: l10n.subscriptionPaidNo,
                    variant: NeoButtonVariant.ghost,
                    fullWidth: true,
                    onPressed: () => _askWhy(context, ref, charge, subscription),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// The charge id carries its subscription, so the two stay linked without a
  /// column on the table.
  Subscription? _subscriptionFor(WidgetRef ref, Transaction charge) {
    for (final s in ref.watch(subscriptionsProvider).value ?? const <Subscription>[]) {
      if (charge.id.startsWith('subchg-${s.id}-')) return s;
    }
    return null;
  }

  Future<void> _confirm(WidgetRef ref, Transaction charge) async {
    await ref.read(addTransactionUseCaseProvider).execute(charge);
  }

  Future<void> _askWhy(
    BuildContext context,
    WidgetRef ref,
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
        await _editSubscription(context, ref, subscription);
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
    WidgetRef ref,
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
