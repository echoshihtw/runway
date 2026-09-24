import 'package:flutter/material.dart';

/// Motion the viewer did not start.
///
/// Reduce Motion is not a request for stillness. It is a request to stop
/// motion that happens *to* you — a page travelling sideways, a dot
/// stretching on its own, a step sliding in — because for someone with a
/// vestibular condition that is a trigger for real vertigo, not a matter of
/// taste. The viewer has already told the system they want less of it, and an
/// app that animates anyway is overriding an instruction it was given.
///
/// Motion bounded by a finger is not that, and stays. A button compressing
/// while held is the app answering; take it away and nothing confirms the tap
/// landed. Press feedback, a chevron turning on the card you just tapped and
/// a fill following your selection do not belong here.
abstract final class AppMotion {
  /// Whether the system has asked for less motion.
  static bool isReduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// [normally], or no time at all when the system has asked for less.
  static Duration unprompted(BuildContext context, Duration normally) =>
      isReduced(context) ? Duration.zero : normally;
}
