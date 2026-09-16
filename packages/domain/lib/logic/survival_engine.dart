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
  );
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
