import 'dart:async';
import 'dart:math' as math; // Add import

import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../core/game/logic/ai_logic.dart';
import '../core/game/logic/mus_game.dart';
import '../core/game/models/ai_profile.dart';
import '../core/game/models/card.dart';
import '../core/game/models/game_config.dart';
import '../core/game/models/player.dart';
import '../widgets/game_controls.dart';
import '../widgets/mus_table.dart';
import '../widgets/round_summary.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    this.partnerProfile,
    this.config,
  });

  final AiProfile? partnerProfile;
  final GameConfig? config;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late MusGame _game;
  bool _isLoading = true;
  StreamSubscription? _gameSub;
  final Set<MusCard> _selectedCards = {};

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _gameSub?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    final human = Player(id: 'p0', name: 'Tú');

    final partnerProfile = widget.partnerProfile;
    final partner = Player(
      id: 'p2',
      name: partnerProfile?.name ?? 'Compañero',
      aiProfile:
          partnerProfile ??
          const AiProfile(name: 'Compañero', boldness: 0.5, bluffing: 0.1),
    );

    final rival1 = Player(
      id: 'p1',
      name: 'Rival 1',
      aiProfile: const AiProfile(name: 'Rival 1', boldness: 0.4, bluffing: 0.2),
    );
    final rival3 = Player(
      id: 'p3',
      name: 'Rival 2',
      aiProfile: const AiProfile(name: 'Rival 2', boldness: 0.7, bluffing: 0.5),
    );

    final players = [human, rival1, partner, rival3];

    _game = MusGame(
      players: players,
      config: widget.config ?? const GameConfig(),
    );
    _gameSub = _game.onChange.listen((event) {
      if (mounted) {
        setState(() {});
        _checkAiTurn();
      }
    });

    setState(() {
      _isLoading = false;
    });

    _vibrateShort();
    _checkAiTurn(); // Check initial turn
  }

  Future<void> _checkAiTurn() async {
    // If game finished, do nothing
    if (_game.currentPhase == GamePhase.finished) return;
    if (_game.currentPhase == GamePhase.scoring) {
      // Wait a bit then show summary or auto-restart
      return;
    }

    // Handle Declaration Rounds (Special Auto-Flow)
    if (_game.currentPhase == GamePhase.paresDeclaration ||
        _game.currentPhase == GamePhase.juegoDeclaration) {
      await _handleDeclarationRound();
      return;
    }

    final turnPlayer = _game.players[_game.currentTurn];
    if (turnPlayer.isAi) {
    // Random think time: 1s to 4s
    final random = math.Random();
    final int thinkTime = 1000 + random.nextInt(3000);
       
      await Future.delayed(Duration(milliseconds: thinkTime));
      if (mounted) _playAiTurn(turnPlayer);
    }
  }

  Future<void> _handleDeclarationRound() async {
    // 1 second delay between declarations as requested
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    
    // Perform step
    _game.performDeclarationStep();
    
    // Recursion handled by onChange listener -> _checkAiTurn logic
  }

  void _playAiTurn(Player player) {
    final idx = _game.players.indexOf(player);
    // Logic delegation
    final ev = _game.evaluations[idx]!;

    if (_game.currentPhase == GamePhase.mus) {
      final wantsMus = AiLogic.shouldAcceptMus(
        player,
        ev,
        isDealer: _game.manoIndex == idx,
      );
      if (wantsMus) {
        _game.playerSaysMus(idx);
      } else {
        _game.playerCutsMus(idx);
      }
    } else if (_game.currentPhase == GamePhase.discard) {
      final toDiscard = AiLogic.getCardsToDiscard(player, ev);
      _game.playerDiscards(idx, toDiscard);
    } else {
      // Betting Phases
      final decision = AiLogic.makeBettingDecision(
        player: player,
        ev: ev,
        phase: _game.currentPhase,
        currentBet: _game.currentBet,
        isPartnerWinning:
            false, // TODO: Check partner state
      );

      String action = 'PASO';
      if (decision.type == BettingType.envido) {
        action = 'ENVIDO';
      }
      if (decision.type == BettingType.ordago) {
        action = 'ORDAGO';
      }
      if (decision.type == BettingType.quiero) {
        action = 'QUIERO';
      }
      if (decision.type == BettingType.noQuiero) {
        action = 'NO QUIERO';
      }

      _game.playerAction(idx, action, amount: decision.amount);
    }
  }

  Future<void> _vibrateShort() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      await Vibration.vibrate(duration: 50);
    }
  }

  Future<void> _handleCardTap(int playerIndex, MusCard card) async {
    if (playerIndex != 0) return;

    if (_game.currentPhase == GamePhase.discard && _game.currentTurn == 0) {
      setState(() {
        if (_selectedCards.contains(card)) {
          _selectedCards.remove(card);
        } else {
          _selectedCards.add(card);
        }
      });
      await _vibrateShort();
    }
  }

  // User Actions
  void _onUserAction(String action) {
    if (_game.currentTurn != 0) return;

    if (action == 'DESCARTAR') {
      _game.playerDiscards(0, _selectedCards.toList());
      _selectedCards.clear();
      return;
    }

    if (action == 'MUS') {
      _game.playerSaysMus(0);
    } else if (action == 'NO HAY MUS') {
      _game.playerCutsMus(0);
    } else {
      _game.playerAction(0, action);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool isMyTurn = _game.currentTurn == 0;

    // Determine buttons logic
    bool canMus = false,
        canCut = false,
        canPass = false,
        canEnvido = false,
        canOrdago = false,
        canQuiero = false,
        canNoQuiero = false;

    if (isMyTurn) {
      if (_game.currentPhase == GamePhase.mus) {
        canMus = true;
        canCut = true;
      } else if (_game.currentPhase != GamePhase.discard &&
          _game.currentPhase != GamePhase.scoring) {
        // Check if we are responding to a bet
        if (_game.currentBet > 0) {
          // Must accept/reject/raise
          canQuiero = true;
          canNoQuiero = true;
          canEnvido = true; // Raise
          canOrdago = true;
        } else {
          // Open betting
          canPass = true;
          canEnvido = true;
          canOrdago = true;
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.black, // Fill notch area with black or theme color
      body: SafeArea(
        top: false, // Let MusTable handle its own background/stack
        child: Stack(
          children: [
            MusTable(
              players: _game.players,
              onCardTap: _handleCardTap,
              selectedCards: _selectedCards,
              manoIndex: _game.manoIndex,
              currentTurn: _game.currentTurn, // Pass current turn
              lastAction: _game.lastAction,
              lastActionPlayerIndex: _game.lastActionPlayerIndex,
              declarations: _game.declarations, // Pass declarations
            ),

            // Phase Indicator (Safe Area)
            Positioned(
              top: 0,
              left: 20,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Fase: ${_game.currentPhase.name.toUpperCase()}\nApuesta: ${_game.currentBet > 0 ? _game.currentBet : "N/A"}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Score Board (Safe Area Top Right)
            Positioned(
              top: 0,
              right: 20,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Nosotros: ${_game.teamScores[0]}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Ellos: ${_game.teamScores[1]}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Controls Area
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_game.currentPhase == GamePhase.discard && isMyTurn)
                    ElevatedButton(
                      onPressed:
                          _selectedCards.isNotEmpty
                              ? () => _onUserAction('DESCARTAR')
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: Text('DESCARTAR (${_selectedCards.length})'),
                    ),

                  if (_game.currentPhase != GamePhase.discard &&
                      _game.currentPhase != GamePhase.scoring &&
                      _game.currentPhase != GamePhase.paresDeclaration &&
                      _game.currentPhase != GamePhase.juegoDeclaration &&
                      isMyTurn)
                    GameControls(
                      onAction: _onUserAction,
                      canMus: canMus,
                      canCut: canCut,
                      canPass: canPass,
                      canEnvido: canEnvido,
                      canOrdago: canOrdago,
                      canQuiero: canQuiero,
                      canNoQuiero: canNoQuiero,
                    ),

                  if (!isMyTurn && _game.currentPhase != GamePhase.scoring)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Esperando a ${_game.players[_game.currentTurn].name}...',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Round Summary Overlay
            if (_game.currentPhase == GamePhase.scoring ||
                _game.currentPhase == GamePhase.finished)
              RoundSummary(
                scoreDetails: _game.scoreDetails,
                onContinue: () {
                  if (_game.currentPhase == GamePhase.finished) {
                    Navigator.of(context).pop(); // Back to menu
                  } else {
                    _game.restartHand();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
