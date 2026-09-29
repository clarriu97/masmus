import 'dart:async';

import 'package:flutter/foundation.dart';

import '../bots/bot.dart';
import '../bots/heuristic_bot.dart';
import '../game/event.dart';
import '../game/match.dart';
import '../game/move.dart';
import '../game/table.dart';
import '../services/match_store.dart';
import '../services/scheduler.dart';

/// How long a bot takes to move, and how long the table holds what just
/// happened, so each thing can be read before the next.
enum Pace {
  slow(Duration(milliseconds: 3200), 1.4),
  normal(Duration(milliseconds: 2200), 1),
  fast(Duration(milliseconds: 1200), 0.6);

  const Pace(this.thinking, this._holding);

  final Duration thinking;
  final double _holding;

  /// How long [event] stays alone on the table before the next one shows.
  Duration hold(GameEvent event) => _normalHold(event) * _holding;

  static Duration _normalHold(GameEvent event) => switch (event) {
    NoHayMusSaid() ||
    ManoMoved() ||
    LanceClosed() ||
    HandEnded() => const Duration(milliseconds: 1800),
    LanceStarted() => const Duration(milliseconds: 700),
    _ => const Duration(milliseconds: 1000),
  };
}

/// Cards dealt from the deck one after another: who gets each, from the
/// mano on. The table draws them flying; nobody moves until they land.
final class Deal {
  Deal(this.seats);

  /// The four cards of each player, at the start of a hand.
  factory Deal.hand(int mano) => Deal([
    for (var round = 0; round < 4; round++)
      for (final seat in speakingOrder(mano)) seat,
  ]);

  final List<int> seats;

  static const between = Duration(milliseconds: 110);
  static const flight = Duration(milliseconds: 350);

  Duration get duration => between * (seats.length - 1) + flight;
}

/// Runs a match against bots: takes the human's moves, makes the bots move
/// one at a time after their thinking pause, and saves after every move.
/// A move can bring many things at once (the last paso closes the chica,
/// everyone declares pares…): the table is shown them one at a time
/// ([shown]), each for as long as the [pace] holds it, and nobody moves
/// until it has seen them all. The one place where time passes in a match
/// (AGENTS.md → Architecture).
final class MatchController extends ChangeNotifier {
  /// [bots] plays every seat but the human's; with a bot in every seat
  /// nobody is human.
  MatchController({
    required MatchState match,
    required this.bots,
    required this.seats,
    required Scheduler scheduler,
    required MatchStore store,
    this.pace = Pace.normal,
    bool deal = false,
  }) : assert(bots.length >= 3),
       _match = match,
       _shown = match.hand.log.length,
       _scheduler = scheduler,
       _store = store {
    if (deal) {
      _deal(Deal.hand(match.hand.mano));
    } else {
      _scheduleBot();
    }
  }

  final Map<int, Bot> bots;

  /// Who each bot is, saved with the match so it resumes with the same.
  final Map<int, Personality> seats;
  final Scheduler _scheduler;
  final MatchStore _store;
  MatchState _match;
  int _shown;
  Deal? _dealing;
  void Function()? _cancel;

  MatchState get match => _match;

  /// The cards being dealt right now, if any.
  Deal? get dealing => _dealing;

  /// How many events of the hand's log the table shows by now.
  int get shown => _shown;

  /// The table is still being shown what the last move brought, or the
  /// cards are being dealt.
  bool get catchingUp => _dealing != null || _shown < _match.hand.log.length;

  /// The seat no bot plays, if any.
  int? get humanSeat =>
      [0, 1, 2, 3].where((seat) => !bots.containsKey(seat)).firstOrNull;

  /// Applies from the next bot move on.
  Pace pace;

  Set<MoveKind> get humanMoves => humanSeat == null || catchingUp
      ? const {}
      : _match.legalMoves(humanSeat!);

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
    if (!_match.isCounted || catchingUp) {
      return;
    }
    _match = _match.nextHand();
    _shown = 0;
    _save();
    _deal(Deal.hand(_match.hand.mano));
  }

  /// The move is shown at once; what it brought, one thing at a time.
  void _apply(int seat, Move move) {
    _shown = _match.hand.log.length + 1;
    _match = _match.play(seat, move);
    _save();
    _shownOne();
  }

  /// Saves after every move; a match that is over is no longer resumed.
  void _save() => unawaited(
    _match.isOver
        ? _store.clear()
        : _store.save(SavedMatch(match: _match, bots: seats)),
  );

  /// The table shows one more event. The last discard of a round comes
  /// with the cards each player asked for.
  void _shownOne() {
    final log = _match.hand.log;
    final at = _shown - 1;
    if (log[at] is Discarded) {
      final start = log.lastIndexWhere((event) => event is! Discarded, at) + 1;
      final round = log.sublist(start, at + 1).cast<Discarded>();
      if (round.length == 4) {
        _deal(
          Deal([
            for (final discard in round)
              for (var i = 0; i < discard.count; i++) discard.seat,
          ]),
        );
        return;
      }
    }
    notifyListeners();
    _next();
  }

  void _deal(Deal deal) {
    _dealing = deal;
    notifyListeners();
    _cancel = _scheduler.after(deal.duration, () {
      _cancel = null;
      _dealing = null;
      notifyListeners();
      _next();
    });
  }

  void _next() {
    if (_shown < _match.hand.log.length) {
      _cancel = _scheduler.after(pace.hold(_match.hand.log[_shown - 1]), () {
        _cancel = null;
        _shown++;
        _shownOne();
      });
    } else {
      _scheduleBot();
    }
  }

  void _scheduleBot() {
    final seat = _match.hand.turn;
    final bot = bots[seat];
    if (_cancel != null || _match.isOver || seat == null || bot == null) {
      return;
    }
    _cancel = _scheduler.after(pace.thinking, () {
      _cancel = null;
      _apply(seat, bot.choose(SeatView.of(_match, seat)));
    });
  }

  @override
  void dispose() {
    _cancel?.call();
    _cancel = null;
    super.dispose();
  }
}
