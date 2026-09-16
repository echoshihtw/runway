import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import '../../../shared/status_color.dart';

class StatusBadge extends StatelessWidget {
  final RunwayStatus status;
  const StatusBadge({super.key, required this.status});

  Color get _color => statusColor(status);

  String _label(AppLocalizations l10n) => switch (status) {
    RunwayStatus.stable => l10n.stable,
    RunwayStatus.caution => l10n.caution,
    RunwayStatus.critical => l10n.critical,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, color: _color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          _label(context.l10n),
          style: AppTextStyles.value.copyWith(color: _color),
        ),
      ],
    );
  }
}
