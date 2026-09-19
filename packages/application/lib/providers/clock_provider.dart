import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where "now" comes from.
///
/// Every figure that depends on the date — the months of runway, what is left
/// of this month's living budget per remaining day, the countdown to the next
/// subscription charge — read the system clock directly, each at its own call
/// site. That made the store screenshots impossible to reproduce: identical
/// code produced different pixels on a different day, so the committed set
/// read stale a fortnight after capture and every rerun was a byte diff.
///
/// A function rather than a value, so the app still asks the real clock every
/// time it needs to know and nothing freezes mid-session. Only a test pins it.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
