import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../product_config.dart';
import 'pro_gate.dart';

/// How much of the free allowance is gone, wherever spending one is a tap away.
///
/// The paywall must never arrive unannounced, so every screen that can use up
/// a free entry shows how many are left.
///
/// Nothing is shown before the first is spent, or to an owner with Pro.
class FreeEntriesCaption extends ConsumerWidget {
  const FreeEntriesCaption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final used = ref.watch(entryCountProvider).value ?? 0;
    // Watched, not read: buying Pro from the paywall leaves this screen
    // mounted, and a const widget is not rebuilt by its parent.
    if (used == 0 || watchProOwner(ref)) return const SizedBox.shrink();
    // Aligned by itself, so where it is mounted cannot change where it sits.
    // In a Column that centres its children it was indenting 64pt and reading
    // as a second line of the button above it. Align rather than an infinite
    // SizedBox: same guarantee, and it shrink-wraps instead of throwing if a
    // future parent gives it an unbounded width.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          context.l10n.freeEntriesUsed(
            shownAsUsed(used: used, free: ProductConfig.freeEntries),
            ProductConfig.freeEntries,
          ),
          style: AppTextStyles.caption,
        ),
      ),
    );
  }
}
