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

  @override
  String get actionMus => 'Mus';

  @override
  String get actionNoHayMus => 'No hay mus';

  @override
  String get actionPaso => 'Paso';

  @override
  String get actionEnvido => 'Envido';

  @override
  String get actionOrdago => 'Órdago';

  @override
  String get actionHold => 'mantén';

  @override
  String get actionHoldHint => 'Mantén pulsado para echar el órdago';

  @override
  String get actionQuiero => 'Quiero';

  @override
  String get actionNoQuiero => 'No quiero';

  @override
  String get actionRaise => 'Subir';

  @override
  String get actionOtherAmount => 'Otra';

  @override
  String get amountTitle => '¿Cuánto?';

  @override
  String get amountLess => 'Menos';

  @override
  String get amountMore => 'Más';

  @override
  String amountConfirm(int amount) {
    return 'Envidar $amount';
  }

  @override
  String enviteBy(String name, String ordago, int stake, String lance) {
    String _temp0 = intl.Intl.selectLogic(ordago, {
      'yes': 'echa órdago',
      'other': 'envida $stake',
    });
    String _temp1 = intl.Intl.selectLogic(lance, {
      'grande': 'a la grande',
      'chica': 'a la chica',
      'pares': 'a pares',
      'juego': 'a juego',
      'other': 'al punto',
    });
    return '$name $_temp0 $_temp1';
  }

  @override
  String enviteIfNot(String team, int points) {
    String _temp0 = intl.Intl.selectLogic(team, {
      'us': 'Nosotros',
      'other': 'Ellos',
    });
    return '$_temp0 +$points';
  }

  @override
  String saidPartnerDecides(String partner) {
    String _temp0 = intl.Intl.selectLogic(partner, {
      'you': 'Tú decides',
      'other': 'Decide su compañero',
    });
    return '$_temp0';
  }

  @override
  String get actionRaiseAny => 'cuánto';

  @override
  String get actionDiscard => 'Descartar';

  @override
  String actionDiscardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartas',
      one: 'una carta',
      zero: 'marca las que cambias',
    );
    return '$_temp0';
  }

  @override
  String get discardHint => 'Toca las cartas que quieres cambiar';

  @override
  String seatAsked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pidió $count',
      one: 'pidió una',
    );
    return '$_temp0';
  }

  @override
  String get countTitle => 'Recuento';

  @override
  String get countYou => 'Tú';

  @override
  String countWinner(String name, String hand) {
    return '$name, con $hand';
  }

  @override
  String countByNoQuiero(String team) {
    String _temp0 = intl.Intl.selectLogic(team, {
      'us': 'Nosotros',
      'other': 'Ellos',
    });
    return '$_temp0, por el no quiero';
  }

  @override
  String countNobody(String lance) {
    String _temp0 = intl.Intl.selectLogic(lance, {
      'pares': 'pares',
      'other': 'juego',
    });
    return 'Nadie tenía $_temp0';
  }

  @override
  String countPunto(int points) {
    return '$points de punto';
  }

  @override
  String get countEnPaso => 'en paso';

  @override
  String countQuerido(int stake) {
    return 'querido $stake';
  }

  @override
  String countNoQuerido(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points tantos',
      one: '1 tanto',
    );
    return 'no quiero: $_temp0 ya contado';
  }

  @override
  String get countSinDisputa => 'sin disputa';

  @override
  String get countOrdago => 'órdago querido';

  @override
  String get countNotCounted => 'no se cuenta: la partida ya estaba ganada';

  @override
  String countPart(String kind, int points) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'par': 'par',
      'medias': 'medias',
      'duples': 'duples',
      'juego31': 'la 31',
      'other': 'juego',
    });
    return '$_temp0 $points';
  }

  @override
  String countPoints(String team, int points) {
    String _temp0 = intl.Intl.selectLogic(team, {
      'us': 'Nosotros',
      'other': 'Ellos',
    });
    return '$_temp0 +$points';
  }

  @override
  String countScore(String team, int before, int after) {
    String _temp0 = intl.Intl.selectLogic(team, {
      'us': 'Nosotros',
      'other': 'Ellos',
    });
    return '$_temp0 $before → $after';
  }

  @override
  String countWon(String team) {
    String _temp0 = intl.Intl.selectLogic(team, {
      'us': '¡Ganáis la partida!',
      'other': 'Ganan ellos la partida',
    });
    return '$_temp0';
  }

  @override
  String get countNextHand => 'Siguiente mano';

  @override
  String get countDeal => 'Ver el reparto';

  @override
  String get dealTitle => 'El reparto';

  @override
  String dealDiscards(String name) {
    return 'Descartes de $name';
  }

  @override
  String get dealAllDiscards => 'Descartes';

  @override
  String get dealNoDiscards =>
      'Nadie ha descartado: se cortó el mus de entrada.';

  @override
  String dealTotal(int hands, int discards, int stock) {
    return '$hands en las manos + $discards descartadas + $stock en el mazo = 40';
  }

  @override
  String get countToEnd => 'Ver el final';

  @override
  String get endWon => '¡Ganáis la partida!';

  @override
  String get endLost => 'Ganan ellos';

  @override
  String endSummary(int hands, String how) {
    String _temp0 = intl.Intl.pluralLogic(
      hands,
      locale: localeName,
      other: '$hands manos',
      one: 'Una mano',
    );
    String _temp1 = intl.Intl.selectLogic(how, {
      'count': 'a los tantos',
      'noQuiero': 'con un no quiero',
      'other': 'con un órdago',
    });
    return '$_temp0 · $_temp1';
  }

  @override
  String get endRematch => 'Revancha';

  @override
  String get endHome => 'Volver al inicio';
}
