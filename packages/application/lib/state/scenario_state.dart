class ScenarioState {
  final double? burnRateOverride;
  final double? simulatedIncome;
  final bool isActive;
  final bool isCalculating;
  final bool hasRunSimulation;
  final int resetVersion;

  const ScenarioState({
    this.burnRateOverride,
    this.simulatedIncome,
    this.isActive = false,
    this.isCalculating = false,
    this.hasRunSimulation = false,
    this.resetVersion = 0,
  });

  /// Whether there is anything to simulate: a monthly costs override, simulated
  /// income, or both.
  bool get hasInput => burnRateOverride != null || simulatedIncome != null;

  ScenarioState copyWith({
    double? burnRateOverride,
    double? simulatedIncome,
    bool? isActive,
    bool? isCalculating,
    bool? hasRunSimulation,
    int? resetVersion,
  }) {
    return ScenarioState(
      burnRateOverride: burnRateOverride ?? this.burnRateOverride,
      simulatedIncome: simulatedIncome ?? this.simulatedIncome,
      isActive: isActive ?? this.isActive,
      isCalculating: isCalculating ?? this.isCalculating,
      hasRunSimulation: hasRunSimulation ?? this.hasRunSimulation,
      resetVersion: resetVersion ?? this.resetVersion,
    );
  }
}
