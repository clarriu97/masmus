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

  @override
  String get startTitle => 'Más Mus';

  @override
  String get startSubtitle => 'Tú y tu compañero contra dos rivales';

  @override
  String get newMatch => 'Nueva partida';

  @override
  String get back => 'Volver';

  @override
  String get newMatchPartner => 'Tu compañero';

  @override
  String get newMatchKings => 'Reyes';

  @override
  String kingsCount(int count) {
    return '$count reyes';
  }

  @override
  String get newMatchTarget => 'Tantos';

  @override
  String targetPoints(int count) {
    return 'A $count';
  }

  @override
  String get newMatchStart => 'Empezar partida';

  @override
  String get personalityPrudente => 'El Prudente';

  @override
  String get personalityTemeraria => 'La Temeraria';

  @override
  String get personalityCalculador => 'El Calculador';

  @override
  String get personalityFarolero => 'El Farolero';

  @override
  String get personalityPrudenteStyle =>
      'Envida con buena mano; casi no farolea';

  @override
  String get personalityTemerariaStyle =>
      'Quiere casi todo; le gusta el órdago';

  @override
  String get personalityCalculadorStyle => 'Juega las probabilidades';

  @override
  String get personalityFaroleroStyle => 'Envida sin nada cuando puede';

  @override
  String get tableExit => 'Salir';

  @override
  String get teamUs => 'Nosotros';

  @override
  String get teamThem => 'Ellos';

  @override
  String tableTarget(int target) {
    return 'a $target';
  }

  @override
  String roleSeat(String role, String position) {
    String _temp0 = intl.Intl.selectLogic(role, {
      'partner': 'compañero',
      'other': 'rival',
    });
    String _temp1 = intl.Intl.selectLogic(position, {
      'mano': ' · mano',
      'postre': ' · postre',
      'other': '',
    });
    return '$_temp0$_temp1';
  }

  @override
  String stepName(String step) {
    String _temp0 = intl.Intl.selectLogic(step, {
      'mus': 'Mus',
      'grande': 'Grande',
      'chica': 'Chica',
      'pares': 'Pares',
      'juego': 'Juego',
      'punto': 'Punto',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get stepYourTurn => 'te toca';

  @override
  String get stepCorrido => 'corrido';

  @override
  String get stepCut => 'cortado';

  @override
  String get stepDiscards => 'descartes';

  @override
  String get stepEnPaso => 'en paso';

  @override
  String stepQuerido(int stake) {
    return 'querido $stake';
  }

  @override
  String stepNoQuerido(String team, int points) {
    String _temp0 = intl.Intl.selectLogic(team, {
      'us': 'Nosotros',
      'other': 'Ellos',
    });
    return '$_temp0 +$points';
  }

  @override
  String stepSinDisputa(String team) {
    String _temp0 = intl.Intl.selectLogic(team, {
      'us': 'Nosotros',
      'other': 'Ellos',
    });
    return 'de $_temp0';
  }

  @override
  String get stepNotPlayed => 'no se juega';

  @override
  String stepEnvite(int stake) {
    return 'envite $stake';
  }

  @override
  String get stepOrdago => 'órdago';

  @override
  String get stepOrdagoQuerido => 'órdago querido';

  @override
  String get saidMus => 'Mus';

  @override
  String get saidNoHayMus => 'No hay mus';

  @override
  String saidDiscarded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pide $count',
      one: 'Pide una',
    );
    return '$_temp0';
  }

  @override
  String saidDeclared(String lance, String has) {
    String _temp0 = intl.Intl.selectLogic(lance, {
      'pares': 'Pares',
      'other': 'Juego',
    });
    String _temp1 = intl.Intl.selectLogic(has, {'yes': 'sí', 'other': 'no'});
    return '$_temp0: $_temp1';
  }

  @override
  String get saidPaso => 'Paso';

  @override
  String saidEnvido(String raise, int amount) {
    String _temp0 = intl.Intl.selectLogic(raise, {
      'yes': '$amount más',
      'other': 'Envido $amount',
    });
    return '$_temp0';
  }

  @override
  String get saidQuiero => 'Quiero';

  @override
  String get saidNoQuiero => 'No quiero';

  @override
  String get saidOrdago => '¡Órdago!';

  @override
  String get tableStake => 'En la mesa';

  @override
  String get tableStakeNone => 'Nada';

  @override
  String get tableYourTurn => 'Te toca';

  @override
  String tableTurnOf(String name) {
    return 'Turno de $name';
  }

  @override
  String helpPares(String kind, String high, String low) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'par': 'Par de $high',
      'medias': 'Medias de $high',
      'duples': 'Duples de $high y $low',
      'other': 'Duples de $high',
    });
    return '$_temp0';
  }

  @override
  String helpJuego(int points) {
    return 'Juego $points';
  }

  @override
  String helpPunto(int points) {
    return 'Punto $points';
  }

  @override
  String rankPlural(String rank) {
    String _temp0 = intl.Intl.selectLogic(rank, {
      '12': 'reyes',
      '11': 'caballos',
      '10': 'sotas',
      '7': 'sietes',
      '6': 'seises',
      '5': 'cincos',
      '4': 'cuatros',
      '3': 'treses',
      '2': 'doses',
      'other': 'ases',
    });
    return '$_temp0';
  }

  @override
  String get tableMano => 'Mano';

  @override
  String tableStakeIs(String stake) {
    return 'En la mesa: $stake';
  }
}
