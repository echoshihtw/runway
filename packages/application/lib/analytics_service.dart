import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Nothing calls any of these yet.
abstract class AnalyticsService {
  Future<void> logScreen(String name);
  Future<void> logAddTransaction(String type);
  Future<void> logDeleteTransaction(String type);
  Future<void> logAddLoan(String source);
  Future<void> logRepayLoan();
  Future<void> logAddSubscription(String cycle);
  Future<void> logDeleteSubscription();
  Future<void> logSetBudget();
  Future<void> logRunSimulation({bool hasBurnOverride, bool hasIncome});
  Future<void> logShare(String surface);
  Future<void> logChangeLanguage(String locale);
  Future<void> logChangeCurrency(String code);
}

/// The default, and what tests use.
class NoOpAnalytics implements AnalyticsService {
  const NoOpAnalytics();
  @override
  Future<void> logScreen(String name) async {}
  @override
  Future<void> logAddTransaction(String type) async {}
  @override
  Future<void> logDeleteTransaction(String type) async {}
  @override
  Future<void> logAddLoan(String source) async {}
  @override
  Future<void> logRepayLoan() async {}
  @override
  Future<void> logAddSubscription(String cycle) async {}
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
  Future<void> logShare(String surface) async {}
  @override
  Future<void> logChangeLanguage(String locale) async {}
  @override
  Future<void> logChangeCurrency(String code) async {}
}

/// Override this in main.dart with FirebaseAnalyticsService
final analyticsProvider = Provider<AnalyticsService>(
  (_) => const NoOpAnalytics(),
);
