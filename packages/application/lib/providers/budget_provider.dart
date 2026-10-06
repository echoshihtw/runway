import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'legacy_financial_preferences.dart';
import 'repository_provider.dart';

class BudgetNotifier extends AsyncNotifier<Budget> {
  @override
  Future<Budget> build() async {
    await ref.watch(legacyFinancialPreferencesMigrationProvider.future);
    return ref.watch(financialSettingsRepositoryProvider).getBudget();
  }

  Future<void> setRent(double value) => _save(_stored.copyWith(rent: value));

  Future<void> setLiving(double value) =>
      _save(_stored.copyWith(living: value));

  Future<void> clear() {
    // Erasing what was never shown is still writing blind.
    if (state.value == null) {
      throw StateError('Refusing to clear a budget that was never read.');
    }
    return _save(const Budget());
  }

  /// The budget as last read. Null while the first read is still running or
  /// after it failed — and in both cases we do not know what is on disk.
  ///
  /// This used to fall back to `const Budget()`, so after a failed read
  /// `setRent(1100)` wrote `Budget(rent: 1100, living: 0)` over the real
  /// living budget. Riverpod retries a failing build for about 38 seconds
  /// before it errors, so that was the state for the whole first half-minute
  /// on a database that would not open.
  Budget get _stored =>
      state.value ??
      (throw StateError('Refusing to write a budget that was never read.'));

  Future<void> _save(Budget budget) async {
    await ref.read(financialSettingsRepositoryProvider).saveBudget(budget);
    state = AsyncData(budget);
  }
}

final budgetProvider = AsyncNotifierProvider<BudgetNotifier, Budget>(
  BudgetNotifier.new,
);
