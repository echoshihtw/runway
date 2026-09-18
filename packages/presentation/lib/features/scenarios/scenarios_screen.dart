import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import '../../product_config.dart';
import '../../shared/pro_gate.dart';
import '../../shared/status_color.dart';
import 'package:domain/domain.dart';
import 'package:intl/intl.dart';

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

    String fmt(double v) => '$symbol ${nf.format(v.abs())}';
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
                          fmtRunway(realModel.runwayMonths),
                          runwayColor(realModel.runwayStatus),
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
                          fmt(realModel.currentCash),
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
                    initialValue: (scenario.burnRateOverride ?? variableBurn)
                        ?.toStringAsFixed(0),
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
                    initialValue: scenario.simulatedIncome?.toStringAsFixed(0),
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
                    l10n: l10n,
                    scenario: scenario,
                    realModel: realModel,
                    simModel: simModel,
                    fmtRunway: fmtRunway,
                    runwayColor: runwayColor,
                  ),
                  if (canRun) ...[
                    const SizedBox(height: AppSpacing.md),
                    NeoButton(
                      label: 'RUN SIMULATION',
                      variant: NeoButtonVariant.primary,
                      fullWidth: true,
                      onPressed: () {
                        if (!allowsSimulation(context, ref)) return;
                        ref.read(scenarioProvider.notifier).activate();
                      },
                    ),
                  ],
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
    required AppLocalizations l10n,
    required ScenarioState scenario,
    required ModelState realModel,
    required ModelState? simModel,
    required String Function(int) fmtRunway,
    required Color Function(RunwayStatus) runwayColor,
  }) {
    if (realModel.currentCash == 0) {
      return _simulationPanel(
        icon: Icons.account_balance_wallet_outlined,
        child: Column(
          children: [
            Text(
              'Add your opening balance first',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Go to LOG → + ADD → Opening Balance',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
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
      final isImproved = simModel.runwayMonths >= realModel.runwayMonths;
      final delta = simModel.runwayMonths - realModel.runwayMonths;

      return _simulationPanel(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _tile(
                    l10n.simRunway,
                    fmtRunway(simModel.runwayMonths),
                    runwayColor(simModel.runwayStatus),
                  ),
                ),
                Icon(
                  isImproved
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: isImproved ? AppColors.green : AppColors.red,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${delta > 0 ? "+" : ""}$delta MO',
                  style: AppTextStyles.metricSmall.copyWith(
                    color: isImproved ? AppColors.green : AppColors.red,
                  ),
                ),
              ],
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
      inputType: NeoInputType.numeric,
      hint: widget.hint,
      onChanged: widget.onChanged,
    );
  }
}
