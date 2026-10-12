import 'dart:io';
import 'dart:ui';

import 'package:app/firebase_analytics_service.dart';
import 'package:domain/domain.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

class _Recorder extends Fake implements FirebaseAnalytics {
  final events = <(String, Map<String, Object>?)>[];

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
    List<AnalyticsEventItem>? items,
    AnalyticsCallOptions? callOptions,
  }) async => events.add((name, parameters));

  @override
  Future<void> logScreenView({
    String? screenClass,
    String? screenName,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) async => events.add(('screen_view', {'screen_name': screenName!}));
}

class _Throws extends Fake implements FirebaseAnalytics {
  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
    List<AnalyticsEventItem>? items,
    AnalyticsCallOptions? callOptions,
  }) async => throw StateError('offline');

  @override
  Future<void> logScreenView({
    String? screenClass,
    String? screenName,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) async => throw StateError('offline');
}

/// Logs every event the service can send, with the widest arguments.
Future<void> _logEverything(FirebaseAnalyticsService analytics) async {
  await analytics.logScreen('/dashboard');
  for (final type in TransactionType.values) {
    await analytics.logAddTransaction(type);
    await analytics.logDeleteTransaction(type);
  }
  await analytics.logAddLoan('BANK');
  await analytics.logRepayLoan();
  for (final cycle in BillingCycle.values) {
    await analytics.logAddSubscription(cycle);
  }
  await analytics.logDeleteSubscription();
  await analytics.logSetBudget();
  await analytics.logRunSimulation(hasBurnOverride: true, hasIncome: true);
  await analytics.logChangeLanguage(const Locale('zh', 'TW'));
  await analytics.logChangeCurrency('TWD');
}

void main() {
  /// Constructing this service used to resolve `FirebaseAnalytics.instance`
  /// in a field initialiser, which throws when Firebase never initialised.
  /// That ran outside main's try/catch and before runApp, so a Firebase
  /// problem was a launch crash. No Firebase app exists in a plain test,
  /// which is exactly the failing condition.
  test('constructs with no Firebase app initialised', () {
    expect(FirebaseAnalyticsService.new, returnsNormally);
  });

  test('logging is a no-op rather than a throw', () async {
    await expectLater(_logEverything(FirebaseAnalyticsService()), completes);
  });

  test('a failing event never reaches the caller', () async {
    // Events are logged after a save; a throw would read as a failed save.
    await expectLater(
      _logEverything(FirebaseAnalyticsService(_Throws())),
      completes,
    );
  });

  test('every parameter is a known key with a string or number', () async {
    // Firebase asserts on any other value type, and an unknown key is where
    // an amount or a note would arrive.
    const keys = {
      'screen_name',
      'type',
      'source',
      'cycle',
      'has_burn_override',
      'has_income',
      'locale',
      'currency',
    };
    final recorder = _Recorder();
    await _logEverything(FirebaseAnalyticsService(recorder));

    expect(recorder.events, isNotEmpty);
    for (final (name, parameters) in recorder.events) {
      for (final MapEntry(:key, :value) in (parameters ?? {}).entries) {
        expect(keys, contains(key), reason: '$name.$key');
        expect(value is String || value is num, isTrue, reason: '$name.$key');
      }
    }
  });

  test('the privacy page lists exactly the events sent', () async {
    // The page publishes on merge, so an event added here without a line
    // there would be sent while the policy says nothing of it.
    final page = File('../site/privacy/index.html').readAsStringSync();
    final list = RegExp(
      r'<ul id="analytics-events">(.*?)</ul>',
      dotAll: true,
    ).firstMatch(page)!.group(1)!;
    final listed = RegExp(
      r'<li><code>(\w+)</code>',
    ).allMatches(list).map((m) => m.group(1)).toSet();

    final recorder = _Recorder();
    await _logEverything(FirebaseAnalyticsService(recorder));
    final sent = recorder.events.map((e) => e.$1).toSet();

    expect(listed, sent);
  });
}
