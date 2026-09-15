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
  final fixed = burn.loanPayments + burn.subscriptions;

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
    pressureRatio: burn.typicalSpending > 0
        ? fixed / burn.typicalSpending
        : 0.0,
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
