import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/game/cards.dart';
import 'package:masmus/game/hand_state.dart';
import 'package:masmus/game/match.dart';
import 'package:masmus/game/move.dart';
import 'package:masmus/game/rules.dart';

import 'scenario.dart';

/// Seats 0 and 1 tie at grande; seats 2 and 3 are worse.
const _tiedGrande = {0: 'R R 7 1', 1: 'R R 7 1', 2: 'C 5 4 1', 3: 'S 6 5 4'};

MatchState _match(
  Map<int, String> hands, {
  List<int> score = const [0, 0],
  int mano = 0,
}) => MatchState(
  rules: const Rules(),
  score: score,
  handNumber: 3,
  hand: dealt(hands, mano: mano),
);

MatchState _play(MatchState match, List<(int, Move)> moves) {
  var current = match;
  for (final (seat, move) in moves) {
    current = current.play(seat, move);
    final json =
        jsonDecode(jsonEncode(current.toJson())) as Map<String, Object?>;
    expect(MatchState.fromJson(json).toJson(), current.toJson());
  }
  return current;
}

/// Passes in every lance until the hand is over.
MatchState _passToTheEnd(MatchState match) {
  var current = match;
  while (current.hand.phase is! HandOver && !current.isOver) {
    final seat = current.hand.turn!;
    final move = current.legalMoves(seat).contains(MoveKind.paso)
        ? paso
        : noHayMus;
    current = _play(current, [(seat, move)]);
  }
  return current;
}

void main() {
  group('starting a match', () {
    test('R-ORD-4 · the mano is drawn from the seed and the first hand has '
        'mus corrido', () {
      final match = MatchState.start(seed: 7);
      expect(match.handNumber, 1);
      expect(match.score, [0, 0]);
      expect(match.hand.musCorrido, isTrue);
      expect(match.hand.mano, MatchState.start(seed: 7).hand.mano);
      final cards = [...match.hand.hands.expand((h) => h), ...match.hand.stock];
      expect(cards.toSet(), spanishDeck.toSet());
      final manos = {
        for (var seed = 0; seed < 40; seed++)
          MatchState.start(seed: seed).hand.mano,
      };
      expect(manos, {0, 1, 2, 3});
    });

    test('moves are checked against the hand being played', () {
      final match = MatchState.start(seed: 7, mano: 2);
      expect(match.legalMoves(2), {MoveKind.mus, MoveKind.noHayMus});
      expect(match.isLegal(2, mus), isTrue);
      expect(match.isLegal(3, mus), isFalse);
      expect(match.isLegal(2, paso), isFalse);
    });

    test('the mano can be given', () {
      expect(MatchState.start(seed: 7, mano: 2).hand.mano, 2);
    });

    test('rules are carried to every hand', () {
      final match = MatchState.start(
        seed: 3,
        rules: const Rules(kings: Kings.four, target: 30),
      );
      expect(match.hand.rules.kings, Kings.four);
      expect(match.rules.target, 30);
    });
  });

  group('after the count', () {
    test('R-FIN-4 · the match waits for the next hand, which has the next '
        'mano and no mus corrido', () {
      final counted = _passToTheEnd(_match(_tiedGrande, mano: 1));
      expect(counted.isCounted, isTrue);
      expect(counted.isOver, isFalse);
      expect(counted.scoreNow, counted.count!.after);
      for (final seat in [0, 1, 2, 3]) {
        expect(counted.legalMoves(seat), isEmpty);
      }
      final next = counted.nextHand();
      expect(next.handNumber, 4);
      expect(next.score, counted.scoreNow);
      expect(next.hand.mano, 2);
      expect(next.hand.musCorrido, isFalse);
      expect(next.hand.phase, isA<MusTurn>().having((p) => p.seat, 'seat', 2));
      final cards = [...next.hand.hands.expand((h) => h), ...next.hand.stock];
      expect(cards.toSet(), spanishDeck.toSet());
    });

    test(
      'R-ORD-3 · after mus corrido, the next mano follows the one who cut',
      () {
        var match = MatchState.start(seed: 11, mano: 0);
        match = _play(match, [(0, mus), (1, mus), (2, mus), (3, mus)]);
        for (final seat in [0, 1, 2, 3]) {
          match = _play(match, [
            (seat, Discard([match.hand.hands[seat].first])),
          ]);
        }
        expect(match.hand.mano, 1);
        match = _play(match, [(1, mus), (2, noHayMus)]);
        expect(match.hand.mano, 2);
        match = _passToTheEnd(match);
        expect(match.nextHand().hand.mano, 3);
      },
    );

    test('there is no next hand before the count', () {
      expect(() => _match(_tiedGrande).nextHand(), throwsStateError);
    });
  });

  group('the end of the match', () {
    test('R-FIN-2 · S-11: the points of a "no quiero" can win the match '
        'mid-hand', () {
      final match = _play(_match(_tiedGrande, score: const [20, 39]), [
        (0, noHayMus),
        (0, envido(2)),
        (1, envido(5)),
        (2, noQuiero),
        (0, noQuiero),
      ]);
      expect(match.isOver, isTrue);
      expect(match.winner, 1);
      expect(match.end, MatchEnd.noQuiero);
      expect(match.scoreNow, [20, 41]);
      expect(match.count, isNull);
      expect(match.legalMoves(2), isEmpty);
      expect(() => match.play(2, paso), throwsStateError);
    });

    test('R-FIN-3 · S-9: an accepted órdago decides the match; on a tie, '
        'the player nearer the mano wins', () {
      final match = _play(_match(_tiedGrande), [
        (0, noHayMus),
        (0, ordago),
        (1, quiero),
      ]);
      expect(match.isOver, isTrue);
      expect(match.winner, 0);
      expect(match.end, MatchEnd.ordago);
    });

    test('R-REC-6 · a team reaching the target in the count wins', () {
      final match = _passToTheEnd(_match(_tiedGrande, score: const [39, 0]));
      expect(match.isOver, isTrue);
      expect(match.winner, 0);
      expect(match.end, MatchEnd.count);
      expect(match.scoreNow.first, 40);
    });

    test('a whole match where everybody always passes ends, and every state '
        'survives JSON', () {
      var match = MatchState.start(seed: 2026);
      var hands = 0;
      while (!match.isOver) {
        match = _passToTheEnd(match);
        if (match.isCounted) {
          match = match.nextHand();
          hands++;
        }
        expect(hands, lessThan(100));
      }
      expect(match.scoreNow[match.winner!], greaterThanOrEqualTo(40));
      expect(match.end, MatchEnd.count);
    });
  });
}
