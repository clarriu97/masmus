// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Masmus';

  @override
  String cardName(String number, String suit) {
    String _temp0 = intl.Intl.selectLogic(number, {
      '1': 'As',
      '2': 'Dos',
      '3': 'Tres',
      '4': 'Cuatro',
      '5': 'Cinco',
      '6': 'Seis',
      '7': 'Siete',
      '10': 'Sota',
      '11': 'Caballo',
      '12': 'Rey',
      'other': '$number',
    });
    String _temp1 = intl.Intl.selectLogic(suit, {
      'oros': 'oros',
      'copas': 'copas',
      'espadas': 'espadas',
      'bastos': 'bastos',
      'other': '$suit',
    });
    return '$_temp0 de $_temp1';
  }

  @override
  String get cardFaceDown => 'Carta boca abajo';
}
