import 'package:app/firebase_analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Constructing this service used to resolve `FirebaseAnalytics.instance` in a
/// field initialiser, which throws when Firebase never initialised. That ran
/// outside main's try/catch and before runApp, so a Firebase problem was a
/// launch crash. No Firebase app exists in a plain test, which is exactly the
/// failing condition.
void main() {
  test('constructs with no Firebase app initialised', () {
    expect(FirebaseAnalyticsService.new, returnsNormally);
  });

  test('logging is a no-op rather than a throw', () async {
    final analytics = FirebaseAnalyticsService();

    await expectLater(analytics.logScreen('dashboard'), completes);
    await expectLater(analytics.logSetBudget(), completes);
    await expectLater(analytics.logAddTransaction('expense'), completes);
    await expectLater(analytics.logRepayLoan(), completes);
    await expectLater(
      analytics.logRunSimulation(hasBurnOverride: true),
      completes,
    );
  });
}
