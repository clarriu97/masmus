import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Screens and components take colors and text styles from the theme (see
/// AGENTS.md → UI / UX rules).
void main() {
  final files = Directory('lib/ui')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .where((file) => !file.path.contains('/theme/'))
      .toList();

  test('there are files to check', () {
    expect(files, isNotEmpty);
  });

  for (final file in files) {
    test('${file.path} uses no literal colors or text styles', () {
      final source = file.readAsStringSync();
      expect(source, isNot(contains('Color(0x')));
      expect(source, isNot(contains('TextStyle(')));
      expect(source, isNot(contains(RegExp(r'\bColors\.'))));
      expect(source, isNot(contains('fontFamily')));
    });
  }
}
