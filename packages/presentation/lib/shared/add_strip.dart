import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// "One more" at the foot of a list, rather than a control in the header where
/// the tap already toggles the card.
///
/// Shared rather than copied per card: a second copy would have to re-learn
/// the 44pt minimum, and the first one did not have it.
class AddStrip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const AddStrip({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        // 44pt is Apple's minimum. The strip reads as one control all the way
        // down to the gap beneath the label, so the gap belongs inside the
        // target rather than just outside it.
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.cardBorder)),
        ),
        child: Center(
          child: Text(label, style: AppTextStyles.label.copyWith(color: color)),
        ),
      ),
    );
  }
}
