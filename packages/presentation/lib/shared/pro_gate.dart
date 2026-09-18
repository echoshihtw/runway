import 'package:application/application.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/paywall/paywall_screen.dart';
import '../product_config.dart';

/// Whether a new entry may be logged. When a free owner has used their
/// allowance, shows the paywall and returns false.
///
/// Every door that writes an entry asks this first: the add button, a loan,
/// a repayment, a confirmed subscription charge. Editing an existing entry
/// and the opening balance never ask, because neither is a new entry.
bool allowsNewEntry(BuildContext context, WidgetRef ref) => _allows(
  context,
  ref,
  used: ref.read(entryCountProvider).value,
  free: ProductConfig.freeEntries,
  trigger: 'entry_limit',
);

/// Whether another simulation may run. Same rule, same shape.
bool allowsSimulation(BuildContext context, WidgetRef ref) => _allows(
  context,
  ref,
  used: ref.read(simulationCountProvider).value,
  free: ProductConfig.freeSimulations,
  trigger: 'simulation',
);

/// Whether the current owner is Pro, for callers that only need to know
/// whether to show a free-allowance caption.
bool isProOwner(WidgetRef ref) =>
    FeatureFlags.devProEntitlement ||
    (ref.read(entitlementProvider).value?.isPro ?? false);

bool _allows(
  BuildContext context,
  WidgetRef ref, {
  required int? used,
  required int free,
  required String trigger,
}) {
  // An unknown count reads as zero — the open question in #94 item 4, kept
  // consistent across both gates rather than decided in one of them.
  if (needsPro(isPro: isProOwner(ref), used: used ?? 0, free: free)) {
    showPaywall(context, trigger: trigger);
    return false;
  }
  return true;
}
