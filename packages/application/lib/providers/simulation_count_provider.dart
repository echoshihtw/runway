import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/simulation_count_store.dart';

/// Simulations a free user can run before the Pro paywall.
const kFreeSimulations = 3;

/// Whether running another simulation needs Pro.
bool needsProForSimulation({required bool isPro, required int simulationsRun}) =>
    !isPro && simulationsRun >= kFreeSimulations;

/// Overridden in main.dart with the Keychain-backed store.
final simulationCountStoreProvider = Provider<SimulationCountStore>((ref) {
  throw UnimplementedError(
    'simulationCountStoreProvider must be overridden in main.dart',
  );
});

/// How many simulations have been run on this device.
class SimulationCountNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() => ref.watch(simulationCountStoreProvider).read();

  Future<void> increment() async {
    final store = ref.read(simulationCountStoreProvider);
    final next = await store.read() + 1;
    await store.write(next);
    state = AsyncData(next);
  }
}

final simulationCountProvider =
    AsyncNotifierProvider<SimulationCountNotifier, int>(
      SimulationCountNotifier.new,
    );
