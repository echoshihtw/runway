import 'package:data/data.dart' hide Transaction, Loan, Subscription;
import 'package:domain/domain.dart';
import 'package:test/test.dart';

import 'db_helper.dart';

void main() {
  late AppDatabase db;
  late DriftFinancialSettingsRepository repo;

  setUp(() {
    db = openTestDatabase();
    repo = DriftFinancialSettingsRepository(db);
  });

  tearDown(() => db.close());

  test('a fresh database has an empty budget, no assumptions and no goal', () async {
    final budget = await repo.getBudget();
    final assumptions = await repo.getFinancialAssumptions();

    expect(budget.rent, 0);
    expect(budget.living, 0);
    expect(assumptions.expectedMonthlyInflow, isNull);
    expect(assumptions.expectedMonthlyBurnOverride, isNull);
    expect(await repo.getRunwayGoal(), isNull);
  });

  test('round-trips every value', () async {
    final targetDate = DateTime(2027, 3, 1);
    await repo.saveBudget(const Budget(rent: 1200, living: 850.5));
    await repo.saveFinancialAssumptions(
      const FinancialAssumptions(
        expectedMonthlyInflow: 3000,
        expectedMonthlyBurnOverride: 2100,
      ),
    );
    await repo.saveRunwayGoal(
      RunwayGoal(
        id: 'goal-1',
        name: 'Sabbatical',
        targetMonths: 9,
        targetDate: targetDate,
      ),
    );

    final budget = await repo.getBudget();
    final assumptions = await repo.getFinancialAssumptions();
    final goal = await repo.getRunwayGoal();

    expect(budget.rent, 1200);
    expect(budget.living, 850.5);
    expect(assumptions.expectedMonthlyInflow, 3000);
    expect(assumptions.expectedMonthlyBurnOverride, 2100);
    expect(goal?.id, 'goal-1');
    expect(goal?.name, 'Sabbatical');
    expect(goal?.targetMonths, 9);
    expect(goal?.targetDate, targetDate);
  });

  test('saving one section leaves the others untouched', () async {
    await repo.saveBudget(const Budget(rent: 1200, living: 800));
    await repo.saveRunwayGoal(
      const RunwayGoal(id: 'goal-1', name: 'Trip', targetMonths: 6),
    );

    await repo.saveFinancialAssumptions(
      const FinancialAssumptions(expectedMonthlyInflow: 500),
    );
    await repo.saveRunwayGoal(null);

    final budget = await repo.getBudget();
    expect(budget.rent, 1200);
    expect(budget.living, 800);
    expect((await repo.getFinancialAssumptions()).expectedMonthlyInflow, 500);
    expect(await repo.getRunwayGoal(), isNull);
  });

  test('clearing assumptions stores nulls, not stale values', () async {
    await repo.saveFinancialAssumptions(
      const FinancialAssumptions(
        expectedMonthlyInflow: 500,
        expectedMonthlyBurnOverride: 900,
      ),
    );

    await repo.saveFinancialAssumptions(const FinancialAssumptions());

    final assumptions = await repo.getFinancialAssumptions();
    expect(assumptions.expectedMonthlyInflow, isNull);
    expect(assumptions.expectedMonthlyBurnOverride, isNull);
  });
}
