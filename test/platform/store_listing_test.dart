import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

/// Each text of the listings and the most characters its store takes.
const _limits = {
  'fastlane/metadata/android/es-ES/title.txt': 30,
  'fastlane/metadata/android/es-ES/short_description.txt': 80,
  'fastlane/metadata/android/es-ES/full_description.txt': 4000,
  'fastlane/metadata/es-ES/name.txt': 30,
  'fastlane/metadata/es-ES/subtitle.txt': 30,
  'fastlane/metadata/es-ES/promotional_text.txt': 170,
  'fastlane/metadata/es-ES/description.txt': 4000,
  'fastlane/metadata/es-ES/keywords.txt': 100,
  'fastlane/metadata/es-ES/release_notes.txt': 4000,
};

void main() {
  _limits.forEach((path, limit) {
    test('$path fits its store ($limit characters)', () {
      final text = _read(path);
      expect(text.trim(), isNotEmpty);
      expect(text.runes.length, lessThanOrEqualTo(limit));
    });
  });

  test('App Store keywords: commas without spaces, none repeating the '
      'name', () {
    final keywords = _read('fastlane/metadata/es-ES/keywords.txt').split(',');
    for (final keyword in keywords) {
      expect(keyword, keyword.trim());
      expect(keyword.toLowerCase(), isNot(contains('más mus')));
    }
    expect(keywords.toSet(), hasLength(keywords.length));
  });

  test('the stores link to the site, its privacy page and nowhere else', () {
    expect(
      _read('fastlane/metadata/es-ES/support_url.txt'),
      'https://masmus.larri.dev/',
    );
    expect(
      _read('fastlane/metadata/es-ES/marketing_url.txt'),
      'https://masmus.larri.dev/',
    );
    expect(
      _read('fastlane/metadata/es-ES/privacy_url.txt'),
      'https://masmus.larri.dev/privacy/',
    );
  });

  test('the screenshots, the feature graphic and the icon are there, as '
      'JPEG where the stores refuse alpha', () {
    List<String> files(String dir) =>
        Directory(dir).listSync().map((file) => file.path).toList()..sort();
    final appStore = files('fastlane/screenshots/es-ES');
    final play = files(
      'fastlane/metadata/android/es-ES/images/phoneScreenshots',
    );
    expect(appStore, hasLength(6));
    expect(play, hasLength(6));
    expect([...appStore, ...play], everyElement(endsWith('.jpg')));
    expect(
      File(
        'fastlane/metadata/android/es-ES/images/featureGraphic.jpg',
      ).existsSync(),
      isTrue,
    );
    expect(
      File('fastlane/metadata/android/es-ES/images/icon.png').existsSync(),
      isTrue,
    );
  });
}
