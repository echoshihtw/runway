import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import '../../product_config.dart';
import '../../shared/pro_gate.dart';
import '../../shared/status_color.dart';
import '../../shared/money_field.dart';
import '../transactions/show_entry_sheet.dart';
import 'package:domain/domain.dart';
import 'package:intl/intl.dart';

/// Matches the engine's unlimited sentinel.
const _unlimitedMonths = 9999;

class ScenariosScreen extends ConsumerWidget {
  const ScenariosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scenario = ref.watch(scenarioProvider);
    final simulationsRun = ref.watch(simulationCountProvider).value ?? 0;
    final realModel = ref.watch(modelProvider);
    final burn = ref.watch(monthlyBurnProvider);
    final simModel = ref.watch(scenarioModelProvider);
    final symbol = ref.watch(currencyProvider).value?.symbol ?? '¥';
    final nf = NumberFormat('#,##0', 'en_US');

    // No abs(): a negative balance is an overdraft, and showing it unsigned
    // told the owner they had money they did not have.
    String fmt(double v) => '$symbol ${nf.format(v)}';
    String fmtRunway(int m) {
      if (m >= 9999) return '∞';
      if (m >= 24) return '${(m / 12).toStringAsFixed(1)} YRS';
      return '$m MO';
    }

    Color runwayColor(RunwayStatus s) => statusColor(s);

    final variableBurn = burn.variableBurn > 0 ? burn.variableBurn : null;
    final fixedCosts = burn.subscriptions + burn.loanPayments;
    // The button exists only while it has a job. Disabled, it rendered as a
    // dimmed primary fill both before any input and underneath the result it
    // had just produced, which reads as broken at the one moment the product
    // is trying to impress (#108).
    final canRun =
        realModel.currentCash != 0 &&
        scenario.hasInput &&
        !scenario.isCalculating &&
        !scenario.isActive;

    return GradientScaffold(
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.scenarioSimulator, style: AppTextStyles.title),
            Text(
              l10n.whatIfAnalysis,
              style: AppTextStyles.caption.copyWith(letterSpacing: 1.5),
            ),
            const SizedBox(height: AppSpacing.xl),

