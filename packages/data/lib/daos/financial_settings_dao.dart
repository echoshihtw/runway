import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../tables/financial_settings_table.dart';

part 'financial_settings_dao.g.dart';

@DriftAccessor(tables: [FinancialSettings])
class FinancialSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$FinancialSettingsDaoMixin {
  FinancialSettingsDao(super.db);

  static const _rowId = 1;

  Future<FinancialSettingsRow?> get() => (select(
    financialSettings,
  )..where((t) => t.id.equals(_rowId))).getSingleOrNull();

  /// Writes only the columns present in [changes], creating the row if needed.
  Future<void> write(FinancialSettingsCompanion changes) => into(
    financialSettings,
  ).insertOnConflictUpdate(changes.copyWith(id: const Value(_rowId)));
}
