import 'dart:ui';

import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which features get used, never what anyone has: every parameter is a
/// category, a flag or a locale, and app/test/analytics_parameters_guard_test
/// fails if one could carry an amount or typed text.
abstract class AnalyticsService {
  Future<void> logScreen(String name);
  Future<void> logAddTransaction(TransactionType type);
  Future<void> logDeleteTransaction(TransactionType type);
  Future<void> logAddLoan(String source);
  Future<void> logRepayLoan();
  Future<void> logAddSubscription(BillingCycle cycle);
  Future<void> logDeleteSubscription();
  Future<void> logSetBudget();
  Future<void> logRunSimulation({bool hasBurnOverride, bool hasIncome});
  Future<void> logChangeLanguage(Locale? locale);
  Future<void> logChangeCurrency(String code);
}

/// The default, and what tests use.
class NoOpAnalytics implements AnalyticsService {
  const NoOpAnalytics();
  @override
  Future<void> logScreen(String name) async {}
  @override
  Future<void> logAddTransaction(TransactionType type) async {}
  @override
  Future<void> logDeleteTransaction(TransactionType type) async {}
  @override
  Future<void> logAddLoan(String source) async {}
  @override
  Future<void> logRepayLoan() async {}
  @override
  Future<void> logAddSubscription(BillingCycle cycle) async {}
  @override
  Future<void> logDeleteSubscription() async {}
  @override
  Future<void> logSetBudget() async {}
  @override
  Future<void> logRunSimulation({
    bool hasBurnOverride = false,
    bool hasIncome = false,
  }) async {}
  @override
  Future<void> logChangeLanguage(Locale? locale) async {}
  @override
  Future<void> logChangeCurrency(String code) async {}
}

/// Override this in main.dart with FirebaseAnalyticsService
final analyticsProvider = Provider<AnalyticsService>(
  (_) => const NoOpAnalytics(),
);
