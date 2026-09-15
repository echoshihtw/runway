import 'package:application/application.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for the Keychain. One instance plays the device across restarts.
class _MemoryStore implements SimulationCountStore {
  int count = 0;

  @override
  Future<int> read() async => count;

  @override
  Future<void> write(int value) async => count = value;
}

ProviderContainer _container(SimulationCountStore store) {
  final container = ProviderContainer(
    overrides: [simulationCountStoreProvider.overrideWithValue(store)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('free users get three simulations, then need Pro', () {
    expect(kFreeSimulations, 3);
    for (final run in [0, 1, 2]) {
      expect(needsProForSimulation(isPro: false, simulationsRun: run), isFalse);
    }
    expect(needsProForSimulation(isPro: false, simulationsRun: 3), isTrue);
    expect(needsProForSimulation(isPro: true, simulationsRun: 50), isFalse);
  });

  test('the count starts at zero and survives a restart', () async {
    final device = _MemoryStore();
    final first = _container(device);
    expect(await first.read(simulationCountProvider.future), 0);

    await first.read(simulationCountProvider.notifier).increment();
    await first.read(simulationCountProvider.notifier).increment();
    expect(first.read(simulationCountProvider).value, 2);

    final afterRestart = _container(device);
    expect(await afterRestart.read(simulationCountProvider.future), 2);
  });

  test('running a simulation adds one to the count', () async {
    final device = _MemoryStore();
    final container = _container(device);
    final keepAlive = container.listen(simulationCountProvider, (_, __) {});
    addTearDown(keepAlive.close);
    await container.read(simulationCountProvider.future);

    container.read(scenarioProvider.notifier).setBurnRateOverride(20000);
    await container.read(scenarioProvider.notifier).activate();

    expect(container.read(scenarioProvider).isActive, isTrue);
    expect(device.count, 1);
  });

  test('clearing preferences for Delete all data leaves the count alone', () async {
    final device = _MemoryStore()..count = 3;

    // Delete all data clears preferences and the database, never this store.
    expect(await _container(device).read(simulationCountProvider.future), 3);
  });
}
