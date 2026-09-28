import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:masmus/main.dart';

void setUpE2E() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
}

/// Starts the app the way `main()` does.
Future<void> launchApp(WidgetTester tester) async {
  await tester.pumpWidget(const MasmusApp());
  await tester.pumpAndSettle();
}

/// Waits for [finder] to show (or, with [gone], to disappear), pumping frames
/// in real time: bots think and pause on a real clock.
Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  bool gone = false,
  Duration timeout = const Duration(seconds: 20),
}) async {
  final end = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty != gone) {
    if (DateTime.now().isAfter(end)) {
      throw TestFailure('${gone ? 'Still showing' : 'Never showed'}: $finder');
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
}
