import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'l10n/app_localizations.dart';
import 'services/match_store.dart';
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
  final store = await MatchStore.open(await getApplicationSupportDirectory());
  runApp(MasmusApp(store: store));
}

class MasmusApp extends StatelessWidget {
  const MasmusApp({required this.store, super.key});

  final MatchStore store;

  @override
  Widget build(BuildContext context) => MaterialApp(
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.tapete,
    home: StartScreen(
      store: store,
      table: (partner, rules) =>
          TablePage(partner: partner, rules: rules, store: store),
      resume: (saved) => TablePage.resume(saved, store: store),
    ),
  );
}
