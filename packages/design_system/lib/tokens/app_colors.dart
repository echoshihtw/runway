import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Backgrounds ──────────────────────────────
  static const background = Color(0xFF040D1A);
  static const backgroundTop = Color(0xFF071229);
  static const surface = Color(0xFF060F1E);
  static const surfaceHigh = Color(0xFF08172E);
  static const cardBorder = Color(0xFF0D1F3A);

  // ── BRAND TRIO ────────────────────────────────
  static const turkishBlue = Color(0xFF5B9DC4); // soft sky blue
  static const neonGreen = Color(0xFF8FDDAA); // muted sage mint
  static const hotPink = Color(0xFFE8829E); // muted rose pink

  // ── Semantic aliases from brand trio ─────────
  static const green = neonGreen;
  static const blue = turkishBlue;
  static const red = hotPink;
  static const gold = Color(0xFFCB9A3E); // muted amber — debt only
  static const amber = Color(0xFFFFC978); // light amber — caution status
  static const purple = Color(0xFFBB6DFF); // keep purple for subscriptions

  // ── Text ─────────────────────────────────────
  static const textPrimary = Color(0xFFCDD5E0); // soft blue-smoke
  static const textSecondary = Color(0xFF6B7F96); // softer mid-tone
  static const textDim = Color(0xFF2A3D5A); // dark blue-grey

  // ── Status ────────────────────────────────────
  static const stable = neonGreen;
  static const caution = amber;
  static const critical = hotPink;
  static const safe = turkishBlue;

  // ── Gradients ─────────────────────────────────
  static const gradientGreen = LinearGradient(
    colors: [Color(0xFF39FF14), Color(0xFF00C896)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const gradientBlue = LinearGradient(
    colors: [Color(0xFF007FAE), Color(0xFF00B4D8)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const gradientPink = LinearGradient(
    colors: [Color(0xFFFF2D78), Color(0xFFFF6B6B)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const gradientGold = LinearGradient(
    colors: [Color(0xFFF0B429), Color(0xFFFF8C00)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const gradientBackground = LinearGradient(
    colors: [backgroundTop, background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5],
  );

  // ── Legacy aliases ────────────────────────────
  static const primaryGreen = neonGreen;
  static const dimGreen = textDim;
  static const danger = hotPink;
  static const panelBorder = cardBorder;
  static const scanline = Color(0x00000000);
}
