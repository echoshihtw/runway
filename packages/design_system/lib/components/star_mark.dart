import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';

/// The app icon's star, drawn rather than pictured, so it takes the colour and
/// size of wherever it is used.
///
/// Seven points, and not a regular seven: the tips sit at uneven angles and
/// reach different distances, which is what makes it this star rather than a
/// generic one. The icon's centre highlight is left out, because at 48pt it is
/// under two pixels and reads as a speck. No Unicode glyph has seven points, so
/// this is a path.
class StarMark extends StatelessWidget {
  const StarMark({super.key, this.size = 48, this.color});

  final double size;

  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(painter: _StarPainter(color ?? AppColors.neonGreen)),
  );
}

class _StarPainter extends CustomPainter {
  const _StarPainter(this.color);

  final Color color;

  /// Traced from `assets/brand/runway-icon-1024.png`, alternating tip and
  /// valley, in a 100 by 100 box. Keep in step with the icon if it is redrawn.
  static const _outline = <Offset>[
    Offset(93.85, 55.77), Offset(67.20, 60.65),
    Offset(78.17, 87.38), Offset(50.39, 67.65),
    Offset(36.77, 96.14), Offset(36.21, 64.53),
    Offset(6.05, 64.92), Offset(30.83, 48.41),
    Offset(16.89, 25.05), Offset(49.04, 29.99),
    Offset(54.76, 8.22), Offset(62.39, 33.26),
    Offset(87.48, 24.00), Offset(71.59, 48.96),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.shortestSide / 100;
    final path = Path()..addPolygon([
      for (final p in _outline) Offset(p.dx * k, p.dy * k),
    ], true);

    canvas.drawPath(path, Paint()..color = color..isAntiAlias = true);
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.color != color;
}