            NeoCard(
              title: l10n.current,
              accentColor: AppColors.green,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _tile(
                          l10n.runway,
                          // The dashboard refuses to state a runway with no
                          // cost known, and says so with an em dash. This
                          // screen used to show the same owner ∞ in mint with
                          // a STABLE colour, one tab away (CONTRACTS §3.1).
                          realModel.runwayIsKnown
                              ? fmtRunway(realModel.runwayMonths)
                              : '—',
                          realModel.runwayIsKnown
                              ? runwayColor(realModel.runwayStatus)
                              : AppColors.textSecondary,
                        ),
                      ),
                      Expanded(
                        child: _tile(
                          l10n.totalPerMonth,
                          '-${fmt(realModel.totalMonthlyOutflow)}',
                          AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _tile(
                          l10n.cash,
                          realModel.cashIsKnown
                              ? fmt(realModel.currentCash)
                              : '—',
                          AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.cardGap),

            NeoCard(
              title: l10n.simulate,
              accentColor: AppColors.purple,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.simHint, style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.md),
                  // The field changes rent + living only; subscriptions and
                  // loans survive it (CONTRACTS §3.2). It starts at the
                  // current value so the number the user edits is the one
                  // the field means, not the TOTAL/MO figure two rows up,
                  // which includes the fixed costs (#116).
                  _SimInput(
                    label: l10n.burnRateOverride,
                    hint: '0',
                    initialValue: moneyField(
                      scenario.burnRateOverride ?? variableBurn,
                    ),
                    resetVersion: scenario.resetVersion,
                    focusOnReset: true,
                    onChanged: (v) {
                      final value = double.tryParse(v);
                      ref
                          .read(scenarioProvider.notifier)
                          .setBurnRateOverride(value);
                    },
                  ),
                  if (fixedCosts > 0) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.fixedCostsUnchanged(fmt(fixedCosts)),
                      style: AppTextStyles.caption,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  _SimInput(
                    label: l10n.simulatedIncome,
                    hint: '0',
                    initialValue: moneyField(scenario.simulatedIncome),
                    resetVersion: scenario.resetVersion,
                    focusOnReset: false,
                    onChanged: (v) {
                      final value = double.tryParse(v);
                      ref
                          .read(scenarioProvider.notifier)
                          .setSimulatedIncome(value);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _simulationResult(
                    context: context,
                    ref: ref,
                    l10n: l10n,
                    scenario: scenario,
                    realModel: realModel,
                    simModel: simModel,
                    fmtRunway: fmtRunway,
                    runwayColor: runwayColor,
                  ),
                  // Always rendered. It was deleted when disabled because a
                  // faded primary fill read as broken (#108), which left the
                  // screen with no primary action at all on a cold open — the
                  // cause was the disabled styling, and that is fixed in
                  // NeoButton, so the state can be shown rather than hidden.
                  const SizedBox(height: AppSpacing.md),
                  NeoButton(
                    label: l10n.runSimulation,
                    variant: NeoButtonVariant.primary,
                    fullWidth: true,
                    onPressed: canRun
                        ? () {
                            if (!allowsSimulation(context, ref)) return;
                            ref.read(scenarioProvider.notifier).activate();
                          }
                        : null,
                  ),
                  // Shown once the first is spent, so the paywall never
                  // arrives unannounced.
                  if (simulationsRun > 0 && !isProOwner(ref)) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.freeSimulationsUsed(
                        simulationsRun,
                        ProductConfig.freeSimulations,
                      ),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  NeoButton(
                    label: l10n.resetSim,
                    variant: NeoButtonVariant.ghost,
                    fullWidth: true,
                    onPressed: () {
                      ref.read(scenarioProvider.notifier).reset();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _tile(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
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

  Widget _simulationResult({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocalizations l10n,
    required ScenarioState scenario,
    required ModelState realModel,
    required ModelState? simModel,
    required String Function(int) fmtRunway,
    required Color Function(RunwayStatus) runwayColor,
  }) {
    if (realModel.currentCash == 0) {
      // This used to read "Go to LOG → + ADD → Opening Balance", a route that
      // stopped existing when the add sheet was replaced by the preset grid
      // (#134, #135). The panel now opens the form itself, the way the
      // Getting Started steps do (#142, #153).
      return _simulationPanel(
        icon: Icons.account_balance_wallet_outlined,
        child: Column(
          children: [
            Text(
              l10n.simNeedsBalance,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.simNeedsBalanceWhy,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            NeoButton(
              label: l10n.addOpeningBalance,
              variant: NeoButtonVariant.primary,
              fullWidth: true,
              onPressed: () => showEntrySheet(
                context,
                ref,
                preselectedType: TransactionType.openingBalance,
              ),
            ),
          ],
        ),
      );
    }

    if (scenario.isCalculating || (scenario.isActive && simModel == null)) {
      return _simulationPanel(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.purple,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(l10n.simulation, style: AppTextStyles.bodySmall),
          ],
        ),
      );
    }

    if (scenario.isActive && simModel != null) {
      // 9999 is the unlimited sentinel, not a quantity. Differencing against
      // it printed "+9997 MO" beside ∞, and a runway that is unlimited in the
      // plan is a state to name rather than a number to subtract.
      final unlimited = simModel.runwayMonths >= _unlimitedMonths;
      // Both runways are floored to whole months, so a difference of floors
      // reported "0 MO" for a cut worth half a month — at two months of
      // runway, the fifteen days that decide it.
      final deltaDays = simModel.runwayDays - realModel.runwayDays;
      final better = deltaDays > 0;

      return _simulationPanel(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _tile(
                    l10n.simRunway,
                    simModel.runwayIsKnown
                        ? fmtRunway(simModel.runwayMonths)
                        : '—',
                    simModel.runwayIsKnown
                        ? runwayColor(simModel.runwayStatus)
                        : AppColors.textSecondary,
                  ),
                ),
                if (!unlimited && deltaDays != 0) ...[
                  Icon(
                    better
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: better ? AppColors.green : AppColors.red,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              unlimited
                  ? l10n.runwayUnlimitedHere
                  : _deltaLabel(l10n, deltaDays),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: unlimited
                    ? AppColors.green
                    : deltaDays == 0
                    ? AppColors.textSecondary
                    : (better ? AppColors.green : AppColors.red),
              ),
            ),
          ],
        ),
      );
    }

    return _simulationPanel(
      icon: Icons.science_outlined,
      child: Text(
        l10n.enterValuesToSim,
        style: AppTextStyles.bodySmall,
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Says the change at the precision the decision needs: days under a
  /// month, months above it, and nothing at all when there is no change.
  String _deltaLabel(AppLocalizations l10n, int deltaDays) {
    if (deltaDays == 0) return l10n.runwayNoChange;
    final days = deltaDays.abs();
    if (days < 30) {
      return deltaDays > 0
          ? l10n.deltaDaysLonger(days)
          : l10n.deltaDaysShorter(days);
    }
    final months = days ~/ 30;
    return deltaDays > 0
        ? l10n.deltaMonthsLonger(months)
        : l10n.deltaMonthsShorter(months);
  }

  Widget _simulationPanel({IconData? icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.textDim, size: 24),
            const SizedBox(height: AppSpacing.sm),
          ],
          child,
        ],
      ),
    );
  }
}

class _SimInput extends StatefulWidget {
  final String label;
  final String hint;
  final String? initialValue;
  final int resetVersion;
  final bool focusOnReset;
  final ValueChanged<String> onChanged;

  const _SimInput({
    required this.label,
    required this.hint,
    this.initialValue,
    required this.resetVersion,
    required this.focusOnReset,
    required this.onChanged,
  });

  @override
  State<_SimInput> createState() => _SimInputState();
}

class _SimInputState extends State<_SimInput> {
  late TextEditingController _ctrl;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue ?? '');
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _SimInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resetVersion != oldWidget.resetVersion) {
      _ctrl.text = widget.initialValue ?? '';
      if (widget.focusOnReset) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _focusNode.requestFocus();
        });
      }
      return;
    }
    // A cleared field reads as "no change", which resolves back to the
    // starting value; writing that into a field being typed in would snap
    // the user's deletion straight back.
    if (_focusNode.hasFocus) return;
    final value = widget.initialValue ?? '';
    if (value != _ctrl.text) {
      _ctrl.text = value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NeoInput(
      label: widget.label,
      controller: _ctrl,
      focusNode: _focusNode,
      inputType: NeoInputType.decimal,
      hint: widget.hint,
      onChanged: widget.onChanged,
    );
  }
}
