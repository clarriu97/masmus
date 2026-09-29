import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/bots/arena.dart';
import 'package:masmus/bots/bot.dart';
import 'package:masmus/bots/heuristic_bot.dart';
import 'package:masmus/bots/strategic_bot.dart';
import 'package:masmus/game/cards.dart';
import 'package:masmus/game/event.dart';
import 'package:masmus/game/hand_state.dart';
import 'package:masmus/game/hand_value.dart';
import 'package:masmus/game/match.dart';
import 'package:masmus/game/move.dart';
import 'package:masmus/game/rules.dart';
import 'package:masmus/game/table.dart';

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

bool _playing(MatchState match, Lance lance) => switch (match.hand.phase) {
  LanceTurn(lance: final playing) => playing == lance,
  _ => false,
};

int _mostEnvitesByATeam(List<GameEvent> log) {
  final start = log.lastIndexWhere((event) => event is LanceStarted);
  final seats = [
    for (final event in log.skip(start + 1))
      if (event case EnvidoSaid(:final seat)) seat,
  ];
  return [
    for (final team in [0, 1])
      seats.where((seat) => teamOf(seat) == team).length,
  ].reduce(max);
}

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

  test('a pair that bet with nothing and was raised never pays to see: '
      'it refuses, or a bluffer raises again (seen in a playtest)', () {
    for (final personality in Personality.values) {
      for (final seed in [..._seeds, 5, 6, 7, 8, 9]) {
        var match = _playAll(
          _match({
            0: 'R R 7 7',
            1: '4 5 6 7',
            2: 'R R C 7',
            3: '4 5 6 1',
          }, mano: 1),
          [(1, const NoHayMus()), (1, const Envido(2)), (2, const Envido(2))],
        );
        for (var answers = 0; answers < 2; answers++) {
          final seat = match.hand.turn!;
          if (!_playing(match, Lance.grande) || seat.isEven) {
            break;
          }
          final move = StrategicBot(
            personality,
            Random(seed),
          ).choose(SeatView.of(match, seat));
          expect(
            move,
            isNot(isA<Quiero>()),
            reason: '$personality, seed $seed, seat $seat',
          );
          if (move is! NoQuiero) {
            break;
          }
          match = match.play(seat, move);
        }
      }
    }
  });

  test('two strong hands at grande raise at most once each, not without end '
      '(a playtest reached 40 in the first hand)', () {
    for (final seed in _seeds) {
      var match = _match({
        0: 'R R 3 7',
        1: '3 3 R 6',
        2: 'R 3 C 7',
        3: 'C C 6 5',
      }, mano: 1);
      final bots = [
        for (final personality in Personality.values)
          StrategicBot(personality, Random(seed)),
      ];
      match = match.play(1, const NoHayMus());
      while (_playing(match, Lance.grande)) {
        final seat = match.hand.turn!;
        match = match.play(seat, bots[seat].choose(SeatView.of(match, seat)));
      }
      final envites = match.hand.log.whereType<EnvidoSaid>().toList();
      for (final team in [0, 1]) {
        expect(
          envites.where((envite) => teamOf(envite.seat) == team).length,
          lessThanOrEqualTo(StrategicBot.maxEnvites),
          reason: 'seed $seed: $envites',
        );
      }
    }
  });

  test('against rivals who cut the mus, the careful bluff far less and the '
      'bluffers about the same', () {
    int bluffs(Personality personality, {required bool rivalCut}) {
      final match = _playAll(
        _match({
          0: '4 5 6 7',
          1: 'S C 6 5',
          2: '4 5 6 1',
          3: 'R R C 1',
        }, mano: 3),
        [
          if (rivalCut)
            (3, const NoHayMus())
          else ...[
            (3, const Mus()),
            (0, const NoHayMus()),
          ],
          (3, const Paso()),
        ],
      );
      expect(match.hand.turn, 0);
      var count = 0;
      for (var seed = 0; seed < 400; seed++) {
        final move = StrategicBot(
          personality,
          Random(seed),
        ).choose(SeatView.of(match, 0));
        if (move is Envido) {
          count++;
        }
      }
      return count;
    }

    final careful = bluffs(Personality.calculador, rivalCut: true);
    final carefulFree = bluffs(Personality.calculador, rivalCut: false);
    expect(
      careful,
      lessThan(carefulFree * 0.7),
      reason: '$careful vs $carefulFree',
    );
    final bluffer = bluffs(Personality.farolero, rivalCut: true);
    final blufferFree = bluffs(Personality.farolero, rivalCut: false);
    expect(
      bluffer,
      greaterThan(blufferFree * 0.8),
      reason: '$bluffer vs $blufferFree',
    );
  });

  test('plays whole matches with only legal moves', () {
    for (var seed = 0; seed < 12; seed++) {
      final bots = [
        for (final personality in Personality.values)
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
        expect(
          _mostEnvitesByATeam(match.hand.log),
          lessThanOrEqualTo(StrategicBot.maxEnvites),
          reason: 'seed $seed',
        );
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
