import 'dart:async';
import 'dart:math' as math;

import '../logic/hand_evaluator.dart';
import '../models/card.dart';
import '../models/deck.dart';
import '../models/game_action.dart';
import '../models/game_config.dart';
import '../models/player.dart';

enum GamePhase {
  musDeclaration,
  discard,
  grande,
  chica,
  paresDeclaration,
  pares,
  juegoDeclaration,
  juego,
  punto,
  scoring,
  finished,
}

enum BetType { none, envido, ordago }

class MusGame {
  MusGame({
    required this.players,
    this.config = const GameConfig(),
    this.initialMano,
  }) : deck = Deck(),
       assert(players.length == 4) {
    manoIndex = initialMano ?? math.Random().nextInt(4);
    _startNewHand();
  }

  final List<Player> players;
  final GameConfig config;
  final int? initialMano;
  final Deck deck;

  // Game State
  int manoIndex = 0; // Who is 'mano'
  int currentTurn = 0; // Current speaking player
  GamePhase currentPhase = GamePhase.musDeclaration;

  // Betting State
  int currentBet = 0; // Points at stake in current exchange
  BetType currentBetType = BetType.none;
  int? speakerIndex; // Who made the last bet/raise
  bool phaseFrozen =
      false; // If a phase is "closed" (all passed or bet accepted)
  int? firstResponderIndex; // First player asked to respond in current cycle

  // Pending points to be resolved at end of hand
  // grande, chica, pares, juego. If > 0, it means "Quiero" was said.
  Map<GamePhase, int> pendingBets = {};
  Map<GamePhase, int> phaseWinners =
      {}; // Who won the phase (for visualization)
  Set<GamePhase> rejectedPhases = {}; // Phases closed with "No Quiero"

  // Scores
  Map<int, int> teamScores = {0: 0, 1: 0}; // Team 0 (0&2), Team 1 (1&3)

  // Mus State
  List<bool> wantsMus = [false, false, false, false];
  List<HandEvaluationResult?> evaluations = [null, null, null, null];

  // Player Action Tracking
  final List<GameAction> actionHistory = [];
  int? musCutterIndex; // Who cut the mus in the current hand

  // Action Tracking for UI
  String lastAction = '';
  int lastActionPlayerIndex = -1;

  // Declarations for UI (Persistent bubbles for Pares/Juego)
  Map<int, String> declarations = {};

  // Events for UI
  final _streamController = StreamController<void>.broadcast();
  Stream<void> get onChange => _streamController.stream;

  // Score Details for Summary [Phase, "Description/Points"]
  Map<GamePhase, String> scoreDetails = {};

  // Helpers
  bool isTeamOne(int playerIndex) => playerIndex % 2 == 0;
  int getTeam(int playerIndex) => playerIndex % 2;

  void _startNewHand() {
    deck.reset();
    deck.shuffle();
    for (final p in players) {
      p.clearHand();
      p.receiveCards(_dealCards(4));
    }

    currentTurn = manoIndex;
    currentPhase = GamePhase.musDeclaration;
    wantsMus = [false, false, false, false];

    currentBet = 0;
    currentBetType = BetType.none;
    speakerIndex = null;
    phaseFrozen = false;
    pendingBets.clear();
    phaseWinners.clear();
    rejectedPhases.clear();
    scoreDetails.clear();
    declarations.clear();
    firstResponderIndex = null;
    musCutterIndex = null;

    evaluateHands();
    _notify();
  }

  List<MusCard> _dealCards(int count) {
    final List<MusCard> cards = [];
    for (int i = 0; i < count; i++) {
      var card = deck.draw();
      if (card == null) {
        deck.reset();
        deck.shuffle();
        card = deck.draw()!;
      }
      cards.add(card);
    }
    return cards;
  }

  void evaluateHands() {
    for (int i = 0; i < 4; i++) {
      evaluations[i] = HandEvaluator.evaluate(players[i].hand, config);
    }
  }

  // --- Actions ---

