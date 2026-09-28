import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../product_config.dart';
import 'pro_gate.dart';

/// How much of the free allowance is gone, wherever spending one is a tap away.
///
/// The rule is already written in daily_spend_sheet: the paywall must never
/// arrive unannounced, and a count nobody can see reads as arbitrary. It was
/// implemented in that one place, so tapping a loan met the wall with no
/// warning at all.
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
    // Full width and start-aligned, so where it is mounted cannot change
    // where it sits. In a Column that centres its children it was indenting
    // 64pt and reading as a second line of the button above it.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          context.l10n.freeEntriesUsed(
            shownAsUsed(used: used, free: ProductConfig.freeEntries),
            ProductConfig.freeEntries,
          ),
          textAlign: TextAlign.start,
          style: AppTextStyles.caption,
        ),
      ),
    );
  }
}
