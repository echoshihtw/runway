import 'package:design_system/design_system.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 2.1 relative luminance.
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

double _contrast(Color a, Color b) {
  final la = _luminance(a), lb = _luminance(b);
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

const _surfaces = {
  'background': AppColors.background,
  'surface': AppColors.surface,
  'surfaceHigh': AppColors.surfaceHigh,
};

void main() {
  // The caption default sat at 1.75:1 on surface, two and a half times under
  // the bar, and it is the style hints and sub-labels use throughout (#147).
  group('text meets WCAG AA, 4.5:1', () {
    for (final tier in {
      'textPrimary': AppColors.textPrimary,
      'textSecondary': AppColors.textSecondary,
    }.entries) {
      for (final surface in _surfaces.entries) {
        test('${tier.key} on ${surface.key}', () {
          expect(
            _contrast(tier.value, surface.value),
            greaterThanOrEqualTo(4.5),
          );
        });
      }
    }
  });

  group('icons and decoration meet 3:1', () {
    for (final surface in _surfaces.entries) {
      test('textDim on ${surface.key}', () {
        expect(_contrast(AppColors.textDim, surface.value), greaterThanOrEqualTo(3.0));
      });
    }
  });

  test('the three tiers stay ordered, dimmest to brightest', () {
    expect(_luminance(AppColors.textDim), lessThan(_luminance(AppColors.textSecondary)));
    expect(_luminance(AppColors.textSecondary), lessThan(_luminance(AppColors.textPrimary)));
  });

  test('the caption colour is not the icon tier', () {
    // textDim is legal for icons and nothing else; a caption reaching for it
    // is the regression this file exists to catch. Asserted on the semantic
    // token rather than AppTextStyles.caption, which builds through
    // GoogleFonts and would try to fetch a font in a unit test.
    expect(SC.captionColor, isNot(AppColors.textDim));
    expect(
      _contrast(SC.captionColor, AppColors.surface),
      greaterThanOrEqualTo(4.5),
    );
  });
}
