import 'package:drift/drift.dart';

/// Budget, forecast assumptions and runway goal, in a single row with id 1.
///
/// These values lived in plain SharedPreferences before schema version 6.
@DataClassName('FinancialSettingsRow')
class FinancialSettings extends Table {
  IntColumn get id => integer()();
  RealColumn get budgetRent => real().withDefault(const Constant(0))();
  RealColumn get budgetLiving => real().withDefault(const Constant(0))();
  RealColumn get expectedMonthlyInflow => real().nullable()();
  RealColumn get expectedMonthlyBurnOverride => real().nullable()();
  TextColumn get goalId => text().nullable()();
  TextColumn get goalName => text().nullable()();
  IntColumn get goalTargetMonths => integer().nullable()();
  DateTimeColumn get goalTargetDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
