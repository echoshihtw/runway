import 'package:shared_preferences/shared_preferences.dart';

import '../providers/entitlement_provider.dart';

/// Erases everything the user entered and restarts the app at onboarding.
///
/// Implemented in the app package, which owns the database and the root
/// ProviderScope. The current ProviderScope is disposed during the call, so
/// callers must not use their `ref` or `context` afterwards.
abstract class DataResetService {
  Future<void> deleteAllData();
}

/// Preferences that survive a data reset.
///
/// The cached Pro unlock stays so a paying user is not locked out offline.
/// It holds no financial data, and RevenueCat re-checks it on the next launch.
const kPreferencesKeptOnReset = {kIsProPreferenceKey};

/// Removes every preference except [kPreferencesKeptOnReset].
Future<void> clearPreferencesForReset(SharedPreferences prefs) async {
  for (final key in prefs.getKeys().toList()) {
    if (!kPreferencesKeptOnReset.contains(key)) await prefs.remove(key);
  }
}