  bool playerSaysMus(int playerIndex) {
    if (currentPhase != GamePhase.musDeclaration ||
        currentTurn != playerIndex) {
      return false;
    }

    wantsMus[playerIndex] = true;
    declarations[playerIndex] = 'MUS';
    actionHistory.add(
      GameAction(
        playerIndex: playerIndex,
        phase: GamePhase.musDeclaration,
        type: ActionType.mus,
      ),
    );

    if (_isPostre(playerIndex)) {
      // All said Mus?
      if (wantsMus.every((w) => w)) {
        currentPhase = GamePhase.discard;
        currentTurn = manoIndex;
        declarations.clear();
      } else {
        // This shouldn't happen if someone cut it, but for safety:
        _startPhases();
      }
    } else {
      currentTurn = (currentTurn + 1) % 4;
    }
    _notify();
    return true;
  }

  bool playerCutsMus(int playerIndex) {
    if (currentPhase != GamePhase.musDeclaration ||
        currentTurn != playerIndex) {
      return false;
    }

    declarations.clear();
    declarations[playerIndex] = 'NO HAY MUS';
    lastAction = 'NO HAY MUS';
    lastActionPlayerIndex = playerIndex;
    musCutterIndex = playerIndex;
    actionHistory.add(
      GameAction(
        playerIndex: playerIndex,
        phase: GamePhase.musDeclaration,
        type: ActionType.noHayMus,
      ),
    );

    // Cut Mus -> Start Phases
    _startPhases();
    _notify();
    return true;
  }

  List<MusCard>? playerDiscards(int playerIndex, List<MusCard> cardsToDiscard) {
    if (currentPhase != GamePhase.discard || currentTurn != playerIndex) {
      return null;
    }

    final player = players[playerIndex];
    player.discard(cardsToDiscard);
    final newCards = _dealCards(cardsToDiscard.length);
    player.receiveCards(newCards);
    evaluations[playerIndex] = HandEvaluator.evaluate(player.hand, config);

    if (_isPostre(playerIndex)) {
      currentPhase = GamePhase.musDeclaration;
      currentTurn = manoIndex;
      wantsMus = [false, false, false, false];
      declarations.clear();
    } else {
      _advanceTurn();
    }
    _notify();
    return newCards;
  }

  // --- Betting Logic ---

  void _startPhases() {
    currentPhase = GamePhase.grande;
    _initPhase();
  }

  void _initPhase() {
    currentTurn = manoIndex;
    currentBet = 0;
    currentBetType = BetType.none;
    speakerIndex = null;
    phaseFrozen = false;

    if (currentPhase == GamePhase.pares) {
      if (!_anyPlayerHasPares() || _onlyOneTeamHasPares()) {
        _nextPhase();
        return;
      }
    }
    if (currentPhase == GamePhase.juego) {
      if (!_anyPlayerHasJuego()) {
        currentPhase = GamePhase.punto;
        _initPhase();
        return;
      }
      if (_onlyOneTeamHasJuego()) {
        _nextPhase();
        return;
      }
    }

    _ensureValidTurn();
  }

  bool _onlyOneTeamHasPares() {
    final bool team0 =
        (evaluations[0]?.paresType != ParesType.none) ||
        (evaluations[2]?.paresType != ParesType.none);
    final bool team1 =
        (evaluations[1]?.paresType != ParesType.none) ||
        (evaluations[3]?.paresType != ParesType.none);
    return team0 != team1;
  }

  bool _onlyOneTeamHasJuego() {
    final bool team0 =
        (evaluations[0]?.hasJuego ?? false) ||
        (evaluations[2]?.hasJuego ?? false);
    final bool team1 =
        (evaluations[1]?.hasJuego ?? false) ||
        (evaluations[3]?.hasJuego ?? false);
    return team0 != team1;
  }

  bool _anyPlayerHasPares() {
    return evaluations.any((e) => e != null && e.paresType != ParesType.none);
  }

