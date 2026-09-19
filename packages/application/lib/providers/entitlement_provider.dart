import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../feature_flags.dart';
import 'purchase_provider.dart';
import '../services/purchase_service.dart';

/// SharedPreferences key caching the Pro unlock for offline use.
const kIsProPreferenceKey = 'is_pro';
const _kIsPro = kIsProPreferenceKey;

class EntitlementNotifier extends AsyncNotifier<EntitlementState> {
  @override
  Future<EntitlementState> build() async {
    // Offline fallback — use locally cached value first
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getBool(_kIsPro) ?? false;

    // Read outside the try: a missing override is a programming error, not an
    // offline store.
    final service = ref.read(purchaseServiceProvider);

    if (_effectiveIsPro(cached)) {
      // The cache answers first, so a paying owner is never held at a spinner
      // waiting for the network. But it cannot be the last word: a cached
      // unlock used to return here and the store was never consulted again on
      // that device, so a refund or a lapsed subscription had no way to land
      // and the only thing that could correct it was never called at all.
      _unlockOnExternalPurchase(service);
      if (cached) _revokeIfTheStoreSaysSo(service);
      return EntitlementState(isPro: true);
    }

    try {
      final serverPro = await service.checkProEntitlement();
      if (serverPro) {
        await prefs.setBool(_kIsPro, true);
      } else {
        _unlockOnExternalPurchase(service);
      }
      return EntitlementState(isPro: _effectiveIsPro(serverPro));
    } catch (_) {
      // Offline, or the store is down. Listen anyway: when connectivity
      // returns and RevenueCat reports the entitlement, the unlock has to
      // land without a relaunch. This branch used to return without
      // attaching — the listener was wired only after a *successful* check —
      // so a paying customer who opened the app offline stayed locked out for
      // the whole session.
      _unlockOnExternalPurchase(service);
      return EntitlementState(isPro: _effectiveIsPro(cached));
    }
  }

  /// Gives up a cached unlock the store no longer recognises.
  ///
  /// Only a store that answers may revoke. Offline, or a store that is down,
  /// leaves the cache exactly as it was — the alternative locks a paying owner
  /// out of what they bought because their train went into a tunnel.
  void _revokeIfTheStoreSaysSo(PurchaseService service) {
    unawaited(
      Future(() async {
        final bool serverPro;
        try {
          serverPro = await service.checkProEntitlement();
        } catch (_) {
          return;
        }
        if (serverPro) return;

        // An unlock that arrived while this check was in flight wins. A
        // purchase or a redeemed offer code can land between asking the store
        // and hearing back, and the answer we are holding was true before it
        // happened — acting on it would switch Pro off for someone who had
        // just paid, and write that to disk for the next launch too.
        if (_unlockedSinceCheck) return;

        // Checked here rather than before the awaits: the provider can be
        // disposed during them, and assigning state afterwards throws out of
        // an unawaited future, where nothing catches it.
        if (!ref.mounted) return;
        await revokePro();
      }),
    );
  }

  /// Set when the store reports the entitlement while a revocation check is
  /// still waiting for its answer.
  bool _unlockedSinceCheck = false;

  /// A purchase can complete outside the paywall, for example when an offer
  /// code is redeemed from its URL. Unlock as soon as RevenueCat reports it,
  /// without waiting for the app to relaunch.
  ///
  /// This only ever unlocks. An update without the entitlement, such as one
  /// received while offline, never revokes a cached Pro unlock.
  void _unlockOnExternalPurchase(PurchaseService service) {
    final subscription = service.proEntitlementUpdates.listen((isPro) {
      if (!isPro) return;
      _unlockedSinceCheck = true;
      unlockPro();
    });
    ref.onDispose(subscription.cancel);
  }

  Future<void> unlockPro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsPro, true);
    // The write to disk stands either way; only the in-memory state needs a
    // live provider to land on.
    if (!ref.mounted) return;
    state = AsyncData(EntitlementState(isPro: true));
  }

  Future<void> revokePro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsPro, false);
    if (!ref.mounted) return;
    state = AsyncData(EntitlementState(isPro: _effectiveIsPro(false)));
  }

  bool _effectiveIsPro(bool storedIsPro) {
    return storedIsPro || FeatureFlags.devProEntitlement;
  }
}

class EntitlementState {
  final bool isPro;
  const EntitlementState({required this.isPro});

  // What is free and what is Pro is decided by the gates themselves —
  // needsProForEntry and needsProForSimulation — not restated here. A second
  // statement of the rule drifted: this block still said entries were always
  // free and loans were the paid part.
}

final entitlementProvider =
    AsyncNotifierProvider<EntitlementNotifier, EntitlementState>(
      EntitlementNotifier.new,
    );
