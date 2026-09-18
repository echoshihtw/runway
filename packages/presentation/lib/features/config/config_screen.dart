import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'package:intl/intl.dart';

import 'widgets/delete_all_data_card.dart';

class ConfigScreen extends ConsumerStatefulWidget {
  const ConfigScreen({super.key});

  @override
  ConsumerState<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends ConsumerState<ConfigScreen> {
  final _rentCtrl = TextEditingController();
  final _livingCtrl = TextEditingController();
  final _goalNameCtrl = TextEditingController();
  final _goalMonthsCtrl = TextEditingController();
  final _expectedInflowCtrl = TextEditingController();
  final _expectedBurnCtrl = TextEditingController();
  bool _editingBudget = false;
  bool _editingGoal = false;
  bool _editingAssumptions = false;

  static const _languages = [
    (label: 'ENGLISH', locale: Locale('en')),
    (label: '繁中', locale: Locale('zh', 'TW')),
    (label: 'FRANÇAIS', locale: Locale('fr')),
    (label: '日本語', locale: Locale('ja')),
    (label: 'ESPAÑOL', locale: Locale('es')),
    (label: 'ITALIANO', locale: Locale('it')),
  ];

  @override
  void dispose() {
    _rentCtrl.dispose();
    _livingCtrl.dispose();
    _goalNameCtrl.dispose();
    _goalMonthsCtrl.dispose();
    _expectedInflowCtrl.dispose();
    _expectedBurnCtrl.dispose();
    super.dispose();
  }

  void _startEditing(Budget budget) {
    _rentCtrl.text = budget.rent > 0 ? budget.rent.toStringAsFixed(0) : '';
    _livingCtrl.text = budget.living > 0
        ? budget.living.toStringAsFixed(0)
        : '';
    setState(() => _editingBudget = true);
  }

  Future<void> _saveBudget() async {
    final rent = double.tryParse(_rentCtrl.text.trim()) ?? 0;
    final living = double.tryParse(_livingCtrl.text.trim()) ?? 0;
    await ref.read(budgetProvider.notifier).setRent(rent);
    await ref.read(budgetProvider.notifier).setLiving(living);
    setState(() => _editingBudget = false);
    FocusScope.of(context).unfocus();
  }

  Future<void> _clearBudget() async {
    await ref.read(budgetProvider.notifier).clear();
    _rentCtrl.clear();
    _livingCtrl.clear();
    setState(() => _editingBudget = false);
    FocusScope.of(context).unfocus();
  }

  void _startEditingGoal(RunwayGoal? goal) {
    _goalNameCtrl.text = goal?.name ?? '';
    _goalMonthsCtrl.text = goal?.targetMonths.toString() ?? '';
    setState(() => _editingGoal = true);
  }

  Future<void> _saveGoal() async {
    final targetMonths = int.tryParse(_goalMonthsCtrl.text.trim());
    if (targetMonths == null || targetMonths <= 0) return;
    await ref
        .read(runwayGoalProvider.notifier)
        .saveGoal(name: _goalNameCtrl.text, targetMonths: targetMonths);
    setState(() => _editingGoal = false);
    FocusScope.of(context).unfocus();
  }

  Future<void> _clearGoal() async {
    await ref.read(runwayGoalProvider.notifier).clearGoal();
    _goalNameCtrl.clear();
    _goalMonthsCtrl.clear();
    setState(() => _editingGoal = false);
    FocusScope.of(context).unfocus();
  }

  void _startEditingAssumptions(FinancialAssumptions assumptions) {
    _expectedInflowCtrl.text = assumptions.expectedMonthlyInflow == null
        ? ''
        : assumptions.expectedMonthlyInflow!.toStringAsFixed(0);
    _expectedBurnCtrl.text = assumptions.expectedMonthlyBurnOverride == null
        ? ''
        : assumptions.expectedMonthlyBurnOverride!.toStringAsFixed(0);
    setState(() => _editingAssumptions = true);
  }

  Future<void> _saveAssumptions() async {
    final expectedInflow = double.tryParse(_expectedInflowCtrl.text.trim());
    final expectedBurn = double.tryParse(_expectedBurnCtrl.text.trim());
    await ref
        .read(financialAssumptionsProvider.notifier)
        .save(
          expectedMonthlyInflow: expectedInflow,
          expectedMonthlyBurnOverride: expectedBurn,
        );
    setState(() => _editingAssumptions = false);
    FocusScope.of(context).unfocus();
  }

  Future<void> _clearAssumptions() async {
    await ref.read(financialAssumptionsProvider.notifier).clear();
    _expectedInflowCtrl.clear();
    _expectedBurnCtrl.clear();
    setState(() => _editingAssumptions = false);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeAsync = ref.watch(localeProvider);
    final currAsync = ref.watch(currencyProvider);
    final budgetAsync = ref.watch(budgetProvider);
    final subCost = ref.watch(subscriptionMonthlyTotalProvider);
    final debtCost = ref.watch(totalMonthlyLoanPaymentProvider);
    final goalAsync = ref.watch(runwayGoalProvider);
    final assumptionsAsync = ref.watch(financialAssumptionsProvider);

    // Null means the read has not succeeded: still running, or failed. These
    // used to fall back to the defaults, which rendered as "Not set" beside an
    // EDIT button — and saving that form wrote the defaults over the real
    // values. Unknown is not the same as unset.
    final runwayGoal = goalAsync.value;
    final assumptions = assumptionsAsync.value;
    final currentLocale = localeAsync.value;
    final currentCurr = currAsync.value;
    final budget = budgetAsync.value;
    final symbol = currentCurr?.symbol ?? '¥';
    final nf = NumberFormat('#,##0', 'en_US');

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientBackground),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.config,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.cardBorder, height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── FORECAST ──────────────────────
                    NeoCard(
                      title: l10n.futureAssumptions,
                      accentColor: AppColors.blue,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (assumptions == null) ...[
                            _Unavailable(assumptionsAsync),
                          ] else if (!_editingAssumptions) ...[
                            _budgetRow(
                              l10n.expectedInflow,
                              assumptions.expectedMonthlyInflow == null
                                  ? l10n.notSet
                                  : '$symbol ${nf.format(assumptions.expectedMonthlyInflow)}',
                              AppColors.green,
                            ),
                            _budgetRow(
                              l10n.expectedBurn,
                              assumptions.expectedMonthlyBurnOverride == null
                                  ? l10n.usingCurrentBurn
                                  : '$symbol ${nf.format(assumptions.expectedMonthlyBurnOverride)}',
                              AppColors.red,
                            ),
                            if (assumptions.expectedMonthlyBurnOverride !=
                                null)
                              Text(
                                l10n.computedCost(
                                  '$symbol ${nf.format(ref.watch(monthlyBurnProvider).total)}',
                                ),
                                style: AppTextStyles.caption,
                              ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (assumptions.hasExpectedMonthlyInflow ||
                                    assumptions
                                        .hasExpectedMonthlyBurnOverride) ...[
                                  NeoButton(
                                    label: l10n.clear,
                                    variant: NeoButtonVariant.danger,
                                    onPressed: _clearAssumptions,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                ],
                                NeoButton(
                                  label:
                                      assumptions.hasExpectedMonthlyInflow ||
                                          assumptions
                                              .hasExpectedMonthlyBurnOverride
                                      ? l10n.edit
                                      : l10n.setAssumptions,
                                  variant: NeoButtonVariant.secondary,
                                  onPressed: () =>
                                      _startEditingAssumptions(assumptions),
                                ),
                              ],
                            ),
                          ] else ...[
                            NeoInput(
                              label: l10n.expectedMonthlyInflow,
                              controller: _expectedInflowCtrl,
                              keyboardType: TextInputType.number,
                              hint: '0',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            NeoInput(
                              label: l10n.expectedMonthlyBurn,
                              controller: _expectedBurnCtrl,
                              keyboardType: TextInputType.number,
                              hint: l10n.useCurrentBurn,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.futureInflowHint,
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: NeoButton(
                                    label: l10n.save,
                                    variant: NeoButtonVariant.primary,
                                    fullWidth: true,
                                    onPressed: _saveAssumptions,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: NeoButton(
                                    label: l10n.cancel,
                                    variant: NeoButtonVariant.ghost,
                                    fullWidth: true,
                                    onPressed: () => setState(
                                      () => _editingAssumptions = false,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.cardGap),

                    // ── MONTHLY BUDGET ────────────────
                    NeoCard(
                      title: l10n.monthlyBudget,
                      accentColor: AppColors.green,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (budget == null) ...[
                            _Unavailable(budgetAsync),
                          ] else if (!_editingBudget) ...[
                            if (budget.isSet) ...[
                              _budgetRow(
                                l10n.rentFixed,
                                '$symbol ${nf.format(budget.rent)}',
                                AppColors.textPrimary,
                              ),
                              _budgetRow(
                                l10n.livingExpenses,
                                '$symbol ${nf.format(budget.living)}',
                                AppColors.textPrimary,
                              ),
                              const Divider(
                                color: AppColors.cardBorder,
                                height: AppSpacing.lg,
                              ),
                              _budgetRow(
                                l10n.subtotal,
                                '$symbol ${nf.format(budget.subtotal)}',
                                AppColors.green,
                              ),
                            ] else ...[
                              Text(l10n.notSet, style: AppTextStyles.caption),
                              const SizedBox(height: AppSpacing.xs),
                            ],
                            _budgetRow(
                              '+ ${l10n.subscriptions}',
                              '$symbol ${nf.format(subCost)}',
                              AppColors.purple,
                            ),
                            _budgetRow(
                              '+ ${l10n.loanPerMonth}',
                              '$symbol ${nf.format(debtCost)}',
                              AppColors.gold,
                            ),
                            const Divider(
                              color: AppColors.cardBorder,
                              height: AppSpacing.lg,
                            ),
                            _budgetRow(
                              l10n.totalBudgetPerMonth,
                              '$symbol ${nf.format(budget.subtotal + subCost + debtCost)}',
                              AppColors.red,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                NeoButton(
                                  label: budget.isSet
                                      ? l10n.edit
                                      : l10n.setBudget,
                                  variant: NeoButtonVariant.secondary,
                                  onPressed: () => _startEditing(budget),
                                ),
                              ],
                            ),
                          ] else ...[
                            NeoInput(
                              label: l10n.rentFixedCosts,
                              controller: _rentCtrl,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            NeoInput(
                              label: l10n.livingExpenses,
                              controller: _livingCtrl,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.subscrDebtAuto,
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: NeoButton(
                                    label: l10n.save,
                                    variant: NeoButtonVariant.primary,
                                    fullWidth: true,
                                    onPressed: _saveBudget,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: NeoButton(
                                    label: l10n.clear,
                                    variant: NeoButtonVariant.danger,
                                    fullWidth: true,
                                    onPressed: _clearBudget,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.cardGap),

                    NeoCard(
                      title: l10n.runwayGoal,
                      accentColor: AppColors.turkishBlue,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!goalAsync.hasValue) ...[
                            _Unavailable(goalAsync),
                          ] else if (!_editingGoal) ...[
                            if (runwayGoal != null) ...[
                              _budgetRow(
                                l10n.goal,
                                runwayGoal.name,
                                AppColors.textPrimary,
                              ),
                              _budgetRow(
                                l10n.target,
                                l10n.monthsValue(runwayGoal.targetMonths),
                                AppColors.green,
                              ),
                            ],
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.goalsContextHint,
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (runwayGoal != null) ...[
                                  NeoButton(
                                    label: l10n.clear,
                                    variant: NeoButtonVariant.danger,
                                    onPressed: _clearGoal,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                ],
                                NeoButton(
                                  label: runwayGoal == null
                                      ? l10n.setGoal
                                      : l10n.edit,
                                  variant: NeoButtonVariant.secondary,
                                  onPressed: () =>
                                      _startEditingGoal(runwayGoal),
                                ),
                              ],
                            ),
                          ] else ...[
                            NeoInput(
                              label: l10n.goalName,
                              controller: _goalNameCtrl,
                              hint: 'Paris Study',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            NeoInput(
                              label: l10n.targetMonths,
                              controller: _goalMonthsCtrl,
                              keyboardType: TextInputType.number,
                              hint: '24',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: NeoButton(
                                    label: l10n.save,
                                    variant: NeoButtonVariant.primary,
                                    fullWidth: true,
                                    onPressed: _saveGoal,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: NeoButton(
                                    label: l10n.cancel,
                                    variant: NeoButtonVariant.ghost,
                                    fullWidth: true,
                                    onPressed: () =>
                                        setState(() => _editingGoal = false),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.cardGap),

                    // ── LANGUAGE ──────────────────────
                    NeoCard(
                      title: l10n.language,
                      accentColor: AppColors.purple,
                      child: Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: _languages.map((lang) {
                          final active =
                              currentLocale?.languageCode ==
                                  lang.locale.languageCode &&
                              (lang.locale.countryCode == null ||
                                  currentLocale?.countryCode ==
                                      lang.locale.countryCode);
                          return GestureDetector(
                            onTap: () => ref
                                .read(localeProvider.notifier)
                                .setLocale(lang.locale),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? AppColors.purple.withAlpha(20)
                                    : AppColors.surfaceHigh,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: active
                                      ? AppColors.purple
                                      : AppColors.cardBorder,
                                  width: active ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                lang.label,
                                style: AppTextStyles.button.copyWith(
                                  color: active
                                      ? AppColors.purple
                                      : AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.cardGap),

                    // ── CURRENCY ──────────────────────
                    NeoCard(
                      title: l10n.currency,
                      accentColor: AppColors.gold,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: supportedCurrencies.map((curr) {
                          final active = currentCurr?.code == curr.code;
                          return GestureDetector(
                            onTap: () => ref
                                .read(currencyProvider.notifier)
                                .setCurrency(curr),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? AppColors.gold.withAlpha(20)
                                    : AppColors.surfaceHigh,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: active
                                      ? AppColors.gold
                                      : AppColors.cardBorder,
                                  width: active ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                '${curr.symbol}  ${curr.code}',
                                style: AppTextStyles.button.copyWith(
                                  color: active
                                      ? AppColors.gold
                                      : AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.currencySymbolOnly,
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.cardGap),

                    // ── YOUR DATA ─────────────────────
                    const DeleteAllDataCard(),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _budgetRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.metricSmall.copyWith(color: color),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// What a card shows in place of its settings while their read has not
/// succeeded. Editing is withheld in both states: a form seeded from nothing
/// saves nothing over whatever is really stored, and Riverpod retries a
/// failing read for about 38 seconds before it errors, so "loading" is the
/// state for the whole first half-minute on a database that will not open.
class _Unavailable extends StatelessWidget {
  final AsyncValue<Object?> value;

  const _Unavailable(this.value);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        value.isLoading ? l10n.loading : l10n.settingsFailedToLoad,
        style: AppTextStyles.caption,
      ),
    );
  }
}
