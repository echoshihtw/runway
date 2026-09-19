import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presentation/shared/status_color.dart';

void main() {
  test('caution is amber, so it is not the gold used for debt', () {
    expect(statusColor(RunwayStatus.caution), const Color(0xFFFFC978));
    expect(statusColor(RunwayStatus.caution), isNot(AppColors.gold));
    expect(statusColor(RunwayStatus.caution), isNot(SC.accentCost));
  });

  test('stable is mint and critical is pink', () {
    expect(statusColor(RunwayStatus.stable), SC.life);
    expect(statusColor(RunwayStatus.critical), SC.cost);
  });

  test('every status has its own colour', () {
    final colours = RunwayStatus.values.map(statusColor).toSet();
    expect(colours, hasLength(RunwayStatus.values.length));
  });
}