  bool _anyPlayerHasJuego() {
    return evaluations.any((e) => e != null && e.hasJuego);
  }

  void playerAction(int playerIndex, String action, {int amount = 0}) {
    if (currentTurn != playerIndex) {
      return;
    }

    lastAction = action;
    lastActionPlayerIndex = playerIndex;

    if (action == 'PASO' || action == 'NO QUIERO') {
      if (currentBet > 0) {
        if (currentTurn == firstResponderIndex) {
          _advanceToPartner();
        } else {
          actionHistory.add(
            GameAction(
              playerIndex: playerIndex,
              phase: currentPhase,
              type: ActionType.noQuiero,
              amount: currentBet,
            ),
          );
          _rejectBet();
        }
      } else {
        declarations[playerIndex] = 'PASO';
        actionHistory.add(
          GameAction(
            playerIndex: playerIndex,
            phase: currentPhase,
            type: ActionType.paso,
          ),
        );
        if (_isPostreForPhase(playerIndex)) {
          _closePhase(null);
        } else {
          _advanceTurn();
        }
      }
    } else if (action == 'ENVIDO' || action == 'ORDAGO' || amount > 0) {
      declarations.clear(); // Clear "PASO" messages when someone bets
      int raise = amount > 0 ? amount : 2;
      if (action == 'ORDAGO') {
        raise = 40;
      }

      currentBet = (currentBet == 0) ? raise : currentBet + raise;
      currentBetType = action == 'ORDAGO' ? BetType.ordago : BetType.envido;
      speakerIndex = playerIndex;
      firstResponderIndex = null; // Reset for new response cycle
      actionHistory.add(
        GameAction(
          playerIndex: playerIndex,
          phase: currentPhase,
          type: action == 'ORDAGO' ? ActionType.ordago : ActionType.envido,
          amount: raise,
        ),
      );
      _jumpToRival();
    } else if (action == 'QUIERO') {
      actionHistory.add(
        GameAction(
          playerIndex: playerIndex,
          phase: currentPhase,
          type: ActionType.quiero,
          amount: currentBet,
        ),
      );
      _closePhase(currentBet);
    }

    _notify();
  }

  void _advanceTurn() {
    int next = (currentTurn + 1) % 4;
    int loops = 0;
    while (!_canPlayPhase(next) && loops < 4) {
      next = (next + 1) % 4;
      loops++;
    }

    if (loops == 4) {
      _nextPhase();
      return;
    }
    currentTurn = next;
  }

  void _jumpToRival() {
    // Jump to rival team, closest to mano
    final int rivalTeam = 1 - getTeam(currentTurn);
    // Closest to mano in rival team:
    // If mano is 0: rival team is 1&3. Closest is 1.
    // If mano is 1: rival team is 0&2. Closest is 2. (Wait, mano=1, so 2 is next)
    // Actually, closest to mano means smallest (pos - mano + 4) % 4
    final int pA = rivalTeam == 0 ? 0 : 1;
    final int pB = rivalTeam == 0 ? 2 : 3;

    final int distA = (pA - manoIndex + 4) % 4;
    final int distB = (pB - manoIndex + 4) % 4;

    int next = distA < distB ? pA : pB;

    // Check if they can play
    if (!_canPlayPhase(next)) {
      // Try the other partner
      next = next == pA ? pB : pA;
      if (!_canPlayPhase(next)) {
        // Nobody in rival team has it? Should not happen if validations are correct
        _closePhase(currentBet);
        return;
      }
    }
    currentTurn = next;
    firstResponderIndex = next;
  }

  void _advanceToPartner() {
    final int partner = (currentTurn + 2) % 4;
    if (_canPlayPhase(partner)) {
      currentTurn = partner;
    } else {
      // Partner can't play, so we must decide or it's implicitly NO QUIERO?
      // Actually, if we are responding to a bet and we "Pass", and partner can't play,
      // then we must have decided. But let's assume UI only shows PASO if partner can play.
      _rejectBet();
    }
  }

