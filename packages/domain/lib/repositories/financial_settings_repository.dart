import '../entities/budget.dart';
import '../entities/financial_assumptions.dart';
import '../entities/runway_goal.dart';

/// Budget, forecast assumptions and runway goal, kept with the rest of the
/// user's financial data in the encrypted database.
abstract interface class FinancialSettingsRepository {
  Future<Budget> getBudget();
  Future<void> saveBudget(Budget budget);

  Future<FinancialAssumptions> getFinancialAssumptions();
  Future<void> saveFinancialAssumptions(FinancialAssumptions assumptions);

  Future<RunwayGoal?> getRunwayGoal();

  /// Saves [goal], or removes the goal when it is null.
  Future<void> saveRunwayGoal(RunwayGoal? goal);
}
