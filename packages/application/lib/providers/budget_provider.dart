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

  Future<void> setRent(double value) =>
      _save((state.value ?? const Budget()).copyWith(rent: value));

  Future<void> setLiving(double value) =>
      _save((state.value ?? const Budget()).copyWith(living: value));

  Future<void> clear() => _save(const Budget());

  Future<void> _save(Budget budget) async {
    await ref.read(financialSettingsRepositoryProvider).saveBudget(budget);
    state = AsyncData(budget);
  }
}

final budgetProvider = AsyncNotifierProvider<BudgetNotifier, Budget>(
  BudgetNotifier.new,
);
