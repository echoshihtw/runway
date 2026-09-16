import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/shared/status_color.dart';

void main() {
  test('caution is amber, so it is not the gold used for debt', () {
    expect(statusColor(SurvivalStatus.caution), const Color(0xFFFFC978));
    expect(statusColor(SurvivalStatus.caution), isNot(AppColors.gold));
    expect(statusColor(SurvivalStatus.caution), isNot(SC.accentCost));
  });

  test('stable is mint and critical is pink', () {
    expect(statusColor(SurvivalStatus.stable), SC.life);
    expect(statusColor(SurvivalStatus.critical), SC.cost);
  });

  test('every status has its own colour', () {
    final colours = SurvivalStatus.values.map(statusColor).toSet();
    expect(colours, hasLength(SurvivalStatus.values.length));
  });
}
