import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'legacy_financial_preferences.dart';
import 'repository_provider.dart';

final financialAssumptionsProvider =
    AsyncNotifierProvider<FinancialAssumptionsNotifier, FinancialAssumptions>(
      FinancialAssumptionsNotifier.new,
    );

class FinancialAssumptionsNotifier extends AsyncNotifier<FinancialAssumptions> {
  @override
  Future<FinancialAssumptions> build() async {
    await ref.watch(legacyFinancialPreferencesMigrationProvider.future);
    return ref
        .watch(financialSettingsRepositoryProvider)
        .getFinancialAssumptions();
  }

  /// Saves the assumptions. Zero or negative values count as not set.
  Future<void> save({
    double? expectedMonthlyInflow,
    double? expectedMonthlyBurnOverride,
  }) async {
    // The screen seeds its fields from what was read. If nothing was read the
    // fields are empty, and saving them writes nulls over the real figures.
    if (state.value == null) {
      throw StateError('Refusing to write assumptions that were never read.');
    }
    final assumptions = FinancialAssumptions(
      expectedMonthlyInflow: _positiveOrNull(expectedMonthlyInflow),
      expectedMonthlyBurnOverride: _positiveOrNull(expectedMonthlyBurnOverride),
    );
    await ref
        .read(financialSettingsRepositoryProvider)
        .saveFinancialAssumptions(assumptions);
    state = AsyncData(assumptions);
  }

  Future<void> clear() => save();

  double? _positiveOrNull(double? value) =>
      value != null && value > 0 ? value : null;
}
