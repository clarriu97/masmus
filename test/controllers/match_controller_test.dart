import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/bots/heuristic_bot.dart';
import 'package:masmus/bots/random_bot.dart';
import 'package:masmus/controllers/match_controller.dart';
import 'package:masmus/game/event.dart';
import 'package:masmus/game/hand_state.dart';
import 'package:masmus/game/hand_value.dart';
import 'package:masmus/game/match.dart';
import 'package:masmus/game/move.dart';
import 'package:masmus/game/outcome.dart';
import 'package:masmus/services/match_store.dart';
import 'package:masmus/services/scheduler.dart';

import '../game/scenario.dart';
import '../helpers/table.dart';

const _seats = {
  1: Personality.prudente,
  2: Personality.calculador,
  3: Personality.temeraria,
};

typedef _Table = ({
  MatchController controller,
  ManualScheduler scheduler,
  MatchStore store,
});

/// The human in seat 0 against random bots, with the bot in [mano] to speak
/// first.
_Table _table({int mano = 1, int seed = 3, Pace pace = Pace.normal}) {
  final scheduler = ManualScheduler();
  final store = MatchStore.inMemory();
  final controller = MatchController(
    match: MatchState.start(seed: seed, mano: mano),
    bots: {
      for (final seat in [1, 2, 3]) seat: RandomBot(Random(seat)),
    },
    seats: _seats,
    scheduler: scheduler,
    store: store,
    pace: pace,
  );
  addTearDown(controller.dispose);
  return (controller: controller, scheduler: scheduler, store: store);
}

/// Moves the clock in small steps until the table shows something new.
void _untilSomethingHappens(
  MatchController controller,
  ManualScheduler scheduler,
) {
  final shown = controller.shown;
  final length = controller.match.hand.log.length;
  while (controller.shown == shown &&
      controller.match.hand.log.length == length) {
    scheduler.advance(const Duration(milliseconds: 100));
  }
}