  bool _canPlayPhase(int idx) {
    if (currentPhase == GamePhase.pares) {
      return evaluations[idx]?.paresType != ParesType.none;
    }
    if (currentPhase == GamePhase.juego) {
      return evaluations[idx]?.hasJuego ?? false;
    }
    return true;
  }

  void _ensureValidTurn() {
    if (!_canPlayPhase(currentTurn)) {
      _advanceTurn();
    }
  }

  void _closePhase(int? agreedBet) {
    if (agreedBet != null) {
      if (currentBetType == BetType.ordago) {
        _resolveOrdago();
        return;
      }
      pendingBets[currentPhase] = agreedBet;
    }
    // Clear declarations if we were in Pares/Juego
    if (currentPhase == GamePhase.pares || currentPhase == GamePhase.juego) {
      declarations.clear();
    }
    _nextPhase();
  }

  void _rejectBet() {
    final int winnerTeam = getTeam(speakerIndex!);
    const int points = 1;
    teamScores[winnerTeam] = (teamScores[winnerTeam] ?? 0) + points;

    rejectedPhases.add(currentPhase);

    // Clear declarations
    if (currentPhase == GamePhase.pares || currentPhase == GamePhase.juego) {
      declarations.clear();
    }
    _nextPhase();
  }

  void _nextPhase() {
    declarations.clear();
    if (currentPhase == GamePhase.grande) {
      currentPhase = GamePhase.chica;
    } else if (currentPhase == GamePhase.chica) {
      // Check if anyone has Pares
      if (_anyPlayerHasPares()) {
        currentPhase = GamePhase.paresDeclaration;
        currentTurn = manoIndex;
        // Don't init phase yet, declaration is special
        _notify();
        return;
      } else {
        // No one has pares, skip to Juego check
        _checkJuegoPhase();
        return;
      }
    } else if (currentPhase == GamePhase.paresDeclaration) {
      // Advance declaration or move to betting
      // This is controlled by performDeclarationStep usually
      // If we fall through here, it means we are done declaring
      currentPhase = GamePhase.pares;
    } else if (currentPhase == GamePhase.pares) {
      _checkJuegoPhase();
      return;
    } else if (currentPhase == GamePhase.juegoDeclaration) {
      currentPhase = GamePhase.juego;
    } else if (currentPhase == GamePhase.juego ||
        currentPhase == GamePhase.punto) {
      _calculateScores();
      return;
    }

    _initPhase();
  }

  void _checkJuegoPhase() {
    if (_anyPlayerHasJuego()) {
      currentPhase = GamePhase.juegoDeclaration;
      currentTurn = manoIndex;
      _notify();
    } else {
      currentPhase = GamePhase.punto;
      _initPhase();
    }
  }

  // Called to advance one step in declaration round
  // Returns true if round finished
  bool performDeclarationStep() {
    final idx = currentTurn;
    final ev = evaluations[idx]!;

    if (currentPhase == GamePhase.paresDeclaration) {
      final hasPares = ev.paresType != ParesType.none;
      declarations[idx] = hasPares ? 'SÍ' : 'NO';
    } else if (currentPhase == GamePhase.juegoDeclaration) {
      final hasJuego = ev.hasJuego;
      declarations[idx] = hasJuego ? 'SÍ' : 'NO';
    }

    // Advance
    if (_isPostre(currentTurn)) {
      // End of declaration round
      _nextPhase(); // Move to actual betting phase
      return true;
    } else {
      currentTurn = (currentTurn + 1) % 4;
      _notify();
      return false;
    }
  }

  void _resolveOrdago() {
    // For simplicity, we declare the current speaker's team as winner if accepted (requires actual comparison!)
    // To Compare: we need to know who accepted against whom.
    // In Ordago, cards are shown immediately.
    // Winner is calculated based on CURRENT PHASE hierarchy.

    final int team0Best = _getBestPlayerInTeam(0, currentPhase);
    final int team1Best = _getBestPlayerInTeam(1, currentPhase);

    final int winner = _comparePlayers(team0Best, team1Best, currentPhase) > 0
        ? 0
        : 1; // Team 0 wins?

    // 40 points usually implies game over
    teamScores[winner] = 40;

    currentPhase = GamePhase.finished;
  }

