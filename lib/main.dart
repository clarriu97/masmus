import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'l10n/app_localizations.dart';
import 'ui/start/start_screen.dart';
import 'ui/table/table_page.dart';
import 'ui/theme/app_theme.dart';
import 'ui/theme/font_licenses.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicenses();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.none,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.feltDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MasmusApp());
}

class MasmusApp extends StatelessWidget {
  const MasmusApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.tapete,
    home: StartScreen(
      table: (partner, rules) => TablePage(partner: partner, rules: rules),
    ),
  );
}
