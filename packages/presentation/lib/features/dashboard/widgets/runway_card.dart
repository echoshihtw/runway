import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:application/application.dart';
import 'package:intl/intl.dart';
import '../../../shared/status_color.dart';

class RunwayCard extends ConsumerWidget {
  final ModelState model;
  const RunwayCard({super.key, required this.model});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final symbol = ref.watch(currencyProvider).value?.symbol ?? '¥';
    final nf = NumberFormat('#,##0', 'en_US');
    final status = model.survivalStatus;

    // With no cost known the runway cannot be stated, so it must not borrow
    // the confidence of a status colour.
    final known = model.runwayIsKnown;
    final color = known ? statusColor(status) : AppColors.textSecondary;
    final statusLabel = switch (status) {
      SurvivalStatus.stable => l10n.stable,
      SurvivalStatus.caution => l10n.caution,
      SurvivalStatus.critical => l10n.critical,
    };

    String fmtRunwayMonths(int m) {
      if (!known) return '—';
      if (m >= 9999) return '∞';
      return '$m';
    }

    String fmtRunwayMonthUnit(int m) {
      if (!known || m >= 9999) return '';
      return m == 1 ? l10n.monthSingular : l10n.monthPlural;
    }

    String fmtSustainability() {
      if (!model.hasSustainableProjection) return '';
      if (model.isSustainableIndefinitely) {
        return l10n.sustainableWithExpectedInflow;
      }
      return l10n.shortByPerMonth(
        '$symbol ${nf.format(model.sustainableMonthlyShortfall)}',
      );
    }

    String fmtDate(DateTime? d) =>
        d == null ? '—' : DateFormat('MMM yyyy').format(d).toUpperCase();

    final glassEnabled = ref.watch(displayProvider).value ?? false;
    return LiquidGlassContainer(
      glassEnabled: glassEnabled,
      accentColor: color,
      child: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    fmtRunwayMonths(model.runwayMonths),
                    style: AppTextStyles.heroLarge.copyWith(
                      color: color,
                      fontSize: 72,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    ' ${fmtRunwayMonthUnit(model.runwayMonths)}',
                    style: AppTextStyles.metric.copyWith(
                      color: color.withAlpha(180),
                    ),
                  ),
                ],
              ),
              Text(
                known ? l10n.ifIncomePausedToday : l10n.runwayNeedsCosts,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall,
              ),
              if (known) ...[
                const SizedBox(height: AppSpacing.md),
                PixelBadge(label: statusLabel, color: color),
              ],
              if (model.hasSustainableProjection) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  fmtSustainability(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: model.isSustainableIndefinitely
                        ? AppColors.green
                        : AppColors.gold,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Divider(color: Colors.white.withAlpha(15), height: 1),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _stat(
                      l10n.cash,
                      '$symbol ${nf.format(model.currentCash)}',
                      AppColors.green,
                    ),
                  ),
                  Expanded(
                    child: _stat(
                      l10n.runOut,
                      fmtDate(model.runOutDate),
                      AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          style: AppTextStyles.metricSmall.copyWith(color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ── Liquid Glass Card ─────────────────────────────────────────
class _LiquidGlassCard extends StatefulWidget {
  final Widget child;
  final Color accentColor;

  const _LiquidGlassCard({required this.child, required this.accentColor});

  @override
  State<_LiquidGlassCard> createState() => _LiquidGlassCardState();
}

class _LiquidGlassCardState extends State<_LiquidGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  color: Colors.transparent,
                ),
              ),
            ),
          ),

          CustomPaint(
            painter: _GlassBodyPainter(
              t: _ctrl.value,
              accentColor: widget.accentColor,
              radius: AppSpacing.cardRadius,
            ),
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                color: Colors.transparent,
              ),
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: child,
            ),
          ),

          CustomPaint(
            painter: _GlassRimPainter(
              t: _ctrl.value,
              radius: AppSpacing.cardRadius,
            ),
          ),
        ],
      ),
      child: widget.child,
    );
  }
}

class _GlassBodyPainter extends CustomPainter {
  final double t;
  final Color accentColor;
  final double radius;

  _GlassBodyPainter({
    required this.t,
    required this.accentColor,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    canvas.drawRRect(
      rrect,
      Paint()..color = const Color(0xFF111318).withAlpha(200),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.4, 1.0],
          colors: [
            Colors.white.withAlpha(18),
            Colors.white.withAlpha(5),
            Colors.white.withAlpha(0),
          ],
        ).createShader(rect),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.5),
          radius: 1.2,
          colors: [accentColor.withAlpha(12), accentColor.withAlpha(0)],
        ).createShader(rect),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: const [0.0, 0.3],
          colors: [Colors.black.withAlpha(40), Colors.black.withAlpha(0)],
        ).createShader(rect),
    );

    final shimmerX = 0.5 + cos(t * 2 * pi) * 0.3;
    final shimmerY = 0.3 + sin(t * pi) * 0.2;
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(shimmerX * 2 - 1, shimmerY * 2 - 1),
          radius: 0.6,
          colors: [
            Colors.white.withAlpha(
              (12 * (0.5 + 0.5 * sin(t * 2 * pi))).round(),
            ),
            Colors.white.withAlpha(0),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GlassBodyPainter old) => old.t != t;
}

class _GlassRimPainter extends CustomPainter {
  final double t;
  final double radius;

  _GlassRimPainter({required this.t, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..shader = SweepGradient(
          center: Alignment.topLeft,
          startAngle: -pi * 0.25,
          endAngle: -pi * 0.25 + pi * 2,
          stops: const [0.0, 0.08, 0.25, 0.5, 0.75, 0.92, 1.0],
          colors: [
            Colors.white.withAlpha(180),
            Colors.white.withAlpha(80),
            Colors.white.withAlpha(20),
            Colors.white.withAlpha(8),
            Colors.white.withAlpha(12),
            Colors.white.withAlpha(60),
            Colors.white.withAlpha(180),
          ],
        ).createShader(rect),
    );

    final innerRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      Radius.circular(radius - 1),
    );
    canvas.drawRRect(
      innerRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..shader = SweepGradient(
          center: Alignment.topLeft,
          startAngle: -pi * 0.25,
          endAngle: -pi * 0.25 + pi * 2,
          stops: const [0.0, 0.15, 0.5, 1.0],
          colors: [
            Colors.white.withAlpha(60),
            Colors.white.withAlpha(15),
            Colors.white.withAlpha(3),
            Colors.white.withAlpha(60),
          ],
        ).createShader(Rect.fromLTWH(1, 1, size.width - 2, size.height - 2)),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(radius * 0.3, 0, size.width - radius * 0.6, 1),
        const Radius.circular(1),
      ),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withAlpha(0),
            Colors.white.withAlpha(120),
            Colors.white.withAlpha(120),
            Colors.white.withAlpha(0),
          ],
          stops: const [0.0, 0.2, 0.8, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, size.width, 1)),
    );
  }

  @override
  bool shouldRepaint(_GlassRimPainter old) => old.t != t;
}
