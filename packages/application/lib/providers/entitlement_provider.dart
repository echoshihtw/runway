import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../feature_flags.dart';
import 'purchase_provider.dart';

/// SharedPreferences key caching the Pro unlock for offline use.
const kIsProPreferenceKey = 'is_pro';
const _kIsPro = kIsProPreferenceKey;

class EntitlementNotifier extends AsyncNotifier<EntitlementState> {
  @override
  Future<EntitlementState> build() async {
    // Offline fallback — use locally cached value first
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getBool(_kIsPro) ?? false;
    if (_effectiveIsPro(cached)) {
      return EntitlementState(isPro: true);
    }

    // Try to verify with RevenueCat if configured
    try {
      final service = ref.read(purchaseServiceProvider);
      final serverPro = await service.checkProEntitlement();
      if (serverPro) await prefs.setBool(_kIsPro, true);
      return EntitlementState(isPro: _effectiveIsPro(serverPro));
    } catch (_) {
      return EntitlementState(isPro: _effectiveIsPro(cached));
    }
  }

  Future<void> unlockPro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsPro, true);
    state = AsyncData(EntitlementState(isPro: true));
  }

  Future<void> revokePro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsPro, false);
    state = AsyncData(EntitlementState(isPro: _effectiveIsPro(false)));
  }

  bool _effectiveIsPro(bool storedIsPro) {
    return storedIsPro || FeatureFlags.devProEntitlement;
  }
}

class EntitlementState {
  final bool isPro;
  const EntitlementState({required this.isPro});

  // Feature gates — what's free vs pro
  bool get canUseSubscriptions => isPro;
  bool get canAddMultipleLoans => isPro;
  bool get canUseTimeline => isPro;
  bool get canUseUnlimitedSims => isPro;

  // Always free
  bool get canAddTransactions => true;
  bool get canUseBasicRunway => true;
  bool get canShare => true;
  bool get canUseBudget => true;
  bool get canAddFirstLoan => true;
  bool get canUseOneSim => true;
}

final entitlementProvider =
    AsyncNotifierProvider<EntitlementNotifier, EntitlementState>(
      EntitlementNotifier.new,
    );
