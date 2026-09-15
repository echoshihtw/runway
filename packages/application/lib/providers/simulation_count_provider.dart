import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simulations a free user can run before the Pro paywall.
const kFreeSimulations = 3;

const _kSimulationsRun = 'simulations_run';

/// Whether running another simulation needs Pro.
bool needsProForSimulation({required bool isPro, required int simulationsRun}) =>
    !isPro && simulationsRun >= kFreeSimulations;

/// How many simulations have been run on this device. Kept in preferences,
/// so the free limit and the Getting Started step survive a restart.
class SimulationCountNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kSimulationsRun) ?? 0;
  }

  Future<void> increment() async {
    final prefs = await SharedPreferences.getInstance();
    final next = (prefs.getInt(_kSimulationsRun) ?? 0) + 1;
    await prefs.setInt(_kSimulationsRun, next);
    state = AsyncData(next);
  }
}

final simulationCountProvider =
    AsyncNotifierProvider<SimulationCountNotifier, int>(
      SimulationCountNotifier.new,
    );
