/// Where the number of entries logged on this device is kept.
///
/// It must survive reinstalling the app, so the free entry limit can't be
/// reset by deleting and reinstalling. It isn't the user's data, so Delete all
/// data leaves it alone.
abstract class EntryCountStore {
  Future<int> read();
  Future<void> write(int count);
}
