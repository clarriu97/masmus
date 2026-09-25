import 'dart:async';

import 'package:flutter/foundation.dart';

import '../bots/bot.dart';
import '../game/event.dart';
import '../game/match.dart';
import '../game/move.dart';
import '../services/match_store.dart';
import '../services/scheduler.dart';

/// How long a bot takes to move, so each move can be read before the next.
enum Pace {
  slow(Duration(milliseconds: 1800)),
  normal(Duration(milliseconds: 1100)),
  fast(Duration(milliseconds: 450));

  const Pace(this.thinking);

  final Duration thinking;
}

/// Runs a match against bots: takes the human's moves, makes the bots move
/// one at a time after their thinking pause, and saves after every move.
/// The one place where time passes in a match (AGENTS.md → Architecture).
final class MatchController extends ChangeNotifier {
  /// [bots] plays every seat but the human's; with a bot in every seat
  /// nobody is human.
  MatchController({
    required MatchState match,
    required this.bots,
    required Scheduler scheduler,
    required MatchStore store,
    this.pace = Pace.normal,
  }) : assert(bots.length >= 3),
       _match = match,
       _scheduler = scheduler,
       _store = store {
    _scheduleBot();
  }

  final Map<int, Bot> bots;
  final Scheduler _scheduler;
  final MatchStore _store;
  MatchState _match;
  List<GameEvent> _lastEvents = const [];
  void Function()? _cancelBot;

  MatchState get match => _match;

  /// The seat no bot plays, if any.
  int? get humanSeat =>
      [0, 1, 2, 3].where((seat) => !bots.containsKey(seat)).firstOrNull;

  /// What the last move added to the table's log, to animate it.
  List<GameEvent> get lastEvents => _lastEvents;

  /// Applies from the next bot move on.
  Pace pace;

  Set<MoveKind> get humanMoves =>
      humanSeat == null ? const {} : _match.legalMoves(humanSeat!);

  bool get isHumanTurn => humanMoves.isNotEmpty;

  /// The human's move. Ignored when it isn't their turn (a late tap); an
  /// illegal move on their turn is a bug and throws.
  void play(Move move) {
    if (isHumanTurn) {
      _apply(humanSeat!, move);
    }
  }

  /// Deals the next hand once the count has been seen. Ignored otherwise.
  void nextHand() {
    if (!_match.isCounted) {
      return;
    }
    _match = _match.nextHand();
    _lastEvents = const [];
    _changed();
  }

  void _apply(int seat, Move move) {
    final before = _match.hand.log.length;
    _match = _match.play(seat, move);
    _lastEvents = _match.hand.log.sublist(before);
    _changed();
  }

  void _changed() {
    unawaited(_store.save(_match));
    notifyListeners();
    _scheduleBot();
  }

  void _scheduleBot() {
    final seat = _match.hand.turn;
    final bot = bots[seat];
    if (_cancelBot != null || _match.isOver || seat == null || bot == null) {
      return;
    }
    _cancelBot = _scheduler.after(pace.thinking, () {
      _cancelBot = null;
      _apply(seat, bot.choose(SeatView.of(_match, seat)));
    });
  }

  @override
  void dispose() {
    _cancelBot?.call();
    _cancelBot = null;
    super.dispose();
  }
}
