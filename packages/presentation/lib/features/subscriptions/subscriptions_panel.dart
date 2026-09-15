import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'package:intl/intl.dart';
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
    final sorted = sortedByNextBilling(active);
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
        ? _EmptySummary(l10n: l10n)
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
                  Expanded(child: _NextBillingStrip(sub: next!)),
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
      ),
    );
  }
}

class _EmptySummary extends StatelessWidget {
  final AppLocalizations l10n;

  const _EmptySummary({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: SC.subscr.withAlpha(16),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: SC.subscr.withAlpha(45)),
          ),
          child: const Icon(
            Icons.subscriptions_rounded,
            color: SC.subscr,
            size: 18,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(l10n.noSubscriptions, style: AppTextStyles.bodySmall),
        ),
      ],
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

  const _NextBillingStrip({required this.sub});

  @override
  Widget build(BuildContext context) {
    final days = sub.daysUntilNextBilling;
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

  const _SubRow({
    required this.sub,
    required this.symbol,
    required this.nf,
    this.showCategoryLabel = false,
    required this.showDivider,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final days = sub.daysUntilNextBilling;
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
              child: Icon(Icons.autorenew_rounded, color: daysColor, size: 15),
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
                            border: Border.all(
                              color: SC.subscr.withAlpha(60),
                            ),
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
