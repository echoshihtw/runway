import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'package:intl/intl.dart';
import '../../shared/add_strip.dart';
import '../../shared/ledger_glyphs.dart';
import 'add_subscription_sheet.dart';
import 'subscription_form.dart';

class SubscriptionsPanel extends ConsumerWidget {
  const SubscriptionsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final subs = ref.watch(subscriptionsProvider).value ?? [];
    final symbol = ref.watch(currencyProvider).value?.symbol ?? '¥';
    final nf = NumberFormat('#,##0', 'en_US');
    final active = subs.where((s) => s.isActive).toList();
    final now = ref.watch(clockProvider)();
    final sorted = sortedByNextBilling(active, now: now);
    final monthly = totalSubscriptionMonthlyCost(active);
    final yearly = totalSubscriptionYearlyCost(active);
    final next = sorted.isEmpty ? null : sorted.first;

    // Show category tags only when both personal AND business exist
    final hasPersonal = active.any(
      (s) => s.category == SubscriptionCategory.personal,
    );
    final hasBusiness = active.any(
      (s) => s.category == SubscriptionCategory.business,
    );
    final showCatLabel = hasPersonal && hasBusiness;

    final summary = active.isEmpty
        ? _EmptySummary(
            l10n: l10n,
            onAdd: () => showAddSubscriptionSheet(context, ref),
          )
        : Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MetricCell(
                      unit: l10n.subscrPerMonth,
                      value: '$symbol ${nf.format(monthly)}',
                      color: SC.subscr,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _MetricCell(
                      unit: l10n.subscrPerYear,
                      value: '$symbol ${nf.format(yearly)}',
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _NextBillingStrip(sub: next!, now: now),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _CountBadge(count: active.length),
                ],
              ),
            ],
          );

    final details = active.isEmpty
        ? null
        : Column(
            children: [
              for (var i = 0; i < sorted.length; i++)
                _SubRow(
                  sub: sorted[i],
                  symbol: symbol,
                  nf: nf,
                  showCategoryLabel: showCatLabel,
                  showDivider: i < sorted.length - 1,
                  onEdit: () => _showEditSubscription(context, ref, sorted[i]),
                  now: now,
                ),
              AddStrip(
                label: l10n.newSubscription,
                color: SC.subscr,
                onTap: () => showAddSubscriptionSheet(context, ref),
              ),
            ],
          );

    return NeoExpandableCard(
      title: l10n.subscriptions,
      accentColor: SC.subscr,
      initiallyExpanded: false,
      summary: summary,
      details: details,
      trailing: active.isEmpty
          ? null
          : Text(
              '${active.length}',
              style: AppTextStyles.caption.copyWith(color: SC.subscr),
            ),
    );
  }

  /// A reminder has to be stoppable. Deleting it ends future entries; the
  /// payments already written stay in the log, because they happened.
  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Subscription subscription,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.deleteSubscription, style: AppTextStyles.label),
        content: Text(
          l10n.deleteSubscriptionKeepsEntries,
          style: AppTextStyles.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.abort, style: AppTextStyles.label),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.deleteSubscription,
              style: AppTextStyles.label.copyWith(color: SC.cost),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(deleteSubscriptionUseCaseProvider).execute(subscription.id);
  }

  void _showEditSubscription(
    BuildContext context,
    WidgetRef ref,
    Subscription subscription,
  ) {
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
      builder: (_) => SubscriptionForm(
        existing: subscription,
        onSubmit: (name, category, amount, cycle, startDate, note) async {
          final updated = Subscription(
            id: subscription.id,
            name: name,
            category: category,
            amount: amount,
            cycle: cycle,
            startDate: startDate,
            nextBillingDate: computeNextBillingDate(startDate, cycle),
            note: note,
            isActive: subscription.isActive,
            createdAt: subscription.createdAt,
            updatedAt: DateTime.now(),
          );
          await ref.read(editSubscriptionUseCaseProvider).execute(updated);
          return true;
        },
        onDelete: () => _confirmDelete(context, ref, subscription),
      ),
    );
  }
}

