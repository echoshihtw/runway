import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

enum NeoButtonVariant { primary, secondary, ghost, danger }

class NeoButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final NeoButtonVariant variant;
  final bool fullWidth;
  final String? icon;
  final Color? color;

  const NeoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = NeoButtonVariant.secondary,
    this.fullWidth = false,
    this.icon,
    this.color,
  });

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _bgColor => switch (widget.variant) {
    NeoButtonVariant.primary => widget.color ?? AppColors.neonGreen,
    NeoButtonVariant.secondary => AppColors.surfaceHigh,
    NeoButtonVariant.ghost => Colors.transparent,
    NeoButtonVariant.danger => AppColors.hotPink.withAlpha(20),
  };

  Color get _borderColor => switch (widget.variant) {
    NeoButtonVariant.primary => Colors.transparent,
    NeoButtonVariant.secondary =>
      widget.color != null
          ? widget.color!.withAlpha(120)
          : AppColors.cardBorder,
    NeoButtonVariant.ghost => AppColors.cardBorder,
    NeoButtonVariant.danger => AppColors.red.withAlpha(80),
  };

  Color get _textColor => switch (widget.variant) {
    NeoButtonVariant.primary => AppColors.background,
    NeoButtonVariant.secondary => AppColors.textPrimary,
    NeoButtonVariant.ghost => AppColors.textSecondary,
    NeoButtonVariant.danger => AppColors.hotPink,
  };

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    return GestureDetector(
      onTapDown: disabled
          ? null
          : (_) {
              HapticFeedback.selectionClick();
              _ctrl.forward();
            },
      onTapUp: disabled
          ? null
          : (_) {
              _ctrl.reverse();
              widget.onPressed?.call();
            },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: disabled ? 0.4 : 1.0,
          child: Container(
            width: widget.fullWidth ? double.infinity : null,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: _bgColor,
              // Pill shape — Kraken style
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: _borderColor, width: 1),
            ),
            child: Row(
              mainAxisSize: widget.fullWidth
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Text(
                    widget.icon!,
                    style: TextStyle(color: _textColor, fontSize: 14),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                // The label yields rather than pushing the button past its
                // own edge at large text sizes. This only bites where the
                // button is given a width to fit inside: a non-fullWidth
                // NeoButton laid out as a plain child of a Row gets unbounded
                // constraints, the Flexible below is then treated as non-flex,
                // and the label lays out at its intrinsic width regardless.
                // Those callers have to bound the button themselves (#178).
                Flexible(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.button.copyWith(color: _textColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
