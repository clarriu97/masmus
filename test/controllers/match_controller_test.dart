import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/bots/random_bot.dart';
import 'package:masmus/controllers/match_controller.dart';
import 'package:masmus/game/event.dart';
import 'package:masmus/game/hand_state.dart';
import 'package:masmus/game/match.dart';
import 'package:masmus/game/move.dart';
import 'package:masmus/services/match_store.dart';
import 'package:masmus/services/scheduler.dart';

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
    scheduler: scheduler,
    store: store,
    pace: pace,
  );
  addTearDown(controller.dispose);
  return (controller: controller, scheduler: scheduler, store: store);
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
      scheduler.advance(Pace.normal.thinking);
      final added = controller.match.hand.log.sublist(before);
      expect(added, isNotEmpty);
      expect(controller.lastEvents, added);
      expect(turn, isNot(0));
      moves++;
    }
    expect(moves, greaterThan(0));
    expect(scheduler.hasPending, isFalse, reason: 'waiting for the human');
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
      expect(controller.lastEvents, const [MusSaid(0)]);
      expect(notified, 1);
      expect((await store.load())!.toJson(), controller.match.toJson());
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
        expect(controller.lastEvents, isEmpty);
      }
      scheduler.advance(Pace.fast.thinking);
      expect(++steps, lessThan(20000));
    }
    expect(scheduler.hasPending, isFalse);
    expect((await store.load())!.toJson(), controller.match.toJson());
  });
}
