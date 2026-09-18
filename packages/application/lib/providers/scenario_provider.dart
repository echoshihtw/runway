import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/scenario_state.dart';
import 'usage_count_provider.dart';

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
    // The result is the user's; the count is ours. The screen does not await
    // this, so a Keychain refusal used to surface as an unhandled error.
    try {
      await ref.read(simulationCountProvider.notifier).increment();
    } catch (_) {
      // Counting failed; the simulation did not.
    }
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
