// Driver for integration_test/screenshots_test.dart. Writes every frame the
// test captures to SCREENSHOT_DIR, which defaults to build/screenshots.
//
//   flutter drive --driver=test_driver/screenshots.dart \
//     --target=integration_test/screenshots_test.dart -d <simulator id>
//
// ignore_for_file: avoid_print
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final directory = Directory(
    Platform.environment['SCREENSHOT_DIR'] ?? 'build/screenshots',
  );
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? _]) async {
      await directory.create(recursive: true);
      final file = File('${directory.path}/$name.png');
      await file.writeAsBytes(bytes);
      print('screenshot: ${file.path} (${bytes.length} bytes)');
      return true;
    },
  );
}
