import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/bots/arena.dart';
import 'package:masmus/bots/bot.dart';
import 'package:masmus/bots/heuristic_bot.dart';
import 'package:masmus/bots/strategic_bot.dart';
import 'package:masmus/game/cards.dart';
import 'package:masmus/game/match.dart';
import 'package:masmus/game/move.dart';
import 'package:masmus/game/rules.dart';

import '../game/helpers.dart';
import '../game/scenario.dart';

const _seeds = [0, 1, 2, 3, 4];

const _filler = {1: '4 5 6 7', 2: '4 5 6 7', 3: '4 5 6 7'};

MatchState _match(
  Map<int, String> hands, {
  int mano = 0,
  List<int> score = const [0, 0],
}) => MatchState(
  rules: const Rules(),
  score: score,
  handNumber: 1,
  hand: dealt(hands, mano: mano),
);

MatchState _playAll(MatchState match, List<(int, Move)> moves) {
  var current = match;
  for (final (seat, move) in moves) {
    current = current.play(seat, move);
  }
  return current;
}

List<Move> _choices(MatchState match, int seat) => [
  for (final seed in _seeds)
    StrategicBot(
      Personality.calculador,
      Random(seed),
    ).choose(SeatView.of(match, seat)),
];

void main() {
  group('mus', () {
    test('cuts it with 31, duples of kings or medias of kings', () {
      for (final hand in ['R C 7 4', 'R R C C', 'R R R 5']) {
        expect(
          _choices(_match({0: hand, ..._filler}), 0),
          everyElement(isA<NoHayMus>()),
          reason: hand,
        );
      }
    });

    test('asks for mus with a hand that wins nothing', () {
      final match = _playAll(
        _match({0: '4 5 6 7', 1: '4 5 6 7', 2: 'S C 2 2', 3: 'S C 3 3'}),
        [(0, const Mus())],
      );
      expect(_choices(match, 1), everyElement(isA<Mus>()));
    });
  });

  group('discards', () {
    MatchState discarding(String hand) =>
        _playAll(_match({0: hand, ..._filler}), [
          for (final seat in [0, 1, 2, 3]) (seat, const Mus()),
        ]);

    List<List<PlayingCard>> discards(String hand) => [
      for (final move in _choices(discarding(hand), 0)) (move as Discard).cards,
    ];

    test('keep a pair of kings', () {
      for (final thrown in discards('R R 6 4')) {
        expect(thrown, isNot(contains(PlayingCard.parse('Ro'))));
        expect(thrown, isNot(contains(PlayingCard.parse('Rc'))));
      }
    });

    test('throw away only the odd card of medias of kings', () {
      expect(discards('R R R 5'), everyElement(cards('5o')));
    });

    test('keep three figures to look for juego', () {
      for (final thrown in discards('C S S 4')) {
        expect(thrown, cards('4o'));
      }
    });

    test('keep a pair of aces', () {
      for (final thrown in discards('1 1 6 7')) {
        expect(thrown, isNot(contains(PlayingCard.parse('1o'))));
        expect(thrown, isNot(contains(PlayingCard.parse('1c'))));
      }
    });
  });

  group('envites', () {
    MatchState grande(
      String hand, {
      int mano = 1,
      List<int> score = const [0, 0],
    }) => _playAll(_match({0: hand, ..._filler}, mano: mano, score: score), [
      (mano, const NoHayMus()),
    ]);

    test('never refuses with four kings at grande', () {
      final match = _playAll(grande('R R R R'), [(1, const Envido(2))]);
      expect(_choices(match, 0), everyElement(isNot(isA<NoQuiero>())));
    });

    test('never goes to órdago at grande with four aces', () {
      final match = _playAll(grande('1 1 1 1', mano: 0), []);
      expect(_choices(match, 0), everyElement(isNot(isA<Ordago>())));
    });

    test('an órdago is accepted more readily when far behind', () {
      MatchState ordago(List<int> score) =>
          _playAll(grande('R C 7 5', score: score), [(1, const Ordago())]);
      expect(_choices(ordago(const [5, 35]), 0), everyElement(isA<Quiero>()));
      expect(_choices(ordago(const [35, 5]), 0), everyElement(isA<NoQuiero>()));
    });

    test('lets the partner decide when its own hand is not good', () {
      final match = _playAll(
        _match({
          0: '4 5 6 7',
          1: '6 5 4 1',
          2: 'R R R 7',
          3: 'C C 6 5',
        }, mano: 1),
        [(1, const NoHayMus()), (1, const Envido(2))],
      );
      expect(match.hand.turn, 2);
      expect(_choices(match, 2), everyElement(isNot(isA<NoQuiero>())));
      final weak = _playAll(
        _match({
          0: 'R R R 7',
          1: '6 5 4 1',
          2: '4 5 6 7',
          3: 'C C 6 5',
        }, mano: 1),
        [(1, const NoHayMus()), (1, const Envido(2))],
      );
      expect(weak.hand.turn, 2);
      expect(_choices(weak, 2), everyElement(isA<NoQuiero>()));
    });
  });

  test('plays whole matches with only legal moves', () {
    for (var seed = 0; seed < 12; seed++) {
      final bots = [
        for (final personality in Personality.all)
          StrategicBot(personality, Random(seed)),
      ];
      var match = MatchState.start(seed: seed);
      var moves = 0;
      while (!match.isOver) {
        if (match.isCounted) {
          match = match.nextHand();
          continue;
        }
        final seat = match.hand.turn!;
        final move = bots[seat].choose(SeatView.of(match, seat));
        expect(match.isLegal(seat, move), isTrue, reason: 'seed $seed: $move');
        match = match.play(seat, move);
        expect(++moves, lessThan(5000), reason: 'seed $seed never ends');
      }
    }
  });

  test('beats the heuristic bot in the arena', () {
    final result = playArena(
      a: (random) => StrategicBot(Personality.calculador, random),
      b: (random) => HeuristicBot(Personality.calculador, random),
      pairs: 150,
    );
    expect(result.interval.$1, greaterThan(0.5));
  });
}
