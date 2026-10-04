import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'controllers/settings_controller.dart';
import 'l10n/app_localizations.dart';
import 'services/json_file.dart';
import 'services/match_store.dart';
import 'services/sounds.dart';
import 'ui/start/start_screen.dart';
import 'ui/table/table_page.dart';
import 'ui/theme/app_theme.dart';
import 'ui/theme/font_licenses.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicenses();
  await SystemChrome.setPreferredOrientations([
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
  final directory = await getApplicationSupportDirectory();
  final store = await MatchStore.open(
    JsonFile.at(File('${directory.path}/match.json')),
  );
  final settings = await SettingsController.open(
    JsonFile.at(File('${directory.path}/settings.json')),
  );
  runApp(MasmusApp(store: store, settings: settings, sounds: Sounds()));
}

class MasmusApp extends StatelessWidget {
  const MasmusApp({
    required this.store,
    required this.settings,
    required this.sounds,
    super.key,
  });

  final MatchStore store;
  final SettingsController settings;
  final Sounds sounds;

  @override
  Widget build(BuildContext context) => MaterialApp(
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.tapete,
    home: StartScreen(
      store: store,
      settings: settings,
      table: (partner, rules, rivals) => TablePage(
        partner: partner,
        rules: rules,
        rivals: rivals,
        pace: settings.settings.pace,
        handHelp: settings.settings.handHelp,
        haptics: settings.settings.haptics,
        sounds: settings.settings.sound ? sounds : null,
        store: store,
      ),
      resume: (saved) => TablePage.resume(
        saved,
        pace: settings.settings.pace,
        handHelp: settings.settings.handHelp,
        haptics: settings.settings.haptics,
        sounds: settings.settings.sound ? sounds : null,
        store: store,
      ),
    ),
  );
}
