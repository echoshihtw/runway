import 'package:application/application.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/paywall/paywall_screen.dart';

/// Whether a new entry may be logged. When a free owner has used their five,
/// shows the paywall and returns false.
///
/// Every door that writes an entry asks this first: the add button, a loan,
/// a repayment, a confirmed subscription charge. Editing an existing entry
/// and the opening balance never ask, because neither is a new entry.
bool allowsNewEntry(BuildContext context, WidgetRef ref) {
  final isPro =
      FeatureFlags.devProEntitlement ||
      (ref.read(entitlementProvider).value?.isPro ?? false);
  // Unknown reads as zero, like the simulation count: the same open question
  // as #94 item 4, kept consistent rather than decided here.
  final logged = ref.read(entryCountProvider).value ?? 0;
  if (needsProForEntry(isPro: isPro, entriesLogged: logged)) {
    showPaywall(context, trigger: 'entry_limit');
    return false;
  }
  return true;
}
