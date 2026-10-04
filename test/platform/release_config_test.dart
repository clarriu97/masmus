import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/ui/about/about_screen.dart';

String _read(String path) => File(path).readAsStringSync();

/// The `<array>` or value that follows `<key>key</key>` in a plist.
String _plistValue(String plist, String key) {
  final match = RegExp(
    '<key>$key</key>\\s*(<array>.*?</array>|<array/>|<[a-z]+/>|<[a-z]+>[^<]*</[a-z]+>)',
    dotAll: true,
  ).firstMatch(plist);
  expect(match, isNotNull, reason: '$key is missing');
  return match!.group(1)!;
}

void main() {
  test('the version shown in Acerca de is the one in pubspec.yaml', () {
    final version = RegExp(
      r'^version: (\d+\.\d+\.\d+)\+(\d+)$',
      multiLine: true,
    ).firstMatch(_read('pubspec.yaml'));
    expect(version, isNotNull);
    expect(appVersion, version!.group(1));
    expect(appBuild, int.parse(version.group(2)!));
  });

  group('iOS', () {
    final plist = _read('ios/Runner/Info.plist');

    test('takes the version and build number from pubspec', () {
      expect(
        _plistValue(plist, 'CFBundleShortVersionString'),
        r'<string>$(FLUTTER_BUILD_NAME)</string>',
      );
      expect(
        _plistValue(plist, 'CFBundleVersion'),
        r'<string>$(FLUTTER_BUILD_NUMBER)</string>',
      );
    });

    test('iPhone only, in portrait', () {
      expect(
        RegExp(r'<string>(UIInterfaceOrientation\w+)</string>')
            .allMatches(_plistValue(plist, 'UISupportedInterfaceOrientations'))
            .map((match) => match.group(1)),
        ['UIInterfaceOrientationPortrait'],
      );
      expect(plist, isNot(contains('~ipad')));
      final project = _read('ios/Runner.xcodeproj/project.pbxproj');
      expect(
        RegExp(
          r'TARGETED_DEVICE_FAMILY = ([^;]+);',
        ).allMatches(project).map((match) => match.group(1)).toSet(),
        {'1'},
      );
    });

    test('declares no non-exempt encryption', () {
      expect(_plistValue(plist, 'ITSAppUsesNonExemptEncryption'), '<false/>');
    });

    test('a privacy manifest in the app: no tracking, no data collected', () {
      final manifest = _read('ios/Runner/PrivacyInfo.xcprivacy');
      expect(_plistValue(manifest, 'NSPrivacyTracking'), '<false/>');
      expect(_plistValue(manifest, 'NSPrivacyTrackingDomains'), '<array/>');
      expect(_plistValue(manifest, 'NSPrivacyCollectedDataTypes'), '<array/>');
      expect(
        _read('ios/Runner.xcodeproj/project.pbxproj'),
        contains('PrivacyInfo.xcprivacy in Resources */,'),
      );
    });
  });

  group('Android', () {
    final gradle = _read('android/app/build.gradle.kts');

    test('takes versionCode and versionName from pubspec', () {
      expect(gradle, contains('versionCode = flutter.versionCode'));
      expect(gradle, contains('versionName = flutter.versionName'));
    });

    test('release is shrunk with R8 and signed from key.properties, which '
        'git never sees', () {
      expect(gradle, contains('isMinifyEnabled = true'));
      expect(gradle, contains('isShrinkResources = true'));
      expect(gradle, contains('rootProject.file("key.properties")'));
      expect(_read('android/.gitignore'), contains('key.properties'));
    });

    test('can open the web and write mail from Acerca de', () {
      final manifest = _read('android/app/src/main/AndroidManifest.xml');
      expect(manifest, contains('android:scheme="https"'));
      expect(manifest, contains('android:scheme="mailto"'));
    });
  });
}
