import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// The three swipe screens as labelled dots. Tapping a label opens that
/// screen, so navigation doesn't depend on discovering the swipe.
class PageIndicator extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const PageIndicator({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = [l10n.navHud, l10n.navLog, l10n.navSim];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(labels.length, (i) {
        final active = i == currentIndex;
        final color = active
            ? AppColors.neonGreen
            : AppColors.textDim.withAlpha(160);
        // excludeSemantics hides the GestureDetector's tap from VoiceOver,
        // so the semantics node needs its own onTap.
        return Semantics(
          button: true,
          selected: active,
          label: labels[i],
          onTap: () => onSelect(i),
          excludeSemantics: true,
          child: GestureDetector(
            onTap: () => onSelect(i),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: AppMotion.unprompted(
                      context,
                      const Duration(milliseconds: 250),
                    ),
                    curve: Curves.easeOut,
                    width: active ? 18 : 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs + 1),
                  Text(
                    labels[i].toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      color: color,
                      fontSize: 9,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
