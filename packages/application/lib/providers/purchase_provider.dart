import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/purchase_service.dart';

// Overridden in app/lib/main.dart with the RevenueCat implementation
final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  throw UnimplementedError('purchaseServiceProvider must be overridden');
});

// Current offering — loaded once on startup
final proOfferingProvider = FutureProvider<ProOffering?>((ref) async {
  final service = ref.watch(purchaseServiceProvider);
  return service.fetchOffering();
});

// Purchase state
class PurchaseNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> purchase(ProPackage package) async {
    state = const AsyncLoading();
    try {
      final service = ref.read(purchaseServiceProvider);
      final success = await service.purchasePackage(package);
      state = const AsyncData(null);
      return success;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<bool> restore() async {
    state = const AsyncLoading();
    try {
      final service = ref.read(purchaseServiceProvider);
      final success = await service.restorePurchases();
      state = const AsyncData(null);
      return success;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final purchaseNotifierProvider = AsyncNotifierProvider<PurchaseNotifier, void>(
  PurchaseNotifier.new,
);
