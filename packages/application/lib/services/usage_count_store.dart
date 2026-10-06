/// Where the per-device usage counts live — entries logged, simulations run.
///
/// They must survive reinstalling the app, so a free allowance can't be reset
/// by deleting and reinstalling. They aren't the user's data, so Delete all
/// data leaves them alone. One store, keyed by what it counts, so the two
/// counters cannot drift apart in how they are kept.
abstract class UsageCountStore {
  Future<int> read(String key);
  Future<void> write(String key, int count);
}
