import 'dart:math' as math;

import '../entities/model_state.dart';
import 'burn_engine.dart';

const _unlimitedMonths = 9999;
const _unlimitedDays = 99999;

/// The model shown on the dashboard.
///
/// An expected burn override replaces [MonthlyBurn.total] and is spread
/// evenly over what is left of this month.
ModelState computeModel({
  required double currentCash,
  required MonthlyBurn burn,
  double? expectedMonthlyInflow,
  double? expectedMonthlyBurnOverride,
  bool cashIsKnown = true,
}) {
  final override =
      expectedMonthlyBurnOverride != null && expectedMonthlyBurnOverride > 0
      ? expectedMonthlyBurnOverride
      : null;
  return modelForMonthlyBurn(
    currentCash: currentCash,
    burn: burn,
    monthlyBurn: override ?? burn.total,
    dueThisMonth: override == null
        ? burn.dueThisMonth
        : override * burn.fractionOfMonthLeft,
    expectedMonthlyInflow: expectedMonthlyInflow,
    expectedMonthlyBurnOverride: expectedMonthlyBurnOverride,
    hasCostBasis: (override ?? burn.total) > 0,
    basis: _basisFor(burn, override),
    cashIsKnown: cashIsKnown,
  );
}

/// An assumption replaces the computed cost outright. Otherwise the variable
/// part is the budget until logged spending overtakes it, which is exactly
/// when [BudgetBucket.monthlyEstimate] switches to spending.
RunwayBasis _basisFor(MonthlyBurn burn, double? assumption) {
  if (assumption != null) return RunwayBasis.assumption;
  final spending = burn.typicalSpending;
  if (spending > 0 && burn.variableBurn <= spending) {
    return RunwayBasis.spending;
  }
  return RunwayBasis.budget;
}

/// Builds the model for a given [monthlyBurn], so the dashboard and the
/// simulator share one runway calculation.
ModelState modelForMonthlyBurn({
  required double currentCash,
  required MonthlyBurn burn,
  required double monthlyBurn,
  required double dueThisMonth,
  double? expectedMonthlyInflow,
  double? expectedMonthlyBurnOverride,
  bool hasCostBasis = true,
  RunwayBasis basis = RunwayBasis.budget,
  bool cashIsKnown = true,
}) {
  final runway = _runwayFromToday(
    cash: currentCash,
    dueThisMonth: dueThisMonth,
    monthlyBurn: monthlyBurn,
    burn: burn,
  );
  return ModelState(
    currentCash: currentCash,
    burnRate: burn.typicalSpending,
    effectiveBurnRate: monthlyBurn,
    monthlyPayment: burn.loanPayments,
    subscriptionMonthlyCost: burn.subscriptions,
    expectedMonthlyInflow: expectedMonthlyInflow,
    expectedMonthlyBurnOverride: expectedMonthlyBurnOverride,
    runwayMonths: runway.months.isInfinite
        ? _unlimitedMonths
        : math.min(runway.months.floor(), _unlimitedMonths),
    runwayDays: runway.months.isInfinite
        ? _unlimitedDays
        : math.min((runway.months * 30).floor(), _unlimitedDays),
    runOutDate: runway.runOutMonth,
    hasCostBasis: hasCostBasis,
    basis: basis,
    cashIsKnown: cashIsKnown,
  );
}

/// The model for a what-if on the plan screen.
///
/// Changes take effect from today. The rest of this month keeps the costs
/// already paid and applies only the difference over the days that are left,
/// so a scenario with no changes returns the dashboard's own runway.
ModelState modelForScenario({
  required double currentCash,
  required MonthlyBurn burn,
  double? monthlyCostOverride,
  double? simulatedIncome,
  double? expectedMonthlyBurnOverride,
  double? expectedMonthlyInflow,
}) {
  // The dashboard may already be running on an assumed monthly cost. Start from
  // whatever it uses, or the comparison subtracts one basis from another and a
  // scenario with no changes reports a loss.
  final assumption =
      expectedMonthlyBurnOverride != null && expectedMonthlyBurnOverride > 0
      ? expectedMonthlyBurnOverride
      : null;
  final baseMonthly = assumption ?? burn.total;
  final baseDueThisMonth = assumption != null
      ? assumption * burn.fractionOfMonthLeft
      : burn.dueThisMonth;

  // The input is a change to the variable part, so fixed costs survive it: a
  // user cutting living expenses does not silently drop a loan payment.
  final variableChange =
      (monthlyCostOverride ?? burn.variableBurn) - burn.variableBurn;
  final income = simulatedIncome ?? 0.0;

  final monthlyBurn = math.max(baseMonthly + variableChange - income, 0.0);
  final changeThisMonth =
      (variableChange - income) * burn.fractionOfMonthLeft;
  return modelForMonthlyBurn(
    currentCash: currentCash,
    burn: burn,
    monthlyBurn: monthlyBurn,
    dueThisMonth: math.max(baseDueThisMonth + changeThisMonth, 0.0),
    // The underlying cost, before income offsets it. Income covering costs is
    // a real unlimited runway, not an unknown one. The typed cost counts: a
    // scenario driven entirely by a what-if, on an owner who has set no
    // budget, still knows what it costs.
    hasCostBasis: (baseMonthly + variableChange) > 0,
    // A typed cost is the basis when there is one, whatever the dashboard is
    // running on — otherwise the scenario claims the number came from a
    // budget the owner never set.
    basis: monthlyCostOverride != null
        ? RunwayBasis.assumption
        : _basisFor(burn, assumption),
    // Carried through so the scenario reports sustainability on the same
    // footing as the dashboard. It does not move the runway: the number
    // answers what happens if income stopped today.
    expectedMonthlyInflow: expectedMonthlyInflow,
    expectedMonthlyBurnOverride: expectedMonthlyBurnOverride,
  );
}

/// How long cash lasts, measured in months from today.
///
/// The rest of this month costs [dueThisMonth] over the days that are left.
/// Every later month costs [monthlyBurn].
({double months, DateTime? runOutMonth}) _runwayFromToday({
  required double cash,
  required double dueThisMonth,
  required double monthlyBurn,
  required MonthlyBurn burn,
}) {
  final start = burn.month.value;
  final thisMonth = DateTime(start.year, start.month);
  if (cash <= 0) return (months: 0, runOutMonth: thisMonth);
  if (cash <= dueThisMonth) {
    return (
      months: burn.fractionOfMonthLeft * cash / dueThisMonth,
      runOutMonth: thisMonth,
    );
  }
  if (monthlyBurn <= 0) return (months: double.infinity, runOutMonth: null);

  final fullMonths = (cash - dueThisMonth) / monthlyBurn;
  return (
    months: burn.fractionOfMonthLeft + fullMonths,
    runOutMonth: DateTime(start.year, start.month + fullMonths.floor() + 1),
  );
}
