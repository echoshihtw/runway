import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:application/application.dart';
import 'package:intl/intl.dart';
import '../../../shared/status_color.dart';

class RunwayCard extends ConsumerWidget {
  final ModelState model;
  const RunwayCard({super.key, required this.model});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final symbol = ref.watch(currencyProvider).value?.symbol ?? '¥';
    final nf = NumberFormat('#,##0', 'en_US');
    final status = model.runwayStatus;

    // With no cost known the runway cannot be stated, so it must not borrow
    // the confidence of a status colour.
    final known = model.runwayIsKnown;
    final owed = ref.watch(totalOwedProvider);
    final color = known ? statusColor(status) : SC.unknown;
    final statusLabel = switch (status) {
      RunwayStatus.stable => l10n.stable,
      RunwayStatus.caution => l10n.caution,
      RunwayStatus.critical => l10n.critical,
    };

    String fmtRunwayMonths(int m) {
      if (!known) return '—';
      if (m >= 9999) return '∞';
      return '$m';
    }

    String fmtRunwayMonthUnit(int m) {
      if (!known || m >= 9999) return '';
      return m == 1 ? l10n.monthSingular : l10n.monthPlural;
    }

    String fmtSustainability() {
      if (!model.hasSustainableProjection) return '';
      if (model.isSustainableIndefinitely) {
        return l10n.sustainableWithExpectedInflow;
      }
      return l10n.shortByPerMonth(
        '$symbol ${nf.format(model.sustainableMonthlyShortfall)}',
      );
    }

    String fmtDate(DateTime? d) =>
        d == null ? '—' : DateFormat('MMM yyyy').format(d).toUpperCase();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        color: AppColors.surface,
        border: Border.all(color: color.withAlpha(40), width: 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                fmtRunwayMonths(model.runwayMonths),
                style: AppTextStyles.heroLarge.copyWith(
                  color: color,
                  fontSize: 72,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                ' ${fmtRunwayMonthUnit(model.runwayMonths)}',
                style: AppTextStyles.metric.copyWith(
                  color: color.withAlpha(180),
                ),
              ),
            ],
          ),
          Text(
            known
                ? switch (model.basis) {
                    RunwayBasis.budget => l10n.runwayBasisBudget,
                    RunwayBasis.spending => l10n.runwayBasisSpending,
                    RunwayBasis.assumption => l10n.runwayBasisAssumption,
                  }
                : l10n.runwayNeedsCosts,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
          if (known) ...[
            const SizedBox(height: AppSpacing.md),
            PixelBadge(label: statusLabel, color: color),
          ],
          if (model.hasSustainableProjection) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              fmtSustainability(),
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: model.isSustainableIndefinitely
                    ? AppColors.green
                    : AppColors.gold,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Divider(color: Colors.white.withAlpha(15), height: 1),
          const SizedBox(height: AppSpacing.md),
          // Borrowing is an inflow: it raises cash and the runway with
          // it, and until now the other side of that same transaction
          // appeared nowhere on this card. OWED is that other side,
          // beside the balance it was borrowed into, as a balance.
          //
          // The two are not to be subtracted, and nothing here invites
          // it: gold is debt's colour throughout the app and mint is
          // cash's, so they read as two facts rather than a sum. The
          // monthly payment stays in the liabilities panel with the
          // other monthly figures. Stocks with stocks, flows with flows.
          //
          // With nothing borrowed the pair is CASH and RUN OUT, as it
          // has always been. A row reading $symbol 0 would be a
          // liability the owner does not have.
          Row(
            children: [
              Expanded(child: _cash(l10n, symbol, nf)),
              Expanded(
                child: owed > 0
                    ? _stat(
                        l10n.owed,
                        '$symbol ${nf.format(owed)}',
                        SC.accentCost,
                      )
                    : _stat(l10n.runOut, fmtDate(model.runOutDate), SC.unknown),
              ),
            ],
          ),
          if (owed > 0) ...[
            const SizedBox(height: AppSpacing.md),
            _stat(l10n.runOut, fmtDate(model.runOutDate), SC.unknown),
          ],
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }

  Widget _cash(AppLocalizations l10n, String symbol, NumberFormat nf) => _stat(
    l10n.cash,
    // An unloaded ledger has no balance to state. The runway already
    // says so with the same mark.
    model.cashIsKnown ? '$symbol ${nf.format(model.currentCash)}' : '—',
    // Negative cash is not life. An overdrawn balance in the mint used
    // for cash and runway reads as "you are fine" at the exact moment
    // that is least true.
    !model.cashIsKnown
        ? SC.unknown
        : model.currentCash < 0
        ? SC.numberCost
        : SC.numberLife,
  );

  Widget _stat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The component shouts and the translation carries sentence case
        // (#188). CASH and RUN OUT are still baked caps in the backlog, so
        // this is the identity for them until they are written down.
        Text(label.toUpperCase(), style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          style: AppTextStyles.metricSmall.copyWith(color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
