import 'dart:convert';

import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stands in for the encrypted database.
class _InMemorySettingsRepository implements FinancialSettingsRepository {
  Budget budget = const Budget();
  FinancialAssumptions assumptions = const FinancialAssumptions();
  RunwayGoal? goal;

  @override
  Future<Budget> getBudget() async => budget;

  @override
  Future<void> saveBudget(Budget value) async => budget = value;

  @override
  Future<FinancialAssumptions> getFinancialAssumptions() async => assumptions;

  @override
  Future<void> saveFinancialAssumptions(FinancialAssumptions value) async =>
      assumptions = value;

  @override
  Future<RunwayGoal?> getRunwayGoal() async => goal;

  @override
  Future<void> saveRunwayGoal(RunwayGoal? value) async => goal = value;
}

ProviderContainer _container(FinancialSettingsRepository repository) {
  final container = ProviderContainer(
    overrides: [
      financialSettingsRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  late _InMemorySettingsRepository repository;

  setUp(() {
    repository = _InMemorySettingsRepository();
    SharedPreferences.setMockInitialValues({});
  });

  group('legacy preference migration', () {
    test('moves all five values into the repository and removes them', () async {
      SharedPreferences.setMockInitialValues({
        'budget_rent': 1200.0,
        'budget_living': 800.0,
        'assumptions_expected_monthly_inflow': 3000.0,
        'assumptions_expected_monthly_burn': 2100.0,
        'runway_goal': jsonEncode(
          const RunwayGoal(id: 'goal-1', name: 'Trip', targetMonths: 6).toJson(),
        ),
        'onboarding_done': true,
        'currency': 'JPY',
      });
      final container = _container(repository);

      final budget = await container.read(budgetProvider.future);
      final assumptions = await container.read(
        financialAssumptionsProvider.future,
      );
      final goal = await container.read(runwayGoalProvider.future);

      expect(budget.rent, 1200);
      expect(budget.living, 800);
      expect(assumptions.expectedMonthlyInflow, 3000);
      expect(assumptions.expectedMonthlyBurnOverride, 2100);
      expect(goal?.name, 'Trip');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), {'onboarding_done', 'currency'});
    });

    test('moves a partial set without inventing the missing values', () async {
      SharedPreferences.setMockInitialValues({
        'assumptions_expected_monthly_burn': 900.0,
      });
      final container = _container(repository);

      final assumptions = await container.read(
        financialAssumptionsProvider.future,
      );

      expect(assumptions.expectedMonthlyInflow, isNull);
      expect(assumptions.expectedMonthlyBurnOverride, 900);
      expect(repository.goal, isNull);
      expect(repository.budget.isSet, isFalse);
    });

    test('drops an unreadable goal and still removes the keys', () async {
      SharedPreferences.setMockInitialValues({
        'budget_rent': 500.0,
        'runway_goal': '{not json',
      });
      final container = _container(repository);

      expect(await container.read(runwayGoalProvider.future), isNull);
      expect((await container.read(budgetProvider.future)).rent, 500);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), isEmpty);
    });

    test('does not overwrite database values when nothing is left to move', () async {
      repository.budget = const Budget(rent: 1500, living: 600);
      final container = _container(repository);

      final budget = await container.read(budgetProvider.future);

      expect(budget.rent, 1500);
      expect(budget.living, 600);
    });
  });

  group('writes go to the repository', () {
    test('budget rent, living and clear', () async {
      final container = _container(repository);
      await container.read(budgetProvider.future);

      await container.read(budgetProvider.notifier).setRent(1100);
      await container.read(budgetProvider.notifier).setLiving(700);
      expect(repository.budget.rent, 1100);
      expect(repository.budget.living, 700);

      await container.read(budgetProvider.notifier).clear();
      expect(repository.budget.isSet, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), isEmpty);
    });

    test('assumptions treat zero or negative values as not set', () async {
      final container = _container(repository);
      await container.read(financialAssumptionsProvider.future);

      await container
          .read(financialAssumptionsProvider.notifier)
          .save(expectedMonthlyInflow: 0, expectedMonthlyBurnOverride: 1800);

      expect(repository.assumptions.expectedMonthlyInflow, isNull);
      expect(repository.assumptions.expectedMonthlyBurnOverride, 1800);
      expect(
        container.read(financialAssumptionsProvider).value?.expectedMonthlyInflow,
        isNull,
      );
    });

    test('goal save keeps its id across edits, and clear removes it', () async {
      final container = _container(repository);
      await container.read(runwayGoalProvider.future);
      final notifier = container.read(runwayGoalProvider.notifier);

      await notifier.saveGoal(name: 'Trip', targetMonths: 6);
      final firstId = repository.goal?.id;
      await notifier.saveGoal(name: 'Longer trip', targetMonths: 9);

      expect(repository.goal?.id, firstId);
      expect(repository.goal?.targetMonths, 9);

      await notifier.clearGoal();
      expect(repository.goal, isNull);
    });
  });
}
