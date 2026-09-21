import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'paywall_screen.dart';

class ProLockedCard extends StatelessWidget {
  final String title;
  final Color accentColor;
  final String feature;

  const ProLockedCard({
    super.key,
    required this.title,
    required this.accentColor,
    required this.feature,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPaywall(context, trigger: feature),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            // Accent bar
            Container(
              width: 3,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
              margin: const EdgeInsets.only(right: AppSpacing.sm),
            ),
            // Title
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: AppTextStyles.sectionTitle,
              ),
            ),
            // Lock badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withAlpha(15),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppColors.neonGreen.withAlpha(40)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    color: AppColors.neonGreen,
                    size: 11,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'PRO',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.neonGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
