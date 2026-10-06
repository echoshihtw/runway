import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

class NeoExpandableCard extends StatefulWidget {
  final String title;
  final Widget summary;
  final Widget? details;
  final Color? accentColor;
  final bool initiallyExpanded;
  final Widget? trailing;

  const NeoExpandableCard({
    super.key,
    required this.title,
    required this.summary,
    this.details,
    this.accentColor,
    this.initiallyExpanded = false,
    this.trailing,
  });

  @override
  State<NeoExpandableCard> createState() => _NeoExpandableCardState();
}

class _NeoExpandableCardState extends State<NeoExpandableCard>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _ctrl;
  late Animation<double> _rotate;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: _expanded ? 1.0 : 0.0,
    );
    _rotate = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          //
          // MergeSemantics rather than excludeSemantics: the header can carry
          // a `trailing` widget with a figure in it, and that is worth
          // hearing. Merging keeps it and still announces the header once
          // instead of as three loose pieces of static text.
          //
          // A card with nothing to expand is not a control, so the role and
          // the expanded state are attached only when there are details.
          MergeSemantics(
            child: Semantics(
              button: widget.details != null,
              expanded: widget.details != null ? _expanded : null,
              onTap: widget.details != null ? _toggle : null,
              child: GestureDetector(
                onTap: widget.details != null ? _toggle : null,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.cardPadding,
                    vertical: AppSpacing.sm + 2,
                  ),
                  child: Row(
                    children: [
                      if (widget.accentColor != null) ...[
                        Container(
                          width: 3,
                          height: 14,
                          decoration: BoxDecoration(
                            color: widget.accentColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      // Expanded, not a Text beside a Spacer: the title is the
                      // one thing here that can be shortened, and at large text
                      // sizes an unflexed title pushes the chevron off the card.
                      Expanded(
                        child: Text(
                          // Sentence case in, upper case out. See NeoCard.
                          widget.title.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.sectionTitle,
                        ),
                      ),
                      if (widget.trailing != null) ...[
                        widget.trailing!,
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      if (widget.details != null)
                        RotationTransition(
                          turns: _rotate,
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textDim,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Summary
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.cardPadding,
              0,
              AppSpacing.cardPadding,
              AppSpacing.cardPadding,
            ),
            child: widget.summary,
          ),

          // Details
          if (widget.details != null)
            SizeTransition(
              sizeFactor: _fade,
              child: FadeTransition(
                opacity: _fade,
                child: Column(
                  children: [
                    const Divider(color: AppColors.cardBorder, height: 1),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.cardPadding),
                      child: widget.details!,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
