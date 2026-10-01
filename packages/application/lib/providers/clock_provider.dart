import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where "now" comes from.
///
/// Nothing reads DateTime.now at its own call site: a dated figure has to be
/// pinnable, or a screenshot run is not reproducible.
///
/// A function rather than a value, so the app still asks the real clock every
/// time it needs to know and nothing freezes mid-session. Only a test pins it.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
