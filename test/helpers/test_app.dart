import 'package:flutter/material.dart';
import 'package:masmus/l10n/app_localizations.dart';
import 'package:masmus/ui/theme/app_theme.dart';

/// [home] in a MaterialApp with the app's theme and texts. Pass [platform]
/// to exercise platform-specific behavior such as the iOS back swipe.
Widget buildTestApp(Widget home, {TargetPlatform? platform}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.tapete.copyWith(platform: platform),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

/// A single component, centered on a screen of the app.
Widget buildTestComponent(Widget child) =>
    buildTestApp(Scaffold(body: Center(child: child)));
