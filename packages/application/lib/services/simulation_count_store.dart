/// Where the number of simulations run on this device is kept.
///
/// It must survive reinstalling the app, so the free simulation limit can't be
/// reset by deleting and reinstalling. It isn't the user's data, so Delete all
/// data leaves it alone.
abstract class SimulationCountStore {
  Future<int> read();
  Future<void> write(int count);
}
