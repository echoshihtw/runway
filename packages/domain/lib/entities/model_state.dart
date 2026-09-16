import '../enums/survival_status.dart';

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
  /// Three to six months of cover is the widely used adequacy range, so
  /// caution sits there and anything above six reads as stable.
  SurvivalStatus get survivalStatus => switch (runwayMonths) {
    >= 6 => SurvivalStatus.stable,
    >= 3 => SurvivalStatus.caution,
    _ => SurvivalStatus.critical,
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
