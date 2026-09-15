import 'package:application/application.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

ProviderContainer _container() {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('free users get three simulations, then need Pro', () {
    expect(kFreeSimulations, 3);
    for (final run in [0, 1, 2]) {
      expect(needsProForSimulation(isPro: false, simulationsRun: run), isFalse);
    }
    expect(needsProForSimulation(isPro: false, simulationsRun: 3), isTrue);
    expect(needsProForSimulation(isPro: true, simulationsRun: 50), isFalse);
  });

  test('the count starts at zero and survives a restart', () async {
    final first = _container();
    expect(await first.read(simulationCountProvider.future), 0);

    await first.read(simulationCountProvider.notifier).increment();
    await first.read(simulationCountProvider.notifier).increment();
    expect(first.read(simulationCountProvider).value, 2);

    final afterRestart = _container();
    expect(await afterRestart.read(simulationCountProvider.future), 2);
  });

  test('running a simulation adds one to the count', () async {
    final container = _container();
    final keepAlive = container.listen(simulationCountProvider, (_, __) {});
    addTearDown(keepAlive.close);
    await container.read(simulationCountProvider.future);

    container.read(scenarioProvider.notifier).setBurnRateOverride(20000);
    await container.read(scenarioProvider.notifier).activate();

    expect(container.read(scenarioProvider).isActive, isTrue);
    expect(container.read(simulationCountProvider).value, 1);
  });
}
