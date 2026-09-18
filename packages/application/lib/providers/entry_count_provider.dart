import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/entry_count_store.dart';

/// Entries a free user can log before the Pro paywall.
///
/// The app is free and the planning tool is the paid part (#80). Five entries
/// let someone see the number move; from the sixth, logging is Pro. Every
/// kind of entry counts except the opening balance, because starting is not
/// logging and onboarding must never dead-end.
const kFreeEntries = 5;

/// Whether logging another entry needs Pro.
bool needsProForEntry({required bool isPro, required int entriesLogged}) =>
    !isPro && entriesLogged >= kFreeEntries;

/// Overridden in main.dart with the Keychain-backed store.
final entryCountStoreProvider = Provider<EntryCountStore>((ref) {
  throw UnimplementedError(
    'entryCountStoreProvider must be overridden in main.dart',
  );
});

/// How many entries have been logged on this device, ever.
class EntryCountNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() => ref.watch(entryCountStoreProvider).read();

  Future<void> increment() async {
    final store = ref.read(entryCountStoreProvider);
    final next = await store.read() + 1;
    await store.write(next);
    state = AsyncData(next);
  }
}

final entryCountProvider = AsyncNotifierProvider<EntryCountNotifier, int>(
  EntryCountNotifier.new,
);
