import 'package:application/application.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('clears every preference except the cached Pro unlock', () async {
    SharedPreferences.setMockInitialValues({
      kIsProPreferenceKey: true,
      'onboarding_done': true,
      'getting_started_dismissed': true,
      'budget_rent': 1200.0,
      'runway_goal': '{"name":"Trip","targetMonths":6}',
      'app_locale': 'ja',
    });
    final prefs = await SharedPreferences.getInstance();

    await clearPreferencesForReset(prefs);

    expect(prefs.getKeys(), {kIsProPreferenceKey});
    expect(prefs.getBool(kIsProPreferenceKey), isTrue);
  });

  test('leaves no preferences when Pro was never cached', () async {
    SharedPreferences.setMockInitialValues({'onboarding_done': true});
    final prefs = await SharedPreferences.getInstance();

    await clearPreferencesForReset(prefs);

    expect(prefs.getKeys(), isEmpty);
  });
}
