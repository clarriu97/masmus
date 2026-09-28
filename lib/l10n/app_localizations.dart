import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// The app's name, until the identity (#21) settles it.
  ///
  /// In es, this message translates to:
  /// **'Masmus'**
  String get appTitle;

  /// A card as a screen reader says it: «Rey de oros». number is 1–7, 10, 11 or 12; suit is oros, copas, espadas or bastos.
  ///
  /// In es, this message translates to:
  /// **'{number, select, 1{As} 2{Dos} 3{Tres} 4{Cuatro} 5{Cinco} 6{Seis} 7{Siete} 10{Sota} 11{Caballo} 12{Rey} other{{number}}} de {suit, select, oros{oros} copas{copas} espadas{espadas} bastos{bastos} other{{suit}}}'**
  String cardName(String number, String suit);

  /// A card whose face can't be seen, as a screen reader says it.
  ///
  /// In es, this message translates to:
  /// **'Carta boca abajo'**
  String get cardFaceDown;

  /// Title of the start screen: the name of the game.
  ///
  /// In es, this message translates to:
  /// **'Más Mus'**
  String get startTitle;

  /// What the game is, under the title of the start screen.
  ///
  /// In es, this message translates to:
  /// **'Tú y tu compañero contra dos rivales'**
  String get startSubtitle;

  /// Button of the start screen and title of the screen where a match is set up.
  ///
  /// In es, this message translates to:
  /// **'Nueva partida'**
  String get newMatch;

  /// Goes back to the previous screen.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get back;

  /// Heading over the bots to choose a partner from.
  ///
  /// In es, this message translates to:
  /// **'Tu compañero'**
  String get newMatchPartner;

  /// Rule: how many kings the deck plays with (8 or 4).
  ///
  /// In es, this message translates to:
  /// **'Reyes'**
  String get newMatchKings;

  /// An option of the kings rule: «8 reyes».
  ///
  /// In es, this message translates to:
  /// **'{count} reyes'**
  String kingsCount(int count);

  /// Rule: how many tantos win the match (40 or 30).
  ///
  /// In es, this message translates to:
  /// **'Tantos'**
  String get newMatchTarget;

  /// An option of the tantos rule: «A 40».
  ///
  /// In es, this message translates to:
  /// **'A {count}'**
  String targetPoints(int count);

  /// Starts the match set up on the screen.
  ///
  /// In es, this message translates to:
  /// **'Empezar partida'**
  String get newMatchStart;

  /// Name of a bot who plays it safe.
  ///
  /// In es, this message translates to:
  /// **'El Prudente'**
  String get personalityPrudente;

  /// Name of a bot who takes risks.
  ///
  /// In es, this message translates to:
  /// **'La Temeraria'**
  String get personalityTemeraria;

  /// Name of a bot who plays the odds.
  ///
  /// In es, this message translates to:
  /// **'El Calculador'**
  String get personalityCalculador;

  /// Name of a bot who bluffs a lot.
  ///
  /// In es, this message translates to:
  /// **'El Farolero'**
  String get personalityFarolero;

  /// How El Prudente plays, in one line.
  ///
  /// In es, this message translates to:
  /// **'Envida con buena mano; casi no farolea'**
  String get personalityPrudenteStyle;

  /// How La Temeraria plays, in one line.
  ///
  /// In es, this message translates to:
  /// **'Quiere casi todo; le gusta el órdago'**
  String get personalityTemerariaStyle;

  /// How El Calculador plays, in one line.
  ///
  /// In es, this message translates to:
  /// **'Juega las probabilidades'**
  String get personalityCalculadorStyle;

  /// How El Farolero plays, in one line.
  ///
  /// In es, this message translates to:
  /// **'Envida sin nada cuando puede'**
  String get personalityFaroleroStyle;

  /// Leaves the table.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get tableExit;

  /// Your pair, in the score.
  ///
  /// In es, this message translates to:
  /// **'Nosotros'**
  String get teamUs;

  /// The rival pair, in the score.
  ///
  /// In es, this message translates to:
  /// **'Ellos'**
  String get teamThem;

  /// How many tantos win the match, next to the score: «a 40».
  ///
  /// In es, this message translates to:
  /// **'a {target}'**
  String tableTarget(int target);

  /// Who a bot is to you, and whether it is mano or postre: «rival · postre».
  ///
  /// In es, this message translates to:
  /// **'{role, select, partner{compañero} other{rival}}{position, select, mano{ · mano} postre{ · postre} other{}}'**
  String roleSeat(String role, String position);

  /// A step of the hand in the row at the top of the table.
  ///
  /// In es, this message translates to:
  /// **'{step, select, mus{Mus} grande{Grande} chica{Chica} pares{Pares} juego{Juego} punto{Punto} other{}}'**
  String stepName(String step);

  /// Under the step being played, when it is your turn.
  ///
  /// In es, this message translates to:
  /// **'te toca'**
  String get stepYourTurn;

  /// Under the mus of the first hand: it goes round until someone cuts it.
  ///
  /// In es, this message translates to:
  /// **'corrido'**
  String get stepCorrido;

  /// Under the mus once someone said «no hay mus».
  ///
  /// In es, this message translates to:
  /// **'cortado'**
  String get stepCut;

  /// Under the mus while the players change cards.
  ///
  /// In es, this message translates to:
  /// **'descartes'**
  String get stepDiscards;

  /// Under a lance nobody bet on.
  ///
  /// In es, this message translates to:
  /// **'en paso'**
  String get stepEnPaso;

  /// Under a lance whose bet was accepted.
  ///
  /// In es, this message translates to:
  /// **'querido {stake}'**
  String stepQuerido(int stake);

  /// Under a lance whose bet was refused: who took the points, «Nosotros +1».
  ///
  /// In es, this message translates to:
  /// **'{team, select, us{Nosotros} other{Ellos}} +{points}'**
  String stepNoQuerido(String team, int points);

  /// Under a lance only one pair could play: it takes it at the count.
  ///
  /// In es, this message translates to:
  /// **'de {team, select, us{Nosotros} other{Ellos}}'**
  String stepSinDisputa(String team);

  /// Under pares when nobody had them.
  ///
  /// In es, this message translates to:
  /// **'no se juega'**
  String get stepNotPlayed;

  /// Under the lance being played while a bet waits for an answer.
  ///
  /// In es, this message translates to:
  /// **'envite {stake}'**
  String stepEnvite(int stake);

  /// Under the lance being played while an órdago waits for an answer.
  ///
  /// In es, this message translates to:
  /// **'órdago'**
  String get stepOrdago;

  /// Under the lance where an órdago was accepted.
  ///
  /// In es, this message translates to:
  /// **'órdago querido'**
  String get stepOrdagoQuerido;

  /// What a player says to ask for mus.
  ///
  /// In es, this message translates to:
  /// **'Mus'**
  String get saidMus;

  /// What a player says to cut the mus.
  ///
  /// In es, this message translates to:
  /// **'No hay mus'**
  String get saidNoHayMus;

  /// What a player asks for in the discards: how many cards.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Pide una} other{Pide {count}}}'**
  String saidDiscarded(int count);

  /// Whether a player has pares or juego, said at the start of those lances.
  ///
  /// In es, this message translates to:
  /// **'{lance, select, pares{Pares} other{Juego}}: {has, select, yes{sí} other{no}}'**
  String saidDeclared(String lance, String has);

  /// What a player says to pass.
  ///
  /// In es, this message translates to:
  /// **'Paso'**
  String get saidPaso;

  /// A bet, or a raise over the one on the table.
  ///
  /// In es, this message translates to:
  /// **'{raise, select, yes{{amount} más} other{Envido {amount}}}'**
  String saidEnvido(String raise, int amount);

  /// What a player says to accept a bet.
  ///
  /// In es, this message translates to:
  /// **'Quiero'**
  String get saidQuiero;

  /// What a player says to refuse a bet.
  ///
  /// In es, this message translates to:
  /// **'No quiero'**
  String get saidNoQuiero;

  /// What a player says to bet the whole match.
  ///
  /// In es, this message translates to:
  /// **'¡Órdago!'**
  String get saidOrdago;

  /// What is bet in the lance being played.
  ///
  /// In es, this message translates to:
  /// **'En la mesa'**
  String get tableStake;

  /// Nothing is bet in the lance being played, for screen readers.
  ///
  /// In es, this message translates to:
  /// **'Nada'**
  String get tableStakeNone;

  /// Your turn.
  ///
  /// In es, this message translates to:
  /// **'Te toca'**
  String get tableYourTurn;

  /// Whose turn it is.
  ///
  /// In es, this message translates to:
  /// **'Turno de {name}'**
  String tableTurnOf(String name);

  /// What your pares are.
  ///
  /// In es, this message translates to:
  /// **'{kind, select, par{Par de {high}} medias{Medias de {high}} duples{Duples de {high} y {low}} other{Duples de {high}}}'**
  String helpPares(String kind, String high, String low);

  /// What your juego is worth.
  ///
  /// In es, this message translates to:
  /// **'Juego {points}'**
  String helpJuego(int points);

  /// Your punto, when you have no juego.
  ///
  /// In es, this message translates to:
  /// **'Punto {points}'**
  String helpPunto(int points);

  /// Cards of a rank, in plural: «reyes».
  ///
  /// In es, this message translates to:
  /// **'{rank, select, 12{reyes} 11{caballos} 10{sotas} 7{sietes} 6{seises} 5{cincos} 4{cuatros} 3{treses} 2{doses} other{ases}}'**
  String rankPlural(String rank);

  /// Marks that you are mano, next to your seat.
  ///
  /// In es, this message translates to:
  /// **'Mano'**
  String get tableMano;

  /// What is bet in the lance being played, for screen readers: «En la mesa: 2».
  ///
  /// In es, this message translates to:
  /// **'En la mesa: {stake}'**
  String tableStakeIs(String stake);

  /// Button: ask for mus.
  ///
  /// In es, this message translates to:
  /// **'Mus'**
  String get actionMus;

  /// Button: cut the mus.
  ///
  /// In es, this message translates to:
  /// **'No hay mus'**
  String get actionNoHayMus;

  /// Button: pass.
  ///
  /// In es, this message translates to:
  /// **'Paso'**
  String get actionPaso;

  /// Button: bet the amount shown under it.
  ///
  /// In es, this message translates to:
  /// **'Envido'**
  String get actionEnvido;

  /// Button: bet the whole match.
  ///
  /// In es, this message translates to:
  /// **'Órdago'**
  String get actionOrdago;

  /// Under the órdago button: it has to be held down.
  ///
  /// In es, this message translates to:
  /// **'mantén'**
  String get actionHold;

  /// Shown when the órdago button is tapped instead of held.
  ///
  /// In es, this message translates to:
  /// **'Mantén pulsado para echar el órdago'**
  String get actionHoldHint;

  /// Button: accept the bet.
  ///
  /// In es, this message translates to:
  /// **'Quiero'**
  String get actionQuiero;

  /// Button: refuse the bet.
  ///
  /// In es, this message translates to:
  /// **'No quiero'**
  String get actionNoQuiero;

  /// Button: raise the bet by the amount shown under it.
  ///
  /// In es, this message translates to:
  /// **'Subir'**
  String get actionRaise;

  /// Opens a choice of any amount to bet.
  ///
  /// In es, this message translates to:
  /// **'Otra'**
  String get actionOtherAmount;

  /// Title of the choice of an amount to bet.
  ///
  /// In es, this message translates to:
  /// **'¿Cuánto?'**
  String get amountTitle;

  /// Lowers the amount to bet, for screen readers.
  ///
  /// In es, this message translates to:
  /// **'Menos'**
  String get amountLess;

  /// Raises the amount to bet, for screen readers.
  ///
  /// In es, this message translates to:
  /// **'Más'**
  String get amountMore;

  /// Confirms the amount to bet.
  ///
  /// In es, this message translates to:
  /// **'Envidar {amount}'**
  String amountConfirm(int amount);

  /// What the rival bet, above your answers: «El Prudente envida 2 a la grande».
  ///
  /// In es, this message translates to:
  /// **'{name} {ordago, select, yes{echa órdago} other{envida {stake}}} {lance, select, grande{a la grande} chica{a la chica} pares{a pares} juego{a juego} other{al punto}}'**
  String enviteBy(String name, String ordago, int stake, String lance);

  /// Under the «no quiero» button: what refusing gives, «Ellos +1».
  ///
  /// In es, this message translates to:
  /// **'{team, select, us{Nosotros} other{Ellos}} +{points}'**
  String enviteIfNot(String team, int points);

  /// A player's «no quiero» that leaves the answer to their partner.
  ///
  /// In es, this message translates to:
  /// **'{partner, select, you{Tú decides} other{Decide su compañero}}'**
  String saidPartnerDecides(String partner);

  /// Under the raise button: it asks how much.
  ///
  /// In es, this message translates to:
  /// **'cuánto'**
  String get actionRaiseAny;

  /// Button: throw away the cards marked, for new ones.
  ///
  /// In es, this message translates to:
  /// **'Descartar'**
  String get actionDiscard;

  /// Under the discard button: how many cards are marked.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{marca las que cambias} =1{una carta} other{{count} cartas}}'**
  String actionDiscardCount(int count);

  /// Above your cards while you choose which to throw away.
  ///
  /// In es, this message translates to:
  /// **'Toca las cartas que quieres cambiar'**
  String get discardHint;

  /// Under a bot's name: how many cards it asked for in the last discards.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{pidió una} other{pidió {count}}}'**
  String seatAsked(int count);

  /// Title of the count at the end of a hand.
  ///
  /// In es, this message translates to:
  /// **'Recuento'**
  String get countTitle;

  /// Your hand, in the count.
  ///
  /// In es, this message translates to:
  /// **'Tú'**
  String get countYou;

  /// Who takes a lance and with what: «El Farolero, con 31».
  ///
  /// In es, this message translates to:
  /// **'{name}, con {hand}'**
  String countWinner(String name, String hand);

  /// A lance taken because the other pair refused the bet.
  ///
  /// In es, this message translates to:
  /// **'{team, select, us{Nosotros} other{Ellos}}, por el no quiero'**
  String countByNoQuiero(String team);

  /// A lance nobody could play.
  ///
  /// In es, this message translates to:
  /// **'Nadie tenía {lance, select, pares{pares} other{juego}}'**
  String countNobody(String lance);

  /// A hand at the punto: «27 de punto».
  ///
  /// In es, this message translates to:
  /// **'{points} de punto'**
  String countPunto(int points);

  /// Why a lance counts: nobody bet.
  ///
  /// In es, this message translates to:
  /// **'en paso'**
  String get countEnPaso;

  /// Why a lance counts: the bet was accepted.
  ///
  /// In es, this message translates to:
  /// **'querido {stake}'**
  String countQuerido(int stake);

  /// A lance refused: its points were taken during the hand.
  ///
  /// In es, this message translates to:
  /// **'no quiero: {points, plural, =1{1 tanto} other{{points} tantos}} ya contado'**
  String countNoQuerido(int points);

  /// Why a lance counts: only one pair could play it.
  ///
  /// In es, this message translates to:
  /// **'sin disputa'**
  String get countSinDisputa;

  /// The lance where an accepted órdago decided the match.
  ///
  /// In es, this message translates to:
  /// **'órdago querido'**
  String get countOrdago;

  /// A lance after the match was already won.
  ///
  /// In es, this message translates to:
  /// **'no se cuenta: la partida ya estaba ganada'**
  String get countNotCounted;

  /// What one hand adds in pares or juego: «duples 3», «la 31 3».
  ///
  /// In es, this message translates to:
  /// **'{kind, select, par{par} medias{medias} duples{duples} juego31{la 31} other{juego}} {points}'**
  String countPart(String kind, int points);

  /// The tantos a lance adds at the count.
  ///
  /// In es, this message translates to:
  /// **'{team, select, us{Nosotros} other{Ellos}} +{points}'**
  String countPoints(String team, int points);

  /// A pair's score before and after the count.
  ///
  /// In es, this message translates to:
  /// **'{team, select, us{Nosotros} other{Ellos}} {before} → {after}'**
  String countScore(String team, int before, int after);

  /// Who won the match in this count.
  ///
  /// In es, this message translates to:
  /// **'{team, select, us{¡Ganáis la partida!} other{Ganan ellos la partida}}'**
  String countWon(String team);

  /// Deals the next hand.
  ///
  /// In es, this message translates to:
  /// **'Siguiente mano'**
  String get countNextHand;

  /// Opens every card discarded in the hand, to check the deal.
  ///
  /// In es, this message translates to:
  /// **'Ver el reparto'**
  String get countDeal;

  /// Title of the cards discarded in the hand.
  ///
  /// In es, this message translates to:
  /// **'El reparto'**
  String get dealTitle;

  /// The cards one player threw away.
  ///
  /// In es, this message translates to:
  /// **'Descartes de {name}'**
  String dealDiscards(String name);

  /// Every card thrown away in the hand.
  ///
  /// In es, this message translates to:
  /// **'Descartes'**
  String get dealAllDiscards;

  /// When nobody changed cards.
  ///
  /// In es, this message translates to:
  /// **'Nadie ha descartado: se cortó el mus de entrada.'**
  String get dealNoDiscards;

  /// That the 40 cards are all there.
  ///
  /// In es, this message translates to:
  /// **'{hands} en las manos + {discards} descartadas + {stock} en el mazo = 40'**
  String dealTotal(int hands, int discards, int stock);

  /// After the last count: goes to the end of the match.
  ///
  /// In es, this message translates to:
  /// **'Ver el final'**
  String get countToEnd;

  /// Title of the end of a match you won.
  ///
  /// In es, this message translates to:
  /// **'¡Ganáis la partida!'**
  String get endWon;

  /// Title of the end of a match the rivals won.
  ///
  /// In es, this message translates to:
  /// **'Ganan ellos'**
  String get endLost;

  /// How the match went: «14 manos · con un órdago».
  ///
  /// In es, this message translates to:
  /// **'{hands, plural, =1{Una mano} other{{hands} manos}} · {how, select, count{a los tantos} noQuiero{con un no quiero} other{con un órdago}}'**
  String endSummary(int hands, String how);

  /// Plays another match with the same partner, rivals and rules.
  ///
  /// In es, this message translates to:
  /// **'Revancha'**
  String get endRematch;

  /// Goes back to the start screen.
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio'**
  String get endHome;

  /// Heading of the match saved, on the start screen.
  ///
  /// In es, this message translates to:
  /// **'Partida en curso'**
  String get savedTitle;

  /// The saved match's score.
  ///
  /// In es, this message translates to:
  /// **'Nosotros {us} · Ellos {them}'**
  String savedScore(int us, int them);

  /// The saved match's rules, which hand it is at and your partner.
  ///
  /// In es, this message translates to:
  /// **'{kings, select, eight{8 reyes} other{4 reyes}} · a {target} · mano {hand} · con {partner}'**
  String savedDetails(String kings, int target, int hand, String partner);

  /// Resumes the saved match where it was left.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get savedContinue;

  /// Asks before a new match replaces the saved one.
  ///
  /// In es, this message translates to:
  /// **'¿Empezar otra partida?'**
  String get confirmNewTitle;

  /// What starting another match means.
  ///
  /// In es, this message translates to:
  /// **'La partida en curso se pierde.'**
  String get confirmNewBody;

  /// Keeps the saved match.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get confirmNewCancel;

  /// Starts the new match and drops the saved one.
  ///
  /// In es, this message translates to:
  /// **'Empezar otra'**
  String get confirmNewOk;

  /// When the saved match couldn't be read.
  ///
  /// In es, this message translates to:
  /// **'No se pudo recuperar la partida guardada. La hemos apartado sin borrarla.'**
  String get savedSetAside;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
