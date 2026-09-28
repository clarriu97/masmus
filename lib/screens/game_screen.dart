import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../bots/heuristic_bot.dart';
import '../bots/strategic_bot.dart';
import '../controllers/match_controller.dart';
import '../game/cards.dart';
import '../game/event.dart';
import '../game/hand_state.dart';
import '../game/hand_value.dart';
import '../game/match.dart';
import '../game/move.dart';
import '../game/rules.dart';
import '../services/match_store.dart';
import '../services/scheduler.dart';
import '../widgets/game_controls.dart';
import '../widgets/mus_table.dart';
import '../widgets/round_summary.dart';

/// The legacy table, now drawing the match controller: you in seat 0, your
/// partner in seat 2, the rivals in seats 1 and 3. Redesigned in M3.
class GameScreen extends StatefulWidget {
  const GameScreen({
    required this.partner,
    super.key,
    this.rules = const Rules(),
    this.seed,
    this.mano,
    this.scheduler,
    this.store,
  });

  final Personality partner;
  final Rules rules;

  /// Fixes the deal and the bots' choices, for tests.
  final int? seed;
  final int? mano;
  final Scheduler? scheduler;
  final MatchStore? store;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final MatchController _controller;
  late final List<String> _names;
  final Set<PlayingCard> _selectedCards = {};

