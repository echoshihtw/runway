import 'dart:ui';

import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// The one place event names and parameter keys are written. The privacy
/// page lists these names, and site/tests checks it still does.
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService([this._instance]);

  FirebaseAnalytics? _instance;

  /// Null whenever Firebase is unavailable.
  ///
  /// `FirebaseAnalytics.instance` reaches for `Firebase.app()`, which throws
  /// when initialisation failed. Resolving it in a field initialiser meant
  /// constructing this service could throw before `runApp`, outside main's
  /// try/catch — so a missing or mismatched GoogleService-Info.plist killed
  /// every launch, for a layer the app never reads. Analytics is optional;
  /// launching is not.
  FirebaseAnalytics? get _fa {
    if (_instance != null) return _instance;
    try {
      if (Firebase.apps.isEmpty) return null;
      return _instance ??= FirebaseAnalytics.instance;
    } catch (_) {
      return null;
    }
  }

  /// Every event is logged after the user's write has landed, so a failure
  /// here must never reach the caller and read as a failed save.
  Future<void> _log(String name, [Map<String, Object>? parameters]) async {
    try {
      await _fa?.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('Analytics event $name failed: $e');
    }
  }

  @override
  Future<void> logScreen(String name) async {
    try {
      await _fa?.logScreenView(screenName: name);
    } catch (e) {
      debugPrint('Analytics screen view failed: $e');
    }
  }

  @override
  Future<void> logAddTransaction(TransactionType type) =>
      _log('add_transaction', {'type': type.name});

  @override
  Future<void> logDeleteTransaction(TransactionType type) =>
      _log('delete_transaction', {'type': type.name});

  @override
  Future<void> logAddLoan(String source) =>
      _log('add_loan', {'source': source});

  @override
  Future<void> logRepayLoan() => _log('repay_loan');

  @override
  Future<void> logAddSubscription(BillingCycle cycle) =>
      _log('add_subscription', {'cycle': cycle.name});

  @override
  Future<void> logDeleteSubscription() => _log('delete_subscription');

  @override
  Future<void> logSetBudget() => _log('set_budget');

  // Firebase takes only strings and numbers, so a flag is sent as 0 or 1.
  @override
  Future<void> logRunSimulation({
    bool hasBurnOverride = false,
    bool hasIncome = false,
  }) => _log('run_simulation', {
    'has_burn_override': hasBurnOverride ? 1 : 0,
    'has_income': hasIncome ? 1 : 0,
  });

  /// Null is "follow the device", the choice that clears the saved language.
  @override
  Future<void> logChangeLanguage(Locale? locale) =>
      _log('change_language', {'locale': locale?.toLanguageTag() ?? 'system'});

  @override
  Future<void> logChangeCurrency(String code) =>
      _log('change_currency', {'currency': code});
}