class _EmptySummary extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onAdd;

  const _EmptySummary({required this.l10n, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    // With nothing subscribed the card has no expanded section, so this row is
    // the only way in. It was inert text, which meant the only door was the
    // add menu — and the one place someone learns the feature exists could not
    // act on it.
    return GestureDetector(
      onTap: onAdd,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: SC.subscr.withAlpha(16),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SC.subscr.withAlpha(45)),
            ),
            // One glyph per concept: the rows and the logged charge both use
            // autorenew, so the card uses it too.
            child: const Icon(
              LedgerGlyphs.recurring,
              color: SC.subscr,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 3,
            child: Text(l10n.noSubscriptions, style: AppTextStyles.bodySmall),
          ),
          // The label is the only thing in this row that can be shortened
          // without losing meaning, so it takes the smaller share and
          // ellipsises instead of pushing the row past the screen edge.
          Expanded(
            flex: 2,
            child: Text(
              l10n.newSubscription,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(color: SC.subscr),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  final String unit;
  final String value;
  final Color color;

  const _MetricCell({
    required this.unit,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(unit, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          style: AppTextStyles.metric.copyWith(color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _NextBillingStrip extends StatelessWidget {
  final Subscription sub;

  /// Handed down rather than read here, so one frame cannot count from a
  /// different instant than the row beside it, and a test can pin both.
  final DateTime now;

  const _NextBillingStrip({required this.sub, required this.now});

  @override
  Widget build(BuildContext context) {
    final days = daysUntilNextBilling(sub, now);
    final color = days <= 7
        ? AppColors.hotPink
        : days <= 14
        ? AppColors.gold
        : SC.subscr;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Row(
        children: [
          Icon(Icons.event_rounded, color: color, size: 14),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              '${sub.name.toUpperCase()} · ${days}D',
              style: AppTextStyles.caption.copyWith(color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: SC.subscr.withAlpha(16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SC.subscr.withAlpha(55)),
      ),
      child: Text(
        '$count ACTIVE',
        style: AppTextStyles.caption.copyWith(color: SC.subscr),
      ),
    );
  }
}

class _SubRow extends StatelessWidget {
  final Subscription sub;
  final String symbol;
  final NumberFormat nf;
  final bool showCategoryLabel;
  final bool showDivider;
  final VoidCallback onEdit;
  final DateTime now;

  const _SubRow({
    required this.sub,
    required this.symbol,
    required this.nf,
    this.showCategoryLabel = false,
    required this.showDivider,
    required this.onEdit,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final days = daysUntilNextBilling(sub, now);
    final daysColor = days <= 7
        ? AppColors.hotPink
        : days <= 14
        ? AppColors.gold
        : AppColors.textDim;

    return GestureDetector(
      onTap: onEdit,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(bottom: BorderSide(color: AppColors.cardBorder))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: daysColor.withAlpha(16),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: daysColor.withAlpha(55)),
              ),
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              child: Icon(LedgerGlyphs.recurring, color: daysColor, size: 15),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          sub.name.toUpperCase(),
                          style: AppTextStyles.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (showCategoryLabel) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: SC.subscr.withAlpha(20),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: SC.subscr.withAlpha(60)),
                          ),
                          child: Text(
                            sub.category == SubscriptionCategory.personal
                                ? l10n.personal
                                : l10n.business,
                            style: AppTextStyles.caption.copyWith(
                              color: SC.subscr,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${sub.cycle.label} · '
                    '$symbol ${nf.format(sub.amount)} · '
                    '≈ $symbol ${nf.format(sub.monthlyEquivalent)}/mo',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${days}D',
              style: AppTextStyles.metricSmall.copyWith(color: daysColor),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.edit_rounded, color: AppColors.textDim, size: 14),
          ],
        ),
      ),
    );
  }
}
