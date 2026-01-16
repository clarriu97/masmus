import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../core/game/logic/mus_game.dart';
import '../core/game/models/card.dart';
import '../core/game/models/player.dart';
import '../core/utils/audio_generator.dart';
import '../widgets/game_controls.dart';
import '../widgets/mus_table.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late MusGame _game;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // Create 4 dummy players
    final players = List.generate(
      4,
      (index) => Player(id: 'p$index', name: 'Player $index'),
    );

    _game = MusGame(players: players);

    setState(() {
      _isLoading = false;
    });

    // Initial vibration to signal game start
    _vibrateShort();
  }

  Future<void> _vibrateShort() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      await Vibration.vibrate(duration: 50);
    }
  }

  final Set<MusCard> _selectedCards = {};

  Future<void> _handleCardTap(int playerIndex, MusCard card) async {
    if (playerIndex != 0) {
      return;
    }
    if (_game.currentPhase == GamePhase.discard) {
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

  void _handleMus() {
    setState(() {
      final bool success = _game.playerSaysMus(0);
      _selectedCards.clear();
      if (success) {
        _advanceAiTurns();
      }
    });
  }

  void _handleCut() {
    setState(() {
      final bool success = _game.playerCutsMus(0);
      _selectedCards.clear();
      if (success) {
        _advanceAiTurns();
      }
    });
  }

  Future<void> _handleDiscard() async {
    if (_selectedCards.isEmpty) {
      return;
    }

    // Play sound
    final player = AudioPlayer();
    final path = await AudioGenerator.generateDealSound();
    await player.play(DeviceFileSource(path)); // Swoosh sound

    setState(() {
      _game.playerDiscards(0, _selectedCards.toList());
      _selectedCards.clear();
      _advanceAiTurns(); // Verify if turn advanced or if we are waiting
    });
  }

  void _advanceAiTurns() {
    // Simple mock AI advancement
    // In a real game, this would be async with delays
    // Here we just refresh state to show changes if any
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Determine button states based on game state
    final bool isMyTurn = _game.currentTurn == 0;
    final bool canMus = isMyTurn && _game.currentPhase == GamePhase.mus;

    return Scaffold(
      body: Stack(
        children: [
          MusTable(
            players: _game.players,
            onCardTap: _handleCardTap,
            selectedCards: _selectedCards,
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_game.currentPhase == GamePhase.discard && isMyTurn)
                  ElevatedButton(
                    onPressed: _selectedCards.isNotEmpty
                        ? _handleDiscard
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text('DESCARTAR (${_selectedCards.length})'),
                  ),
                const SizedBox(height: 10),
                GameControls(
                  onMus: _handleMus,
                  onCut: _handleCut,
                  canMus: canMus,
                  canCut: canMus,
                ),
              ],
            ),
          ),
          // HUD / Status Info
          Positioned(
            top: 40,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Phase: ${_game.currentPhase.name.toUpperCase()}\nTurn: P${_game.currentTurn}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
