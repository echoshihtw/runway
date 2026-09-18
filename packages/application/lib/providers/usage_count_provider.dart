import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/usage_count_store.dart';

/// The two things the free plan counts. The key is the Keychain item; it must
/// never change, or every device forgets what it has used.
enum UsageKind {
  entries('entries_logged'),
  simulations('simulations_run');

  const UsageKind(this.key);
  final String key;
}

/// Whether doing one more of something needs Pro. The allowance itself is not
/// decided here — it lives in the product config with the other decisions.
bool needsPro({required bool isPro, required int used, required int free}) =>
    !isPro && used >= free;

/// Overridden in main.dart with the Keychain-backed store.
final usageCountStoreProvider = Provider<UsageCountStore>((ref) {
  throw UnimplementedError(
    'usageCountStoreProvider must be overridden in main.dart',
  );
});

/// How many of one kind have happened on this device, ever.
class UsageCountNotifier extends AsyncNotifier<int> {
  UsageCountNotifier(this.kind);

  final UsageKind kind;

  @override
  Future<int> build() => ref.watch(usageCountStoreProvider).read(kind.key);

  Future<void> increment() async {
    final store = ref.read(usageCountStoreProvider);
    final next = await store.read(kind.key) + 1;
    await store.write(kind.key, next);
    state = AsyncData(next);
  }
}

final entryCountProvider = AsyncNotifierProvider<UsageCountNotifier, int>(
  () => UsageCountNotifier(UsageKind.entries),
);

final simulationCountProvider = AsyncNotifierProvider<UsageCountNotifier, int>(
  () => UsageCountNotifier(UsageKind.simulations),
);