  void _calculateScores() {
    // 1. Grande
    _resolvePhasePoints(GamePhase.grande);
    // 2. Chica
    _resolvePhasePoints(GamePhase.chica);
    // 3. Pares
    if (_anyPlayerHasPares()) {
      _resolvePhasePoints(GamePhase.pares);
    }
    // 4. Juego/Punto
    if (_anyPlayerHasJuego()) {
      _resolvePhasePoints(GamePhase.juego);
    } else {
      _resolvePhasePoints(GamePhase.punto);
    }

    currentPhase = GamePhase.scoring;

    // Delay auto-restart handled by UI or manual call
  }

  void _resolvePhasePoints(GamePhase phase) {
    if (rejectedPhases.contains(phase)) {
      scoreDetails[phase] = 'Rechazado (1 pt)';
      return;
    }

    if (!pendingBets.containsKey(phase) &&
        phase != GamePhase.punto &&
        phase != GamePhase.juego &&
        phase != GamePhase.pares) {
      // If "Passed" in Grande/Chica -> 1 point for winner in paso
      final int team0 = _getBestPlayerInTeam(0, phase);
      final int team1 = _getBestPlayerInTeam(1, phase);
      final int diff = _comparePlayers(team0, team1, phase);
      int winnerTeam;
      if (diff > 0) {
        winnerTeam = 0;
      } else if (diff < 0) {
        winnerTeam = 1;
      } else {
        winnerTeam = _resolveTieByPosition(team0, team1);
      }
      phaseWinners[phase] = winnerTeam;
      teamScores[winnerTeam] = (teamScores[winnerTeam] ?? 0) + 1;
    } else if (pendingBets.containsKey(phase)) {
      // Bet was accepted. Winner gets Bet points.
      final int team0 = _getBestPlayerInTeam(0, phase);
      final int team1 = _getBestPlayerInTeam(1, phase);
      final int diff = _comparePlayers(team0, team1, phase);
      int winnerTeam;
      if (diff > 0) {
        winnerTeam = 0;
      } else if (diff < 0) {
        winnerTeam = 1;
      } else {
        winnerTeam = _resolveTieByPosition(team0, team1);
      }
      phaseWinners[phase] = winnerTeam;
      teamScores[winnerTeam] =
          (teamScores[winnerTeam] ?? 0) + pendingBets[phase]!;

      // In Pares/Juego, winner also gets "Base Points" (e.g. Par=1) for their team
      if (phase == GamePhase.pares ||
          phase == GamePhase.juego ||
          phase == GamePhase.punto) {
        _addCombinationPoints(winnerTeam, phase);
      }
    } else {
      // Passed in Pares/Juego/Punto. Winner gets combination points only (no 'en paso' point)
      // Actually in Pares/Juego, if passed, everyone showing reveals, and score calculated.
      // "Si todos pasan... al final se miran"
      final int team0 = _getBestPlayerInTeam(0, phase);
      final int team1 = _getBestPlayerInTeam(1, phase);
      if (team0 == -1 && team1 == -1) {
        scoreDetails[phase] = 'Nadie tenía';
        return; // No one has pares/juego
      }

      final int diff = _comparePlayers(team0, team1, phase);
      int winnerTeam;
      if (diff > 0) {
        winnerTeam = 0;
      } else if (diff < 0) {
        winnerTeam = 1;
      } else {
        winnerTeam = _resolveTieByPosition(team0, team1);
      }
      phaseWinners[phase] = winnerTeam;
      final pts = _addCombinationPoints(winnerTeam, phase);
      scoreDetails[phase] = 'Ganador: Equipo ${winnerTeam + 1} ($pts pts)';
    }
  }

