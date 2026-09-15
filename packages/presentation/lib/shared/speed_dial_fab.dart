import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class SpeedDialFab extends StatefulWidget {
  final VoidCallback onEntry;
  final VoidCallback onLoan;
  final VoidCallback onSubscription;
  final IconData icon;
  final bool monochromeOptions;
  final void Function(bool isOpen)? onOpenChanged;

  const SpeedDialFab({
    super.key,
    required this.onEntry,
    required this.onLoan,
    required this.onSubscription,
    this.icon = Icons.add_rounded,
    this.monochromeOptions = false,
    this.onOpenChanged,
  });

  @override
  State<SpeedDialFab> createState() => SpeedDialFabState();
}

class SpeedDialFabState extends State<SpeedDialFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void toggle() {
    setState(() => _open = !_open);
    _open ? _ctrl.forward() : _ctrl.reverse();
    widget.onOpenChanged?.call(_open);
  }

  void close() {
    if (_open) {
      setState(() => _open = false);
      _ctrl.reverse();
      widget.onOpenChanged?.call(false);
    }
  }

  void _fire(VoidCallback action) {
    close();
    WidgetsBinding.instance.addPostFrameCallback((_) => action());
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      _DialOption(
        label: 'ENTRY',
        icon: Icons.add_rounded,
        color: widget.monochromeOptions ? AppColors.neonGreen : AppColors.neonGreen,
        index: 0,
      ),
      _DialOption(
        label: 'NEW LOAN',
        icon: Icons.credit_score_rounded,
        color: widget.monochromeOptions ? AppColors.neonGreen : AppColors.gold,
        index: 1,
      ),
      _DialOption(
        label: 'SUBSCRIPTIONS',
        icon: Icons.loop_rounded,
        color: widget.monochromeOptions ? AppColors.neonGreen : AppColors.purple,
        index: 2,
      ),
    ];

    final callbacks = [
      () => _fire(widget.onEntry),
      () => _fire(widget.onLoan),
      () => _fire(widget.onSubscription),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int i = options.length - 1; i >= 0; i--)
          SpeedDialOption(
            option: options[i],
            animation: CurvedAnimation(
              parent: _ctrl,
              curve: Interval(
                i * 0.1,
                0.8 + i * 0.1,
                curve: Curves.easeOut,
              ),
            ),
            onTap: callbacks[i],
          ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: toggle,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Transform.rotate(
              angle: _ctrl.value * 3.14159 / 4,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.neonGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonGreen.withAlpha(80),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color: AppColors.background,
                  size: 26,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DialOption {
  final String label;
  final IconData icon;
  final Color color;
  final int index;
  const _DialOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.index,
  });
}

class SpeedDialOption extends StatelessWidget {
  final _DialOption option;
  final Animation<double> animation;
  final VoidCallback onTap;

  const SpeedDialOption({
    super.key,
    required this.option,
    required this.animation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.4),
          end: Offset.zero,
        ).animate(animation),
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: GestureDetector(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: option.color.withAlpha(22),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: option.color.withAlpha(80),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(option.icon, color: option.color, size: 15),
                      const SizedBox(width: AppSpacing.xs + 2),
                      Text(
                        option.label,
                        style: AppTextStyles.caption.copyWith(
                          color: option.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
