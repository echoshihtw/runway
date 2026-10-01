import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where "now" comes from.
///
/// Code asks this instead of calling DateTime.now() itself, so a test can fix
/// the date. Without it, anything dated answers differently each day it runs,
/// and the store screenshots never match.
///
/// A function rather than a value, so the app still asks the real clock every
/// time it needs to know and nothing freezes mid-session. Only a test pins it.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
