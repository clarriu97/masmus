import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Bundled fonts are OFL-licensed; the license must ship with the app.
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (font, asset) in const [
      ('Young Serif', 'assets/fonts/OFL-YoungSerif.txt'),
      ('Alegreya Sans', 'assets/fonts/OFL-AlegreyaSans.txt'),
    ]) {
      yield LicenseEntryWithLineBreaks([
        font,
      ], await rootBundle.loadString(asset));
    }
  });
}
