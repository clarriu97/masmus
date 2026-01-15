import '../logic/hand_evaluator.dart';
import '../models/card.dart';
import '../models/deck.dart';
import '../models/game_config.dart';
import '../models/player.dart';

enum GamePhase { mus, discard, grande, chica, pares, juego, punto, finished }

class MusGame {
  MusGame({required this.players, this.config = const GameConfig()})
    : deck = Deck(),
      assert(players.length == 4) {
    _startNewHand();
  }

  final List<Player> players; // 4 players always
  final GameConfig config;
  final Deck deck;

  // Game State
  int manoIndex = 0; // Who is 'mano' (dealer is mano-1)
  int currentTurn = 0; // Index of player whose turn it is

  GamePhase currentPhase = GamePhase.mus;

  // Scoring
  Map<int, int> teamScores = {0: 0, 1: 0}; // Team 0 (P0 & P2), Team 1 (P1 & P3)

  // Transient state (per hand)
  List<bool> wantsMus = [false, false, false, false];
  List<HandEvaluationResult?> evaluations = [null, null, null, null];

  // --- Info ---
  bool isTeamOne(int playerIndex) => playerIndex % 2 == 0;

  void _startNewHand() {
    deck.reset();
    for (final p in players) {
      p.clearHand();
      p.receiveCards(_dealCards(4));
    }

    currentTurn = manoIndex;
    currentPhase = GamePhase.mus;
    wantsMus = [false, false, false, false]; // Reset mus requests

    // Auto-evaluate hands for caching purposes
    _evaluateHands();
  }

  List<MusCard> _dealCards(int count) {
    final List<MusCard> cards = [];
    for (int i = 0; i < count; i++) {
      var card = deck.draw();
      if (card == null) {
        // Shuffle discard pile into deck? In mus usually we don't reshuffle discard immediately
        // unless deck runs out. For simplicity, if deck runs out, we might need to handle it.
        // Assuming infinite deck or reshuffle logic for now.
        deck.reset(); // Crude shuffle for now
        deck.shuffle();
        card = deck.draw()!;
      }
      cards.add(card);
    }
    return cards;
  }

  void _evaluateHands() {
    for (int i = 0; i < 4; i++) {
      evaluations[i] = HandEvaluator.evaluate(players[i].hand, config);
    }
  }

  // --- Actions ---

  /// Jugador dice "Mus"
  bool playerSaysMus(int playerIndex) {
    if (currentPhase != GamePhase.mus) {
      return false;
    }
    if (currentTurn != playerIndex) {
      return false;
    }

    wantsMus[playerIndex] = true;

    // Si es el "postre" (manoIndex - 1 o equivalente) y dice mus, todos han dicho mus
    if (_isPostre(playerIndex)) {
      // Todos mus -> Fase de descarte
      currentPhase = GamePhase.discard;
      currentTurn = manoIndex; // Empieza descartando la mano
    } else {
      _advanceTurn();
    }
    return true;
  }

  /// Jugador dice "No hay Mus" (Corta)
  bool playerCutsMus(int playerIndex) {
    if (currentPhase != GamePhase.mus) {
      return false;
    }
    if (currentTurn != playerIndex) {
      return false;
    }

    // Corta mus -> Empieza el juego
    _startPhases();
    return true;
  }

  /// Jugador descarta cartas
  /// Retorna las nuevas cartas recibidas
  List<MusCard>? playerDiscards(int playerIndex, List<MusCard> cardsToDiscard) {
    if (currentPhase != GamePhase.discard) {
      return null;
    }
    if (currentTurn != playerIndex) {
      return null;
    }

    final player = players[playerIndex];

    // Validar que tiene esas cartas (simplificado, asume que UI envía refs correctas)
    player.discard(cardsToDiscard);

    // Dar nuevas cartas
    final newCards = _dealCards(cardsToDiscard.length);
    player.receiveCards(newCards);

    // Re-evaluar mano
    evaluations[playerIndex] = HandEvaluator.evaluate(player.hand, config);

    // Avanzar turno de descarte
    if (_isPostre(playerIndex)) {
      // Termina ronda de descarte -> Volver a preguntar Mus
      currentPhase = GamePhase.mus;
      currentTurn = manoIndex;
      wantsMus = [false, false, false, false];
    } else {
      _advanceTurn();
    }

    return newCards;
  }

  void _startPhases() {
    currentPhase = GamePhase.grande;
    currentTurn = manoIndex;
    // Aquí inicializaríamos apuestas para Grande
  }

  void _advanceTurn() {
    currentTurn = (currentTurn + 1) % 4;
  }

  bool _isPostre(int playerIndex) {
    // El postre es el anterior a la mano
    return playerIndex == (manoIndex + 3) % 4;
  }
}
