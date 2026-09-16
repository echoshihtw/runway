import '../enums/runway_status.dart';

class ModelState {
  final double currentCash;
  final double burnRate;
  final double effectiveBurnRate;
  final double monthlyPayment;
  final double subscriptionMonthlyCost;
  final double? expectedMonthlyInflow;
  final double? expectedMonthlyBurnOverride;
  final int runwayMonths;
  final int runwayDays;
  final DateTime? runOutDate;

  /// Whether a monthly cost is known at all.
  ///
  /// A cost of zero is not a free life: it means nothing has been budgeted,
  /// logged, or committed yet. Dividing cash by it produced an unlimited
  /// runway, so a user who had only entered their cash — exactly what
  /// onboarding asks for — was told their money lasts for ever. Defaults to
  /// true so only the engines decide it.
  final bool hasCostBasis;

  const ModelState({
    required this.currentCash,
    required this.burnRate,
    required this.effectiveBurnRate,
    required this.monthlyPayment,
    required this.subscriptionMonthlyCost,
    this.expectedMonthlyInflow,
    this.expectedMonthlyBurnOverride,
    required this.runwayMonths,
    required this.runwayDays,
    this.runOutDate,
    this.hasCostBasis = true,
  });

  double get totalMonthlyOutflow => effectiveBurnRate;
  double get emergencyMonthlyBurn => effectiveBurnRate;
  double get sustainableNetMonthlyFlow =>
      (expectedMonthlyInflow ?? 0) - emergencyMonthlyBurn;
  bool get hasSustainableProjection => expectedMonthlyInflow != null;
  bool get isSustainableIndefinitely =>
      hasSustainableProjection && sustainableNetMonthlyFlow >= 0;
  double get sustainableMonthlyShortfall =>
      sustainableNetMonthlyFlow < 0 ? sustainableNetMonthlyFlow.abs() : 0.0;
  /// Whether the runway can be stated at all. When no cost is known the
  /// number is unknown, which is different from unlimited: a scenario whose
  /// simulated income covers its costs is genuinely unlimited and keeps a
  /// cost basis.
  bool get runwayIsKnown => hasCostBasis;

  /// Three to six months of cover is the widely used adequacy range, so
  /// caution sits there and anything above six reads as stable.
  RunwayStatus get runwayStatus => switch (runwayMonths) {
    >= 6 => RunwayStatus.stable,
    >= 3 => RunwayStatus.caution,
    _ => RunwayStatus.critical,
  };

  static ModelState empty() => ModelState(
    currentCash: 0,
    burnRate: 0,
    effectiveBurnRate: 0,
    monthlyPayment: 0,
    subscriptionMonthlyCost: 0,
    expectedMonthlyInflow: null,
    expectedMonthlyBurnOverride: null,
    runwayMonths: 0,
    runwayDays: 0,
    runOutDate: null,
  );
}
