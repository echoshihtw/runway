import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Expected income against monthly costs, and what the month leaves behind.
///
/// This is the growth half of the product, and until now it had no surface.
/// The figure existed — the model has computed it all along — but it showed
/// only as one caption under the status badge, and only once the forecast
/// sheet had been filled in. So the app said plenty about what money leaves
/// and nothing about what comes in.
///
/// It does not touch the runway. The runway is deliberately what the cash
/// covers if income stopped today (CONTRACTS.md §3.2); this says whether, on
/// current expectations, the month adds to that or spends it.
class EveryMonthCard extends ConsumerWidget {
  const EveryMonthCard({super.key, required this.model, required this.onSetUp});

  final ModelState model;

  /// Opens the place the figure is edited. There is one way in, and it is the
  /// same one the settings sheet uses.
  final VoidCallback onSetUp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final symbol = ref.watch(currencyProvider).value?.symbol ?? '¥';
    final nf = NumberFormat('#,##0', 'en_US');
    String money(double v) => '$symbol ${nf.format(v.abs())}';

    // Nothing to say while there is no cost to say it against. Without a
    // budget, a loan or a subscription the monthly cost is not zero, it is
    // unknown — which is why the runway card next to this one prints a dash —
    // and "Monthly costs 0, Surplus everything" is a confident wrong answer.
    //
    // Nothing to say about an income nobody has told us about either, beyond
    // the one way to say it.
    if (!model.hasCostBasis || !model.hasSustainableProjection) {
      return NeoExpandableCard(
        title: l10n.everyMonth,
        accentColor: SC.accentNeutral,
        summary: GestureDetector(
          onTap: onSetUp,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  l10n.setExpectedIncome,
                  style: AppTextStyles.body.copyWith(color: SC.numberPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: SC.captionColor,
              ),
            ],
          ),
        ),
      );
    }

    final net = model.sustainableNetMonthlyFlow;
    final inSurplus = net >= 0;

    return NeoExpandableCard(
      title: l10n.everyMonth,
      accentColor: inSurplus ? SC.accentLife : SC.accentCost,
      summary: Column(
        children: [
          _Row(
            label: l10n.expectedInflow,
            value: money(model.expectedMonthlyInflow ?? 0),
            color: SC.numberPrimary,
          ),
          const SizedBox(height: AppSpacing.xs),
          _Row(
            label: l10n.pressureLabel,
            value: money(model.totalMonthlyOutflow),
            color: SC.numberPrimary,
          ),
          const SizedBox(height: AppSpacing.xs),
          _Row(
            label: inSurplus ? l10n.monthlySurplus : l10n.monthlyDeficit,
            value: '${inSurplus ? '+' : '-'}${money(net)}',
            color: inSurplus ? SC.numberLife : SC.numberCost,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Both sides yield: the label can be long once translated and the value
    // can be twelve digits.
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.metricSmall.copyWith(color: color),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
