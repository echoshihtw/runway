import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

/// Owns the root ProviderScope so "Delete all data" can restart the app in
/// place with an empty database, without relaunching the process.
class RunwayRoot extends StatefulWidget {
  const RunwayRoot({
    super.key,
    required this.openSession,
    required this.eraseAllData,
    required this.onRestarted,
    required this.child,
  });

  /// Opens a database and returns the provider overrides that depend on it.
  /// Called once at start and again after every erase.
  final List<Override> Function() openSession;

  /// Closes the current database and erases all user data. Runs only after
  /// the previous ProviderScope, and every stream it held, is disposed.
  final Future<void> Function() eraseAllData;

  /// Called before the new session starts, to reset navigation.
  final VoidCallback onRestarted;

  final Widget child;

  @override
  State<RunwayRoot> createState() => _RunwayRootState();
}

class _RunwayRootState extends State<RunwayRoot> implements DataResetService {
  late List<Override> _overrides = widget.openSession();
  int _session = 0;
  bool _erasing = false;

  @override
  Future<void> deleteAllData() async {
    if (_erasing) return;
    setState(() => _erasing = true);
    // Let the frame unmount the ProviderScope before the database closes.
    await WidgetsBinding.instance.endOfFrame;
    try {
      await widget.eraseAllData();
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'runway',
          context: ErrorDescription('while deleting all data'),
        ),
      );
    } finally {
      if (mounted) {
        widget.onRestarted();
        setState(() {
          _overrides = widget.openSession();
          _session++;
          _erasing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_erasing) {
      return const ColoredBox(
        color: AppColors.background,
        child: SizedBox.expand(),
      );
    }
    return ProviderScope(
      key: ValueKey(_session),
      overrides: [
        ..._overrides,
        dataResetServiceProvider.overrideWithValue(this),
      ],
      child: widget.child,
    );
  }
}
