import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'legacy_financial_preferences.dart';
import 'repository_provider.dart';

final runwayGoalProvider =
    AsyncNotifierProvider<RunwayGoalNotifier, RunwayGoal?>(
      RunwayGoalNotifier.new,
    );

class RunwayGoalNotifier extends AsyncNotifier<RunwayGoal?> {
  @override
  Future<RunwayGoal?> build() async {
    await ref.watch(legacyFinancialPreferencesMigrationProvider.future);
    return ref.watch(financialSettingsRepositoryProvider).getRunwayGoal();
  }

  Future<void> saveGoal({
    required String name,
    required int targetMonths,
    DateTime? targetDate,
  }) async {
    if (targetMonths <= 0) return;
    final existing = state.value;
    final goal = RunwayGoal(
      id: existing?.id ?? const Uuid().v4(),
      name: name.trim().isEmpty ? 'Runway goal' : name.trim(),
      targetMonths: targetMonths,
      targetDate: targetDate,
    );
    await ref.read(financialSettingsRepositoryProvider).saveRunwayGoal(goal);
    state = AsyncData(goal);
  }

  Future<void> clearGoal() async {
    await ref.read(financialSettingsRepositoryProvider).saveRunwayGoal(null);
    state = const AsyncData(null);
  }
}
