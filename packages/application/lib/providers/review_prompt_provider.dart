import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/review_prompter.dart';

const _kLaunchCount = 'app_launch_count';
const _kEligibleAtLaunch = 'review_eligible_at_launch';
const _kReviewRequested = 'review_requested';

/// Overridden in main.dart with the native in_app_review prompt.
final reviewPrompterProvider = Provider<ReviewPrompter>((ref) {
  throw UnimplementedError(
    'reviewPrompterProvider must be overridden in main.dart',
  );
});

/// Counts app launches. Called once per process start, before runApp.
Future<void> recordAppLaunch(SharedPreferences prefs) =>
    prefs.setInt(_kLaunchCount, (prefs.getInt(_kLaunchCount) ?? 0) + 1);

/// Whether the user has seen a real runway number: an opening balance, at
/// least one expense, and a finite runway (9999 means unlimited).
bool isEligibleForReviewPrompt({
  required List<Transaction> transactions,
  required ModelState model,
}) =>
    transactions.any((t) => t.type == TransactionType.openingBalance) &&
    transactions.any((t) => t.type == TransactionType.expense) &&
    model.runwayMonths < 9999;

/// Remembers the launch in which the user first became eligible. Later calls
/// keep the first value.
Future<void> recordReviewEligibility(SharedPreferences prefs) async {
  if (prefs.containsKey(_kEligibleAtLaunch)) return;
  await prefs.setInt(_kEligibleAtLaunch, prefs.getInt(_kLaunchCount) ?? 0);
}

/// Ask at most once per install, and only on a launch after the one in which
/// the user first became eligible. Apple also limits how often the prompt
/// appears.
bool shouldRequestReview(SharedPreferences prefs, {required bool eligible}) {
  if (!eligible || (prefs.getBool(_kReviewRequested) ?? false)) return false;
  final eligibleAt = prefs.getInt(_kEligibleAtLaunch);
  if (eligibleAt == null) return false;
  return (prefs.getInt(_kLaunchCount) ?? 0) > eligibleAt;
}

Future<void> markReviewRequested(SharedPreferences prefs) =>
    prefs.setBool(_kReviewRequested, true);
