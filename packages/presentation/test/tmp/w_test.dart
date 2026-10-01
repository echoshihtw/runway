import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('real widths', (tester) async {
    tester.view.physicalSize = const Size(2000 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final items = <String, TextStyle>{
      'SEP 2026': AppTextStyles.sectionTitle,
      'NET': AppTextStyles.caption,
      '-\$ 1,250': AppTextStyles.metricSmall,
      '-\$ 12,500': AppTextStyles.metricSmall,
      '-\$ 125,000': AppTextStyles.metricSmall,
      '-NT\$ 12,500': AppTextStyles.metricSmall,
    };
    for (final scale in [2.0, 2.35]) {
      for (final e in items.entries) {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Scaffold(
                body: Align(
                  alignment: Alignment.topLeft,
                  child: Text(e.key, style: e.value, maxLines: 1),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        // ignore: avoid_print
        print('W scale=$scale ${e.key.padRight(13)} '
            '${tester.getSize(find.text(e.key)).width.toStringAsFixed(0)}');
      }
    }
  });
}