  @override
  void initState() {
    super.initState();
    final seed = widget.seed ?? math.Random().nextInt(1 << 32);
    final rivals = Personality.all
        .where((personality) => personality != widget.partner)
        .take(2)
        .toList();
    _names = ['Tú', rivals[0].name, widget.partner.name, rivals[1].name];
    _controller = MatchController(
      match: MatchState.start(
        seed: seed,
        rules: widget.rules,
        mano: widget.mano,
      ),
      bots: {
        1: StrategicBot(rivals[0], math.Random(seed + 1)),
        2: StrategicBot(widget.partner, math.Random(seed + 2)),
        3: StrategicBot(rivals[1], math.Random(seed + 3)),
      },
      scheduler: widget.scheduler ?? Scheduler(),
      store: widget.store ?? MatchStore.inMemory(),
    );
    unawaited(_vibrateShort());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _vibrateShort() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      await Vibration.vibrate(duration: 50);
    }
  }

  Future<void> _handleCardTap(int playerIndex, PlayingCard card) async {
    if (playerIndex != 0 ||
        !_controller.humanMoves.contains(MoveKind.discard)) {
      return;
    }
    setState(() {
      if (!_selectedCards.remove(card)) {
        _selectedCards.add(card);
      }
    });
    await _vibrateShort();
  }

  void _onUserAction(String action, {int? amount}) {
    final move = switch (action) {
      'MUS' => const Mus(),
      'NO HAY MUS' => const NoHayMus(),
      'PASO' => const Paso(),
      'ENVIDO' => Envido(amount ?? minEnvido),
      'QUIERO' => const Quiero(),
      'NO QUIERO' => const NoQuiero(),
      'ORDAGO' => const Ordago(),
      _ => null,
    };
    if (move != null && _controller.match.isLegal(0, move)) {
      _controller.play(move);
    }
  }

  void _discard() {
    final move = Discard(_selectedCards.toList());
    if (_controller.match.isLegal(0, move)) {
      _controller.play(move);
      setState(_selectedCards.clear);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => _table(context),
    );
  }

  Widget _table(BuildContext context) {
    final match = _controller.match;
    final hand = match.hand;
    final moves = _controller.humanMoves;
    final isMyTurn = _controller.isHumanTurn;
    final score = match.scoreNow;
    final canDiscard = moves.contains(MoveKind.discard);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            MusTable(
              seats: [
                for (final seat in [0, 1, 2, 3])
                  TableSeat(name: _names[seat], cards: hand.hands[seat]),
              ],
              onCardTap: _handleCardTap,
              selectedCards: _selectedCards,
              manoIndex: hand.mano,
              currentTurn: hand.turn ?? -1,
              declarations: _bubbles(hand),
              musCutterIndex: hand.log
                  .whereType<NoHayMusSaid>()
                  .map((said) => said.seat)
                  .firstOrNull,
            ),

            Positioned(
              top: 0,
              left: 20,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
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
                        _phaseLabel(hand),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!isMyTurn && hand.turn != null && !match.isOver)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(204),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Esperando a ${_names[hand.turn!]}...',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

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
                        'Nosotros: ${score[0]}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Ellos: ${score[1]}',
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

            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canDiscard)
                    ElevatedButton(
                      onPressed: _selectedCards.isNotEmpty ? _discard : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: Text('DESCARTAR (${_selectedCards.length})'),
                    ),
                  if (isMyTurn && !canDiscard)
                    GameControls(
                      onAction: _onUserAction,
                      canMus: moves.contains(MoveKind.mus),
                      canCut: moves.contains(MoveKind.noHayMus),
                      canPass: moves.contains(MoveKind.paso),
                      canEnvido: moves.contains(MoveKind.envido),
                      canOrdago: moves.contains(MoveKind.ordago),
                      canQuiero: moves.contains(MoveKind.quiero),
                      canNoQuiero: moves.contains(MoveKind.noQuiero),
                    ),
                ],
              ),
            ),

            if (_controller.lastEvents.any((event) => event is NoHayMusSaid))
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 1.0 + (value * 0.5),
                      child: Opacity(
                        opacity: 1.0 - value,
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(230),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: const Text(
                            '¡NO HAY\nMUS!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            if (match.isCounted || match.isOver)
              RoundSummary(
                count: match.count,
                names: _names,
                hands: hand.hands,
                score: score,
                winner: match.winner,
                onContinue: () {
                  if (match.isOver) {
                    Navigator.of(context).pop();
                  } else {
                    _controller.nextHand();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  String _phaseLabel(HandState hand) => switch (hand.phase) {
    MusTurn() => 'Mus',
    DiscardTurn() => 'Descarte',
    LanceTurn(:final lance, :final envite) =>
      '${_lanceName(lance)}${envite == null ? '' : ' · en la mesa ${envite.ordago ? 'órdago' : envite.stake}'}',
    HandOver() => 'Recuento',
  };

  String _lanceName(Lance lance) => switch (lance) {
    Lance.grande => 'Grande',
    Lance.chica => 'Chica',
    Lance.pares => 'Pares',
    Lance.juego => 'Juego',
    Lance.punto => 'Punto',
  };

  /// What each seat said last in the current lance (or in the mus), from the
  /// table's log.
  Map<int, String> _bubbles(HandState hand) {
    final start = hand.log.lastIndexWhere((event) => event is LanceClosed) + 1;
    final bubbles = <int, String>{};
    for (final event in hand.log.skip(start)) {
      final said = switch (event) {
        MusSaid(:final seat) => (seat, 'MUS'),
        NoHayMusSaid(:final seat) => (seat, 'NO HAY MUS'),
        Discarded(:final seat, :final count) => (seat, 'PIDE $count'),
        Declared(:final seat, :final has) => (seat, has ? 'SÍ' : 'NO'),
        PasoSaid(:final seat) => (seat, 'PASO'),
        EnvidoSaid(:final seat, :final amount, :final stake) => (
          seat,
          amount == stake ? 'ENVIDO $amount' : '$amount MÁS',
        ),
        QuieroSaid(:final seat) => (seat, 'QUIERO'),
        NoQuieroSaid(:final seat) => (seat, 'NO QUIERO'),
        OrdagoSaid(:final seat) => (seat, '¡ÓRDAGO!'),
        _ => null,
      };
      if (said != null) {
        bubbles[said.$1] = said.$2;
      }
    }
    return bubbles;
  }
}
