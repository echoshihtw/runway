import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'repository_provider.dart';

const _kBudgetRent = 'budget_rent';
const _kBudgetLiving = 'budget_living';
const _kExpectedInflow = 'assumptions_expected_monthly_inflow';
const _kExpectedBurn = 'assumptions_expected_monthly_burn';
const _kRunwayGoal = 'runway_goal';

/// Keys that held financial values in plain SharedPreferences before the
/// values moved into the encrypted database.
const kLegacyFinancialPreferenceKeys = [
  _kBudgetRent,
  _kBudgetLiving,
  _kExpectedInflow,
  _kExpectedBurn,
  _kRunwayGoal,
];

/// Moves legacy financial values into [repository], then removes them from
/// [prefs].
///
/// Safe to run again after an interruption: values are only removed after
/// they are written, and rewriting the same values changes nothing.
Future<void> moveLegacyFinancialPreferences(
  SharedPreferences prefs,
  FinancialSettingsRepository repository,
) async {
  if (!kLegacyFinancialPreferenceKeys.any(prefs.containsKey)) return;

  final rent = prefs.getDouble(_kBudgetRent);
  final living = prefs.getDouble(_kBudgetLiving);
  if (rent != null || living != null) {
    await repository.saveBudget(Budget(rent: rent ?? 0, living: living ?? 0));
  }

  final inflow = prefs.getDouble(_kExpectedInflow);
  final burn = prefs.getDouble(_kExpectedBurn);
  if (inflow != null || burn != null) {
    await repository.saveFinancialAssumptions(
      FinancialAssumptions(
        expectedMonthlyInflow: inflow,
        expectedMonthlyBurnOverride: burn,
      ),
    );
  }

  final goal = _decodeGoal(prefs.getString(_kRunwayGoal));
  if (goal != null) await repository.saveRunwayGoal(goal);

  for (final key in kLegacyFinancialPreferenceKeys) {
    await prefs.remove(key);
  }
}

/// An unreadable goal is dropped rather than blocking the migration.
RunwayGoal? _decodeGoal(String? raw) {
  if (raw == null) return null;
  try {
    return RunwayGoal.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  } on FormatException {
    return null;
  } on TypeError {
    return null;
  }
}

/// Runs [moveLegacyFinancialPreferences] once per ProviderScope. The
/// settings providers await it before their first read.
final legacyFinancialPreferencesMigrationProvider = FutureProvider<void>((
  ref,
) async {
  final prefs = await SharedPreferences.getInstance();
  await moveLegacyFinancialPreferences(
    prefs,
    ref.watch(financialSettingsRepositoryProvider),
  );
});
