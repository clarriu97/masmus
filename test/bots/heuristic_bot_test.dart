import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/bots/bot.dart';
import 'package:masmus/bots/heuristic_bot.dart';
import 'package:masmus/game/cards.dart';
import 'package:masmus/game/match.dart';
import 'package:masmus/game/move.dart';
import 'package:masmus/game/rules.dart';

import '../game/helpers.dart';
import '../game/scenario.dart';

MatchState _match(
  Map<int, String> hands, {
  int mano = 0,
  Rules rules = const Rules(),
}) => MatchState(
  rules: rules,
  score: const [0, 0],
  handNumber: 1,
  hand: dealt(hands, mano: mano, rules: rules),
);

MatchState _playAll(MatchState match, List<(int, Move)> moves) {
  var current = match;
  for (final (seat, move) in moves) {
    current = current.play(seat, move);
  }
  return current;
}

Move _choose(Personality personality, MatchState match, int seat) =>
    HeuristicBot(personality, Random(0)).choose(SeatView.of(match, seat));

const _filler = {1: 'S C 4 3', 2: 'S C 4 3', 3: 'S C 2 2'};

void main() {
  group('mus', () {
    test('cuts it with 31, 32 or 40, medias or duples', () {
      for (final hand in [
        'R C 7 4',
        'R C 7 5',
        'R C S R',
        '7 7 7 1',
        '7 7 5 5',
      ]) {
        final match = _match({0: hand, ..._filler});
        expect(
          _choose(Personality.calculador, match, 0),
          isA<NoHayMus>(),
          reason: hand,
        );
      }
    });

    test('as mano, cuts it with two kings; otherwise asks for mus', () {
      final mano = _match({0: 'R R 7 1', ..._filler});
      expect(_choose(Personality.prudente, mano, 0), isA<NoHayMus>());
      final second = _match({
        0: '7 6 5 1',
        1: 'R R 7 1',
        2: 'S 6 5 4',
        3: 'C S 6 5',
      });
      final afterMano = second.play(0, const Mus());
      expect(_choose(Personality.prudente, afterMano, 1), isA<Mus>());
    });
  });

  group('discards', () {
    MatchState discarding(String hand, {Rules rules = const Rules()}) =>
        _playAll(_match({0: hand, ..._filler}, rules: rules), [
          for (final seat in [0, 1, 2, 3]) (seat, const Mus()),
        ]);

    List<PlayingCard> discarded(MatchState match) =>
        (_choose(Personality.calculador, match, 0) as Discard).cards;

    test('keep kings, aces and pairs', () {
      final match = discarding('R 7 5 1');
      expect(discarded(match), cards('7o 5o'));
      final pair = discarding('6 6 5 4');
      expect(discarded(pair), cards('5o 4o'));
    });

    test('with 8 kings a 3 is kept as a king and a 2 as an as', () {
      expect(discarded(discarding('3 2 7 5')), cards('7o 5o'));
      expect(
        discarded(discarding('3 2 7 5', rules: const Rules(kings: Kings.four))),
        cards('3o 2o 7o 5o'),
      );
    });

    test('with nothing to throw away, let go of the lowest single card', () {
      expect(discarded(discarding('R 1 7 7')), cards('1o'));
    });
  });

  group('envites', () {
    MatchState grande(String hand, {int mano = 0}) => _playAll(
      _match({0: hand, ..._filler}, mano: mano),
      [(mano, const NoHayMus())],
    );

    test('bets with a strong hand; the boldest go to órdago', () {
      final kings = grande('R R R R');
      expect(_choose(Personality.prudente, kings, 0), isA<Envido>());
      expect(_choose(Personality.temeraria, kings, 0), isA<Ordago>());
    });

    test('never refuses with four kings', () {
      final match = _playAll(grande('R R R R', mano: 1), [
        (1, const Envido(2)),
      ]);
      for (final personality in Personality.all) {
        expect(
          _choose(personality, match, 0),
          isNot(isA<NoQuiero>()),
          reason: personality.name,
        );
      }
    });

    test('the personality sets how much it takes to accept', () {
      final match = _playAll(grande('7 6 5 4', mano: 1), [
        (1, const Envido(2)),
      ]);
      expect(_choose(Personality.prudente, match, 0), isA<NoQuiero>());
      expect(_choose(Personality.temeraria, match, 0), isA<Quiero>());
    });

    test('an órdago is only accepted with a hand for it', () {
      final junk = _playAll(grande('7 6 5 4', mano: 1), [(1, const Ordago())]);
      expect(_choose(Personality.temeraria, junk, 0), isA<NoQuiero>());
      final kings = _playAll(grande('R R R R', mano: 1), [(1, const Ordago())]);
      expect(_choose(Personality.prudente, kings, 0), isA<Quiero>());
    });
  });

  test('plays whole matches with only legal moves', () {
    for (var seed = 0; seed < 30; seed++) {
      final bots = [
        for (final personality in Personality.all)
          HeuristicBot(personality, Random(seed)),
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
}
