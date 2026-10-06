double calculateRunwayGoalProgress({
  required double runwayMonths,
  required int targetMonths,
}) {
  if (runwayMonths >= 9999) return 1.0;
  if (targetMonths <= 0) return 0.0;

  return (runwayMonths / targetMonths).clamp(0.0, 1.0);
}

int calculateRunwayGoalProgressPercent({
  required double runwayMonths,
  required int targetMonths,
}) {
  return (calculateRunwayGoalProgress(
            runwayMonths: runwayMonths,
            targetMonths: targetMonths,
          ) *
          100)
      .round();
}

/// The cash a goal stated in months actually asks for.
///
/// A target of twenty-four months is twenty-four times what a month costs.
/// Without it the bar drew an unfilled half with no size, so there was nothing
/// on the card a person could act on.
///
/// Null when a month costs nothing, because the figure is then unknowable
/// rather than zero — the same reason the runway itself reads as unknown
/// without a cost basis.
double? runwayGoalCashTarget({
  required int targetMonths,
  required double monthlyCost,
}) {
  if (targetMonths <= 0 || monthlyCost <= 0) return null;
  return targetMonths * monthlyCost;
}

/// What is left to put aside to reach [targetMonths] of cover, or null when
/// the target itself is unknowable. Never negative: a goal already met has
/// nothing left to go.
double? runwayGoalCashToGo({
  required int targetMonths,
  required double monthlyCost,
  required double currentCash,
}) {
  final target = runwayGoalCashTarget(
    targetMonths: targetMonths,
    monthlyCost: monthlyCost,
  );
  if (target == null) return null;
  final remaining = target - currentCash;
  return remaining > 0 ? remaining : 0;
}
