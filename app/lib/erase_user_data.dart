import 'package:application/application.dart';
import 'package:data/data.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Erases everything Runway stores about the user on this device.
Future<void> eraseAllUserData(AppDatabase database) async {
  await deleteEncryptedDatabase(database: database);
  await clearPreferencesForReset(await SharedPreferences.getInstance());
  try {
    // Starts a new anonymous analytics identity on this device.
    await FirebaseAnalytics.instance.resetAnalyticsData();
  } catch (e) {
    debugPrint('Analytics reset failed: $e');
  }
}