void main() {
  test('bots move one at a time, each after its thinking pause', () {
    final (:controller, :scheduler, store: _) = _table();
    expect(controller.humanSeat, 0);
    expect(scheduler.requested, [Pace.normal.thinking]);

    scheduler.advance(Pace.normal.thinking - const Duration(milliseconds: 1));
    expect(controller.match.hand.log, isEmpty);

    var moves = 0;
    while (!controller.isHumanTurn && !controller.match.isCounted) {
      final turn = controller.match.hand.turn;
      final before = controller.match.hand.log.length;
      _untilSomethingHappens(controller, scheduler);
      expect(controller.shown, before + 1, reason: 'the move shows at once');
      expect(turn, isNot(0));
      while (controller.catchingUp) {
        expect(controller.match.hand.log.length, greaterThan(before));
        _untilSomethingHappens(controller, scheduler);
      }
      moves++;
    }
    expect(moves, greaterThan(0));
    expect(scheduler.hasPending, isFalse, reason: 'waiting for the human');
  });

  test('what a move brings is shown one thing at a time, each held as long '
      'as its kind needs, and nobody moves meanwhile', () {
    final scheduler = ManualScheduler();
    final controller = tableController(
      hands: const {0: 'R R 5 4', 1: 'C C S S', 2: '7 7 7 1', 3: '6 5 4 1'},
      mano: 1,
      moves: [(1, const NoHayMus()), ...passes(1).take(3)],
      scheduler: scheduler,
    );
    addTearDown(controller.dispose);
    expect(controller.isHumanTurn, isTrue);
    final before = controller.match.hand.log.length;
    controller.play(const Paso());
    final log = controller.match.hand.log;
    expect(log.length, greaterThan(before + 1));
    expect(log[before], const PasoSaid(0));
    expect(log[before + 1], isA<LanceClosed>());

    expect(controller.shown, before + 1);
    expect(controller.catchingUp, isTrue);
    expect(controller.humanMoves, isEmpty);
    expect(controller.isHumanTurn, isFalse);
    for (var shown = before + 1; shown < log.length; shown++) {
      final hold = Pace.normal.hold(log[shown - 1]);
      scheduler.advance(hold - const Duration(milliseconds: 1));
      expect(controller.shown, shown, reason: '${log[shown - 1]} still held');
      scheduler.advance(const Duration(milliseconds: 1));
      expect(controller.shown, shown + 1);
    }
    expect(controller.catchingUp, isFalse);
    expect(controller.match.hand.turn, 1, reason: 'the chica, from the mano');
    expect(scheduler.requested.last, Pace.normal.thinking);
  });

  test('the table holds the close of a lance longer than a word, and each '
      'pace holds it for longer or shorter', () {
    const closed = LanceClosed(EnPaso(Lance.grande));
    expect(
      Pace.normal.hold(closed),
      greaterThan(Pace.normal.hold(const PasoSaid(0))),
    );
    expect(Pace.slow.hold(closed), greaterThan(Pace.normal.hold(closed)));
    expect(Pace.fast.hold(closed), lessThan(Pace.normal.hold(closed)));
    expect(
      Pace.fast.thinking,
      greaterThanOrEqualTo(const Duration(seconds: 1)),
      reason: 'even fast, a move can be followed',
    );
  });

  test('a new match starts by dealing four cards to each, from the mano on, '
      'and nobody plays until they have landed', () {
    final scheduler = ManualScheduler();
    final controller = MatchController(
      match: MatchState.start(seed: 3, mano: 0),
      bots: {
        for (final seat in [1, 2, 3]) seat: RandomBot(Random(seat)),
      },
      seats: _seats,
      scheduler: scheduler,
      store: MatchStore.inMemory(),
      deal: true,
    );
    addTearDown(controller.dispose);
    final deal = controller.dealing!;
    expect(deal.seats, [
      for (var i = 0; i < 4; i++) ...[0, 1, 2, 3],
    ]);
    expect(deal.duration, Deal.between * 15 + Deal.flight);
    expect(controller.humanMoves, isEmpty);
    scheduler.advance(deal.duration - const Duration(milliseconds: 1));
    expect(controller.isHumanTurn, isFalse);
    scheduler.advance(const Duration(milliseconds: 1));
    expect(controller.dealing, isNull);
    expect(controller.isHumanTurn, isTrue);
  });

  test('the next hand is dealt from its mano before its first word', () {
    final scheduler = ManualScheduler();
    final controller = tableController(
      hands: const {0: 'R 6 5 4', 1: 'S 7 6 1', 2: '4 5 6 7', 3: '4 5 1 7'},
      mano: 1,
      moves: [(1, const NoHayMus()), ...passes(1), ...passes(1), ...passes(1)],
      scheduler: scheduler,
    );
    addTearDown(controller.dispose);
    controller.nextHand();
    expect(controller.match.handNumber, 2);
    expect(controller.dealing!.seats.take(4), [2, 3, 0, 1]);
    final requested = scheduler.requested.length;
    scheduler.advance(controller.dealing!.duration);
    expect(scheduler.requested.length, requested + 1);
    expect(scheduler.requested.last, Pace.normal.thinking, reason: 'the mano');
  });

  test('the last discard of a round deals what each asked for, in order', () {
    const hands = {0: 'R 7 5 4', 1: 'S C 7 6', 2: '4 5 6 1', 3: 'R 5 1 4'};
    final dealtHands = dealt(hands, mano: 1).hands;
    Discard first(int seat, int count) =>
        Discard(dealtHands[seat].take(count).toList());
    final scheduler = ManualScheduler();
    final controller = tableController(
      hands: hands,
      mano: 1,
      moves: [
        for (final seat in [1, 2, 3, 0]) (seat, const Mus()),
        (1, first(1, 2)),
        (2, first(2, 1)),
        (3, first(3, 3)),
      ],
      scheduler: scheduler,
    );
    addTearDown(controller.dispose);
    expect(controller.dealing, isNull);
    controller.play(first(0, 1));
    expect(controller.dealing!.seats, [1, 1, 2, 3, 3, 3, 0]);
    expect(controller.humanMoves, isEmpty);
    scheduler.advance(controller.dealing!.duration);
    expect(controller.dealing, isNull);
  });

  test('a move of the human out of turn is ignored', () {
    final (:controller, scheduler: _, store: _) = _table();
    var notified = 0;
    controller.addListener(() => notified++);
    controller.play(const Mus());
    expect(controller.match.hand.log, isEmpty);
    expect(notified, 0);
  });

  test(
    "the human's move is played, saved and hands over to the bots",
    () async {
      final (:controller, :scheduler, :store) = _table(mano: 0);
      expect(controller.isHumanTurn, isTrue);
      expect(scheduler.hasPending, isFalse);
      var notified = 0;
      controller.addListener(() => notified++);

      controller.play(const Mus());

      expect(controller.match.hand.log, const [MusSaid(0)]);
      expect(controller.shown, 1);
      expect(notified, 1);
      expect(store.saved!.match.toJson(), controller.match.toJson());
      expect(store.saved!.bots, _seats);
      expect(scheduler.hasPending, isTrue, reason: 'seat 1 thinks next');
    },
  );

  test('an illegal move on the human turn is a bug', () {
    final (:controller, scheduler: _, store: _) = _table(mano: 0);
    expect(() => controller.play(const Paso()), throwsStateError);
  });

  test('the pace sets how long the next bot thinks', () {
    final (:controller, :scheduler, store: _) = _table(pace: Pace.slow);
    expect(scheduler.requested.last, Pace.slow.thinking);
    controller.pace = Pace.fast;
    scheduler.advance(Pace.slow.thinking);
    expect(scheduler.requested.last, Pace.fast.thinking);
  });

  test('closing the table cancels what a bot was about to do', () {
    final scheduler = ManualScheduler();
    MatchController(
      match: MatchState.start(seed: 3, mano: 1),
      bots: {
        for (final seat in [1, 2, 3]) seat: RandomBot(Random(seat)),
      },
      seats: _seats,
      scheduler: scheduler,
      store: MatchStore.inMemory(),
    ).dispose();
    expect(scheduler.hasPending, isFalse);
    scheduler.advance(const Duration(minutes: 1));
  });

  test('the next hand only comes after the count', () {
    final (:controller, scheduler: _, store: _) = _table(mano: 0);
    controller.nextHand();
    expect(controller.match.handNumber, 1);
  });

  test('a whole match between four bots ends without real waiting', () async {
    final scheduler = ManualScheduler();
    final store = MatchStore.inMemory();
    final controller = MatchController(
      match: MatchState.start(seed: 21),
      bots: {
        for (final seat in [0, 1, 2, 3]) seat: RandomBot(Random(seat)),
      },
      seats: {..._seats, 0: Personality.farolero},
      scheduler: scheduler,
      store: store,
      pace: Pace.fast,
    );
    addTearDown(controller.dispose);
    expect(controller.humanSeat, isNull);
    expect(controller.humanMoves, isEmpty);

    var steps = 0;
    while (!controller.match.isOver) {
      if (controller.match.isCounted) {
        expect(controller.match.hand.phase, isA<HandOver>());
        controller.nextHand();
        expect(controller.shown, 0);
      }
      scheduler.advance(Pace.fast.thinking);
      expect(++steps, lessThan(20000));
    }
    scheduler.advance(const Duration(minutes: 1));
    expect(controller.catchingUp, isFalse);
    expect(scheduler.hasPending, isFalse);
    expect(store.saved, isNull, reason: 'a match that is over is not resumed');
  });
}
