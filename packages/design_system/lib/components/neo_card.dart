import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

class NeoCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsets? padding;
  final Color? accentColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const NeoCard({
    super.key,
    this.title,
    required this.child,
    this.padding,
    this.accentColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // A card that does nothing when tapped must not claim to be a control,
    // so the role is added only when there is something to activate. The
    // contents keep their own nodes: a card holds figures worth reading one
    // at a time, unlike a button, which is a label.
    return Semantics(
      button: onTap != null,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.cardBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) _buildHeader(),
              Padding(
                padding:
                    padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          if (accentColor != null) ...[
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          // The card decides the case, not the translation. Titles are
          // written in sentence case and uppercased here, so the voice is the
          // same on every card and a locale that has no case is untouched —
          // toUpperCase is the identity on Japanese and Chinese.
          Text(title!.toUpperCase(), style: AppTextStyles.sectionTitle),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}
