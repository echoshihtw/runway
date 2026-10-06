import 'package:application/application.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseAnalyticsService implements AnalyticsService {
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
    try {
      if (Firebase.apps.isEmpty) return null;
      return _instance ??= FirebaseAnalytics.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logScreen(String name) async =>
      _fa?.logScreenView(screenName: name);

  @override
  Future<void> logAddTransaction(String type) async =>
      _fa?.logEvent(name: 'add_transaction', parameters: {'type': type});

  @override
  Future<void> logDeleteTransaction(String type) async =>
      _fa?.logEvent(name: 'delete_transaction', parameters: {'type': type});

  @override
  Future<void> logAddLoan(String source) async =>
      _fa?.logEvent(name: 'add_loan', parameters: {'source': source});

  @override
  Future<void> logRepayLoan() async => _fa?.logEvent(name: 'repay_loan');

  @override
  Future<void> logAddSubscription(String cycle) async =>
      _fa?.logEvent(name: 'add_subscription', parameters: {'cycle': cycle});

  @override
  Future<void> logDeleteSubscription() async =>
      _fa?.logEvent(name: 'delete_subscription');

  @override
  Future<void> logSetBudget() async => _fa?.logEvent(name: 'set_budget');

  @override
  Future<void> logRunSimulation({
    bool hasBurnOverride = false,
    bool hasIncome = false,
  }) async => _fa?.logEvent(
    name: 'run_simulation',
    parameters: {'has_burn_override': hasBurnOverride, 'has_income': hasIncome},
  );

  @override
  Future<void> logShare(String surface) async =>
      _fa?.logEvent(name: 'share', parameters: {'surface': surface});

  @override
  Future<void> logChangeLanguage(String locale) async =>
      _fa?.logEvent(name: 'change_language', parameters: {'locale': locale});

  @override
  Future<void> logChangeCurrency(String code) async =>
      _fa?.logEvent(name: 'change_currency', parameters: {'currency': code});
}
