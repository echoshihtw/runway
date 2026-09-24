import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'clock_provider.dart';
import 'transaction_provider.dart';
import 'loan_provider.dart';
import 'scenario_provider.dart';
import 'subscription_provider.dart';
import 'budget_provider.dart';
import 'financial_assumptions_provider.dart';

/// Monthly burn split into rent, living, subscriptions and loans.
final monthlyBurnProvider = Provider<MonthlyBurn>((ref) {
  return computeMonthlyBurn(
    transactions: ref.watch(transactionsProvider).value ?? const [],
    budget: ref.watch(budgetProvider).value ?? const Budget(),
    loans: ref.watch(loanSummariesProvider),
    subscriptions: ref.watch(subscriptionsProvider).value ?? const [],
    now: ref.watch(clockProvider)(),
  );
});

final modelProvider = Provider<ModelState>((ref) {
  final assumptions =
      ref.watch(financialAssumptionsProvider).value ??
      const FinancialAssumptions();

  // Null means the ledger has not loaded or failed to load. Riverpod retries
  // a failing build for about 38 seconds before it errors, so substituting an
  // empty list showed a fabricated balance for most of a minute.
  final transactions = ref.watch(transactionsProvider).value;

  return computeModel(
    currentCash: _currentCash(
      transactions ?? const [],
      ref.watch(clockProvider)(),
    ),
    cashIsKnown: transactions != null,
    burn: ref.watch(monthlyBurnProvider),
    expectedMonthlyInflow: assumptions.expectedMonthlyInflow,
    expectedMonthlyBurnOverride: assumptions.expectedMonthlyBurnOverride,
  );
});

final scenarioModelProvider = Provider<ModelState?>((ref) {
  final scenario = ref.watch(scenarioProvider);
  if (!scenario.isActive) return null;

  final transactions = ref.watch(transactionsProvider).value;
  if (transactions == null) return null;

  final assumptions =
      ref.watch(financialAssumptionsProvider).value ??
      const FinancialAssumptions();

  return modelForScenario(
    currentCash: _currentCash(transactions, ref.watch(clockProvider)()),
    burn: ref.watch(monthlyBurnProvider),
    monthlyCostOverride: scenario.burnRateOverride,
    simulatedIncome: scenario.simulatedIncome,
    expectedMonthlyBurnOverride: assumptions.expectedMonthlyBurnOverride,
    expectedMonthlyInflow: assumptions.expectedMonthlyInflow,
  );
});

double _currentCash(List<Transaction> transactions, DateTime now) =>
    currentCashAsOf(transactions: transactions, now: now);
