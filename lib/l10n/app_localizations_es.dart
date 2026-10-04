// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Más Mus';

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

  @override
  String get savedTitle => 'Partida en curso';

  @override
  String savedScore(int us, int them) {
    return 'Nosotros $us · Ellos $them';
  }

  @override
  String savedDetails(String kings, int target, int hand, String partner) {
    String _temp0 = intl.Intl.selectLogic(kings, {
      'eight': '8 reyes',
      'other': '4 reyes',
    });
    return '$_temp0 · a $target · mano $hand · con $partner';
  }

  @override
  String get savedContinue => 'Continuar';

  @override
  String get confirmNewTitle => '¿Empezar otra partida?';

  @override
  String get confirmNewBody => 'La partida en curso se pierde.';

  @override
  String get confirmNewCancel => 'Cancelar';

  @override
  String get confirmNewOk => 'Empezar otra';

  @override
  String get savedSetAside =>
      'No se pudo recuperar la partida guardada. La hemos apartado sin borrarla.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsRules => 'Reglas por defecto';

  @override
  String get settingsPace => 'Ritmo de los bots';

  @override
  String paceName(String pace) {
    String _temp0 = intl.Intl.selectLogic(pace, {
      'slow': 'Lento',
      'normal': 'Normal',
      'other': 'Rápido',
    });
    return '$_temp0';
  }

  @override
  String get settingsHelp => 'Ayuda con tu jugada';

  @override
  String get settingsHelpDetail =>
      'La mesa te dice qué llevas: pares, juego o punto.';

  @override
  String get settingsHaptics => 'Vibración';

  @override
  String get settingsHapticsDetail => 'El móvil vibra cuando te toca.';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String aboutVersion(String version, int build) {
    return 'Versión $version ($build)';
  }

  @override
  String get aboutTagline =>
      'Mus contra bots, sin conexión y sin cuentas: tus partidas no salen del móvil.';

  @override
  String get aboutWebsite => 'Web';

  @override
  String get aboutPrivacy => 'Privacidad';

  @override
  String get aboutTerms => 'Condiciones de uso';

  @override
  String get aboutContact => 'Contacto';

  @override
  String get aboutLicenses => 'Licencias';

  @override
  String aboutCouldNotOpen(String what) {
    return 'No se ha podido abrir $what';
  }

  @override
  String get settingsSound => 'Sonido';

  @override
  String get settingsSoundDetail =>
      'Barajar, repartir, envites y órdagos. Calla con el móvil en silencio.';

  @override
  String get howTitle => 'Cómo se juega';

  @override
  String get howBasicsTitle => 'Lo básico';

  @override
  String get howBasics =>
      'Juegas con tu compañero, sentado enfrente, contra dos rivales. Cada uno recibe cuatro cartas de una baraja española de 40. Gana la primera pareja que llega a 40 tantos, o a 30 si lo eliges.';

  @override
  String get howCardsTitle => 'Las cartas';

  @override
  String get howCards =>
      'Con 8 reyes, lo normal, los treses cuentan como reyes y los doses como ases. Para la grande, la chica y los pares, de mayor a menor: rey, caballo, sota, 7, 6, 5, 4 y as. Para el juego y el punto, rey, caballo y sota valen 10 y las demás, su número.';

  @override
  String get howTurnsTitle => 'Mano y postre';

  @override
  String get howTurns =>
      'Se habla por turnos, empezando por la mano; el último en hablar es el postre, que es quien reparte. En la mesa, la mano lleva la ficha «M» y el mazo queda entre el postre y la mano. En cada mano nueva, la mano pasa al siguiente. Si dos jugadas empatan, gana la de quien habla antes.';

  @override
  String get howMusTitle => 'Mus o no hay mus';

  @override
  String get howMus =>
      'Al empezar, cada uno dice «mus» si quiere cambiar cartas o «no hay mus» para jugar con las que tiene. En cuanto alguien corta, empiezan los lances. Si los cuatro piden mus, cada uno descarta de una a cuatro cartas y recibe otras tantas. En la primera mano de la partida hay mus corrido: mientras todos pidan mus, la mano pasa al siguiente, y quien corta pasa a ser mano.';

  @override
  String get howLancesTitle => 'Los cuatro lances';

  @override
  String get howGrande =>
      'Grande: gana la carta más alta y, si empatan, la siguiente. R-R-7-4 gana a R-C-C-C.';

  @override
  String get howChica =>
      'Chica: gana la carta más baja y, si empatan, la siguiente. 1-1-4-5 gana a 1-4-5-6.';

  @override
  String get howPares =>
      'Pares: par (dos iguales), medias (tres) o duples (dos parejas, o cuatro iguales). Gana el tipo más alto y, si es el mismo, las cartas más altas de la jugada. Solo juegan quienes tienen pares.';

  @override
  String get howJuego =>
      'Juego: tienes juego si sumas 31 o más. La mejor es la 31; luego 32, 40, 37, 36, 35, 34 y 33. Si nadie tiene juego se juega al punto: gana quien más se acerca a 30.';

  @override
  String get howBetsTitle => 'Envidar';

  @override
  String get howBets =>
      'En cada lance puedes pasar, envidar (2 tantos o más) o echar un órdago, que se juega la partida entera. Ante un envite, la otra pareja quiere, no quiere o sube; basta con que uno de los dos quiera. Si no quieren, quien envidó cobra en el acto 1 tanto, o lo último que se había aceptado. Lo querido se decide en el recuento. Un órdago querido se resuelve al momento, con las cartas boca arriba.';

  @override
  String get howCountTitle => 'El recuento';

  @override
  String get howCount =>
      'Al acabar la mano se enseñan todas las cartas y se cuenta lance a lance. La mejor grande y la mejor chica se llevan 1 tanto si nadie envidó, o lo querido. En pares, cada jugador de la pareja ganadora suma par 1, medias 2 o duples 3; en juego, 3 por la 31 y 2 por cualquier otro. La primera pareja que llega a los tantos gana, aunque queden lances por contar.';

  @override
  String get howFairTitle => 'Reparto limpio';

  @override
  String get howFair =>
      'Las cartas se barajan al azar en cada mano. Los bots juegan con lo mismo que tú: sus cartas y lo que se dice en la mesa, nunca las tuyas ni el mazo. Al final de cada mano puedes ver todas las cartas y todos los descartes.';

  @override
  String get glossaryTitle => 'Glosario';

  @override
  String get glossaryTerm0 => 'Mano';

  @override
  String get glossaryMeaning0 =>
      'Quien habla primero en una mano; gana los empates.';

  @override
  String get glossaryTerm1 => 'Postre';

  @override
  String get glossaryMeaning1 => 'Quien habla el último.';

  @override
  String get glossaryTerm2 => 'Lance';

  @override
  String get glossaryMeaning2 =>
      'Cada una de las partes de la mano: grande, chica, pares y juego o punto.';

  @override
  String get glossaryTerm3 => 'Envido';

  @override
  String get glossaryMeaning3 =>
      'Apostar tantos en un lance: «envido» son 2; «cinco más» sube la apuesta.';

  @override
  String get glossaryTerm4 => 'Órdago';

  @override
  String get glossaryMeaning4 => 'Apostar la partida entera en un lance.';

  @override
  String get glossaryTerm5 => 'Quiero / No quiero';

  @override
  String get glossaryMeaning5 => 'Aceptar o rechazar un envite.';

  @override
  String get glossaryTerm6 => 'En paso';

  @override
  String get glossaryMeaning6 =>
      'Un lance en el que nadie envida; se cuenta al final.';

  @override
  String get glossaryTerm7 => 'Sin disputa';

  @override
  String get glossaryMeaning7 =>
      'Un lance que solo puede jugar una pareja; se lo lleva en el recuento.';

  @override
  String get glossaryTerm8 => 'Par, medias, duples';

  @override
  String get glossaryMeaning8 =>
      'Dos cartas iguales; tres; dos parejas o cuatro iguales.';

  @override
  String get glossaryTerm9 => 'La 31';

  @override
  String get glossaryMeaning9 => 'El mejor juego: sumar exactamente 31.';

  @override
  String get glossaryTerm10 => 'Punto';

  @override
  String get glossaryMeaning10 =>
      'Lo que suman las cartas cuando nadie tiene juego.';

  @override
  String get glossaryTerm11 => 'Mus corrido';

  @override
  String get glossaryMeaning11 =>
      'En la primera mano, la mano pasa al siguiente mientras todos pidan mus.';

  @override
  String get glossaryTerm12 => 'Amarracos';

  @override
  String get glossaryMeaning12 =>
      'Las piedras con las que se llevan los tantos: cada amarraco son cinco.';

  @override
  String get seatThinking => 'pensando';

  @override
  String get centerMus => '¿Mus?';

  @override
  String centerDeclaring(String lance) {
    String _temp0 = intl.Intl.selectLogic(lance, {
      'pares': '¿Pares?',
      'other': '¿Juego?',
    });
    return '$_temp0';
  }

  @override
  String get centerHandOver => 'Fin de la mano';

  @override
  String get centerToCount => 'a contar';

  @override
  String get historyTitle => 'Lo que va de mano';

  @override
  String get historyEmpty => 'Todavía no ha hablado nadie.';

  @override
  String historyLine(String name, String said) {
    return '$name: $said';
  }

  @override
  String historyManoMoved(String name) {
    return '$name pasa a ser mano';
  }

  @override
  String get historyReshuffled => 'Se acaba el mazo: se barajan los descartes';

  @override
  String get centerDeals => 'Reparte';

  @override
  String get tableCorrido => 'Mus corrido: quien corte será mano';

  @override
  String get newMatchGames => 'Juegos';

  @override
  String gamesCount(int games) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: 'De $games',
      one: 'Uno',
    );
    return '$_temp0';
  }

  @override
  String tableGames(int us, int them) {
    return 'juegos $us–$them';
  }

  @override
  String endGameWon(String team) {
    String _temp0 = intl.Intl.selectLogic(team, {
      'us': 'Juego para vosotros',
      'other': 'Juego para ellos',
    });
    return '$_temp0';
  }

  @override
  String endGames(int us, int them, int games) {
    return 'Juegos: Nosotros $us · Ellos $them · al mejor de $games';
  }

  @override
  String get endNextGame => 'Siguiente juego';

  @override
  String get seatCut => 'cortó el mus';

  @override
  String get tableYouMano => 'Eres mano';

  @override
  String get tableYouCut => 'Cortaste el mus';

  @override
  String senaName(String sena) {
    String _temp0 = intl.Intl.selectLogic(sena, {
      'treintaYUna': 'Treinta y una',
      'duples': 'Duples',
      'dosReyes': 'Dos reyes',
      'mediasReyes': 'Medias de reyes',
      'dosAses': 'Dos ases',
      'mediasAses': 'Medias de ases',
      'medias': 'Medias',
      'treinta': 'Treinta',
      'other': 'Ciego',
    });
    return '$_temp0';
  }

  @override
  String senaGesture(String sena) {
    String _temp0 = intl.Intl.selectLogic(sena, {
      'treintaYUna': 'guiña un ojo, al ver las cartas',
      'duples': 'levanta las cejas',
      'dosReyes': 'se muerde el labio inferior',
      'mediasReyes':
          'lleva la comisura de los labios a un lado, al ver las cartas',
      'dosAses': 'saca la punta de la lengua',
      'mediasAses': 'saca la punta de la lengua hacia un lado',
      'medias':
          'lleva la comisura a un lado como las de reyes, pero solo con la grande ya cerrada',
      'treinta': 'guiña un ojo como la 31, pero solo cuando se juega al punto',
      'other': 'cierra los dos ojos',
    });
    return '$_temp0';
  }

  @override
  String tablePartnerSenas(String senas) {
    return 'Seña: $senas';
  }

  @override
  String tableYourSenas(String senas) {
    return 'Tu seña: $senas';
  }

  @override
  String get newMatchSenas => 'Señas';

  @override
  String get senasOn => 'Con señas';

  @override
  String get senasOff => 'Sin señas';

  @override
  String get howSenasTitle => 'Señas';

  @override
  String get howSenas =>
      'Los compañeros se dicen lo que llevan con señas, que los rivales no ven. Son siempre verdaderas y completas: tu compañero te hace las suyas y tú las tuyas, y la mesa las enseña. En la primera mano no hay señas hasta que se corta el mus. Dos señas comparten gesto y se distinguen por cuándo se hacen: la comisura a un lado al ver las cartas son medias de reyes, y con la grande ya cerrada, medias de otra carta; el guiño al ver las cartas es la 31, y al punto, treinta. Puedes jugar sin señas desde Nueva partida o Ajustes.';

  @override
  String howSenaLine(String name, String gesture) {
    return '$name: $gesture';
  }

  @override
  String get adviceAsk => 'Consultar al compañero';

  @override
  String adviceSays(String move) {
    return 'Yo: $move';
  }

  @override
  String get newMatchRivals => 'Rivales';

  @override
  String get rivalsRandom => 'Al azar';

  @override
  String get rivalsRandomDetail => 'Dos de los otros, distintos cada partida';

  @override
  String rivalsPair(String first, String second) {
    return '$first y $second';
  }

  @override
  String rivalsPairDetail(String first, String second) {
    return '$first · $second';
  }
}