  int _resolveTieByPosition(int pA, int pB) {
    final int distA = (pA - manoIndex + 4) % 4;
    final int distB = (pB - manoIndex + 4) % 4;
    return distA < distB ? getTeam(pA) : getTeam(pB);
  }

  // Modified to return points for summary
  int _addCombinationPoints(int teamIndex, GamePhase phase) {
    int totalAdded = 0;
    final List<int> playersIdx = teamIndex == 0 ? [0, 2] : [1, 3];
    for (final int idx in playersIdx) {
      if (phase == GamePhase.pares &&
          evaluations[idx]?.paresType != ParesType.none) {
        int val = 1;
        if (evaluations[idx]!.paresType == ParesType.medias) {
          val = 2;
        }
        if (evaluations[idx]!.paresType == ParesType.duples) {
          val = 3;
        }
        teamScores[teamIndex] = (teamScores[teamIndex] ?? 0) + val;
        totalAdded += val;
      }
      if (phase == GamePhase.juego && evaluations[idx]!.hasJuego) {
        final int val = (evaluations[idx]!.pointSum == 31) ? 3 : 2;
        teamScores[teamIndex] = (teamScores[teamIndex] ?? 0) + val;
        totalAdded += val;
      }
      if (phase == GamePhase.punto) {
        if (phaseWinners[phase] == teamIndex) {
          teamScores[teamIndex] = (teamScores[teamIndex] ?? 0) + 1;
          totalAdded += 1;
        }
        return totalAdded;
      }
    }
    return totalAdded;
  }

  int _getBestPlayerInTeam(int team, GamePhase phase) {
    // Returns player index of best hand in team
    final int p1 = team == 0 ? 0 : 1;
    final int p2 = team == 0 ? 2 : 3;

    // Filter eligibility
    final bool p1Play = _canPlayPhase(p1);
    final bool p2Play = _canPlayPhase(p2);

    if (!p1Play && !p2Play) {
      return -1;
    }
    if (p1Play && !p2Play) {
      return p1;
    }
    if (!p1Play && p2Play) {
      return p2;
    }

    return _comparePlayers(p1, p2, phase) > 0 ? p1 : p2;
  }

  int _comparePlayers(int idxA, int idxB, GamePhase phase) {
    if (idxA < 0 ||
        idxA >= evaluations.length ||
        idxB < 0 ||
        idxB >= evaluations.length) {
      return 0;
    }
    if (evaluations[idxA] == null || evaluations[idxB] == null) {
      return 0;
    }
    final rankA = evaluations[idxA]!.sortedRanks;
    final rankB = evaluations[idxB]!.sortedRanks;

    if (phase == GamePhase.grande) {
      return HandEvaluator.compareGrande(rankA, rankB);
    }
    if (phase == GamePhase.chica) {
      return HandEvaluator.compareChica(rankA, rankB);
    }
    if (phase == GamePhase.pares) {
      return HandEvaluator.comparePares(evaluations[idxA]!, evaluations[idxB]!);
    }
    if (phase == GamePhase.juego) {
      return HandEvaluator.compareJuego(
        evaluations[idxA]!.pointSum,
        evaluations[idxB]!.pointSum,
        config,
      );
    }
    if (phase == GamePhase.punto) {
      return HandEvaluator.comparePunto(
        evaluations[idxA]!.pointSum,
        evaluations[idxB]!.pointSum,
      );
    }

    return 0;
  }

  void restartHand() => _finishHand();

  void _finishHand() {
    if (teamScores[0]! >= 40 || teamScores[1]! >= 40) {
      currentPhase = GamePhase.finished;
      _notify();
      return;
    }
    manoIndex = (manoIndex + 1) % 4;
    _startNewHand();
  }

  bool _isPostre(int playerIndex) => playerIndex == (manoIndex + 3) % 4;

  bool _isPostreForPhase(int idx) {
    return idx == (manoIndex + 3) % 4;
  }

  void _notify() {
    _streamController.add(null);
  }
}
