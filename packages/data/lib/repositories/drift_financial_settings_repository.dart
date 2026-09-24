import 'package:domain/domain.dart' as domain;
import 'package:drift/drift.dart';
import '../database/app_database.dart';

class DriftFinancialSettingsRepository
    implements domain.FinancialSettingsRepository {
  final AppDatabase _db;

  const DriftFinancialSettingsRepository(this._db);

  @override
  Future<domain.Budget> getBudget() async {
    final row = await _db.financialSettingsDao.get();
    return domain.Budget(
      rent: row?.budgetRent ?? 0,
      living: row?.budgetLiving ?? 0,
    );
  }

  @override
  Future<void> saveBudget(domain.Budget budget) =>
      _db.financialSettingsDao.write(
        FinancialSettingsCompanion(
          budgetRent: Value(budget.rent),
          budgetLiving: Value(budget.living),
        ),
      );

  @override
  Future<domain.FinancialAssumptions> getFinancialAssumptions() async {
    final row = await _db.financialSettingsDao.get();
    return domain.FinancialAssumptions(
      expectedMonthlyInflow: row?.expectedMonthlyInflow,
      expectedMonthlyBurnOverride: row?.expectedMonthlyBurnOverride,
    );
  }

  @override
  Future<void> saveFinancialAssumptions(
    domain.FinancialAssumptions assumptions,
  ) => _db.financialSettingsDao.write(
    FinancialSettingsCompanion(
      expectedMonthlyInflow: Value(assumptions.expectedMonthlyInflow),
      expectedMonthlyBurnOverride: Value(
        assumptions.expectedMonthlyBurnOverride,
      ),
    ),
  );

  @override
  Future<domain.RunwayGoal?> getRunwayGoal() async {
    final row = await _db.financialSettingsDao.get();
    final id = row?.goalId;
    final name = row?.goalName;
    final targetMonths = row?.goalTargetMonths;
    if (id == null || name == null || targetMonths == null) return null;
    return domain.RunwayGoal(
      id: id,
      name: name,
      targetMonths: targetMonths,
      targetDate: row?.goalTargetDate,
    );
  }

  @override
  Future<void> saveRunwayGoal(domain.RunwayGoal? goal) =>
      _db.financialSettingsDao.write(
        FinancialSettingsCompanion(
          goalId: Value(goal?.id),
          goalName: Value(goal?.name),
          goalTargetMonths: Value(goal?.targetMonths),
          goalTargetDate: Value(goal?.targetDate),
        ),
      );
}
