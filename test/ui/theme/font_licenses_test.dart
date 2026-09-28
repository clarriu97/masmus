import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/ui/theme/font_licenses.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('registers the OFL license of every bundled font', () async {
    registerFontLicenses();

    final entries = await LicenseRegistry.licenses.toList();
    for (final font in ['Young Serif', 'Alegreya Sans']) {
      final entry = entries.firstWhere((e) => e.packages.contains(font));
      final text = entry.paragraphs.map((p) => p.text).join(' ');
      expect(text, contains('SIL Open Font License'), reason: font);
    }
  });
}
