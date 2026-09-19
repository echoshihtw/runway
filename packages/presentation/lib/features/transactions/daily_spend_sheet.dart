import 'package:application/application.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../product_config.dart';
import '../../shared/pro_gate.dart';
import 'show_entry_sheet.dart';

/// What the add button asks now: not which kind of record this is, but what
/// was bought.
///
/// The presets partition by occasion rather than by item. If two could ever
/// answer the same tap, one of them is redundant — coffee and drinks compete,
/// lunch and dinner never do, because one is reached for at noon and the
/// other at seven, and the notes stay worth reading back.
///
/// A preset fills the note and nothing else. Carrying an amount as well would
/// log money in a single tap, and one tap that writes money needs an undo,
/// which does not exist yet.
Future<void> showDailySpendSheet(BuildContext context, WidgetRef ref) {
  if (!allowsNewEntry(context, ref)) return Future<void>.value();
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    // Without this the sheet is capped near half the screen, and at a doubled
    // text size the title and two rows of tiles do not fit in that.
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.cardRadius),
      ),
    ),
    builder: (sheetContext) {
      final l10n = sheetContext.l10n;

      final presets = ProductConfig.presets;
      // Shown once the first is spent: the paywall must never arrive
      // unannounced, and a count nobody can see reads as arbitrary.
      final used = ref.read(entryCountProvider).value ?? 0;
      final showUsage = used > 0 && !isProOwner(ref);

      void choose(DailySpendPreset preset) {
        Navigator.of(sheetContext).pop();
        // Let the sheet finish closing before the form's own sheet opens, or
        // the two routes animate over each other.
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => showEntrySheet(context, ref, prefillNote: preset.note?.call(l10n)),
        );
      }

      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.spendOnWhat,
                style: AppTextStyles.title.copyWith(color: AppColors.neonGreen),
              ),
              if (showUsage) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.freeEntriesUsed(used, ProductConfig.freeEntries),
                  style: AppTextStyles.caption,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              for (var row = 0; row < 2; row++) ...[
                if (row > 0) const SizedBox(height: AppSpacing.sm),
                // A row of three, each tile taking a third of the width and
                // the row's height coming from its tallest label. Nothing is
                // fixed, so a doubled text size makes tiles taller instead of
                // pushing them off the screen.
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var col = 0; col < 3; col++) ...[
                        if (col > 0) const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _Tile(
                            preset: presets[row * 3 + col],
                            onTap: () => choose(presets[row * 3 + col]),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

class _Tile extends StatelessWidget {
  final DailySpendPreset preset;
  final VoidCallback onTap;

  const _Tile({required this.preset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = preset.dim ? AppColors.textSecondary : AppColors.neonGreen;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: color.withAlpha(preset.dim ? 10 : 22),
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          border: Border.all(color: color.withAlpha(preset.dim ? 45 : 80)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(preset.glyph, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              preset.label(context.l10n),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
