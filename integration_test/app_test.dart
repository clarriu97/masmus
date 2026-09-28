// Single entry point for every end-to-end flow, so the app is built and
// installed once per run instead of once per file:
//   flutter test integration_test/app_test.dart -d <device-id>
// (one flow: add --plain-name '<test name>')
import 'package:flutter_test/flutter_test.dart';

import 'flows/resume_flow.dart';
import 'flows/start_flow.dart';
import 'flows/table_flow.dart';
import 'helpers.dart';

void main() {
  setUpE2E();

  group('start', startFlows);
  group('table', tableFlows);
  group('resume', resumeFlows);
}
