import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/scenario_state.dart';
import 'simulation_count_provider.dart';

class ScenarioNotifier extends Notifier<ScenarioState> {
  int _calculationId = 0;

  @override
  ScenarioState build() => const ScenarioState();

  Future<void> activate() async {
    final calculationId = ++_calculationId;
    // Show calculating state
    state = state.copyWith(isCalculating: true);
    // Brief pause for UX feel
    await Future.delayed(const Duration(milliseconds: 800));
    if (calculationId != _calculationId) return;
    // Show result
    state = state.copyWith(isActive: true, isCalculating: false);
    await ref.read(simulationCountProvider.notifier).increment();
  }

  void setBurnRateOverride(double? value) {
    state = ScenarioState(
      burnRateOverride: value,
      simulatedIncome: state.simulatedIncome,
      isActive: false,
      isCalculating: false,
      resetVersion: state.resetVersion,
    );
  }

  void setSimulatedIncome(double? value) {
    state = ScenarioState(
      burnRateOverride: state.burnRateOverride,
      simulatedIncome: value,
      isActive: false,
      isCalculating: false,
      resetVersion: state.resetVersion,
    );
  }

  void reset() {
    _calculationId++;
    state = ScenarioState(
      burnRateOverride: null,
      simulatedIncome: null,
      isActive: false,
      isCalculating: false,
      resetVersion: state.resetVersion + 1,
    );
  }
}

final scenarioProvider = NotifierProvider<ScenarioNotifier, ScenarioState>(
  ScenarioNotifier.new,
);
