import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/bots/bot.dart';
import 'package:masmus/bots/random_bot.dart';
import 'package:masmus/game/cards.dart';
import 'package:masmus/game/hand_state.dart';
import 'package:masmus/game/hand_value.dart';
import 'package:masmus/game/match.dart';
import 'package:masmus/game/move.dart';
import 'package:masmus/game/outcome.dart';
import 'package:masmus/game/rules.dart';

/// Seeds that once broke an invariant. When the simulation fails, add the
/// seed it prints here so it keeps running forever.
const _regressions = <int>[];

/// More matches locally: `SIMULATION_MATCHES=20000 flutter test
/// test/game/simulation_test.dart`.
final _matches =
    int.tryParse(Platform.environment['SIMULATION_MATCHES'] ?? '') ?? 500;

const _maxMoves = 20000;

Rules _rulesFor(int seed) => Rules(
  kings: seed.isEven ? Kings.eight : Kings.four,
  target: seed % 3 == 0 ? 30 : 40,
);

/// Plays at random with odds that make matches long and varied: mus most
/// of the time (so discards and reshuffles happen), small envites, and an
/// órdago only now and then.
final class _ExploringBot implements Bot {
  _ExploringBot(this._random);

  final Random _random;

  static const _odds = {
    MoveKind.mus: 85,
    MoveKind.noHayMus: 15,
    MoveKind.discard: 1,
    MoveKind.paso: 60,
    MoveKind.envido: 30,
    MoveKind.quiero: 40,
    MoveKind.noQuiero: 45,
    MoveKind.ordago: 1,
  };

  @override
  Move choose(SeatView view) {
    final kinds = view.legal.toList()..sort((a, b) => a.index - b.index);
    final total = kinds.fold(0, (sum, kind) => sum + _odds[kind]!);
    var pick = _random.nextInt(total);
    final kind = kinds.firstWhere((kind) => (pick -= _odds[kind]!) < 0);
    return switch (kind) {
      MoveKind.mus => const Mus(),
      MoveKind.noHayMus => const NoHayMus(),
      MoveKind.discard => Discard(
        ([
          ...view.cards,
        ]..shuffle(_random)).take(1 + _random.nextInt(4)).toList(),
      ),
      MoveKind.paso => const Paso(),
      MoveKind.envido => Envido(minEnvido + _random.nextInt(4)),
      MoveKind.quiero => const Quiero(),
      MoveKind.noQuiero => const NoQuiero(),
      MoveKind.ordago => const Ordago(),
    };
  }
}

String _json(MatchState match) => jsonEncode(match.toJson());

MatchState _restored(MatchState match) =>
    MatchState.fromJson(jsonDecode(_json(match)) as Map<String, Object?>);

/// What one simulated match went through, to check the simulation reaches
/// every corner of the rules.
typedef _Seen = ({Set<String> outcomes, MatchEnd end});

/// Plays a whole match between random bots and checks every invariant after
/// every move. Throws a [TestFailure] naming the seed and the move.
_Seen _simulate(int seed) {
  final bots = <Bot>[
    for (var seat = 0; seat < 4; seat++)
      seed % 3 == 0
          ? RandomBot(Random(seed * 4 + seat))
          : _ExploringBot(Random(seed * 4 + seat)),
  ];
  var match = MatchState.start(seed: seed, rules: _rulesFor(seed));
  final outcomes = <String>{};
  var moves = 0;
  void check(bool ok, String what) {
    if (!ok) {
      throw TestFailure('seed $seed, move $moves: $what\n${_json(match)}');
    }
  }

  while (!match.isOver) {
    if (match.isCounted) {
      final next = match.nextHand();
      check(
        _json(next) == _json(_restored(match).nextHand()),
        'the next hand of a restored match differs',
      );
      check(
        next.score[0] == match.scoreNow[0] &&
            next.score[1] == match.scoreNow[1],
        'the score changed between hands',
      );
      match = next;
      continue;
    }
    final seat = match.hand.turn;
    check(seat != null, 'nobody can move in a hand that is not over');
    for (final other in [0, 1, 2, 3]) {
      check(
        match.legalMoves(other).isEmpty == (other != seat),
        'seat $other has moves ${match.legalMoves(other)} out of turn $seat',
      );
    }
    final move = bots[seat!].choose(SeatView.of(match, seat));
    check(match.isLegal(seat, move), 'the bot chose an illegal $move');
    final next = match.play(seat, move);
    check(
      _json(next) == _json(_restored(match).play(seat, move)),
      'a restored match plays $move differently',
    );
    _checkState(before: match, after: next, check: check);
    match = next;
    moves++;
    check(moves < _maxMoves, 'the match never ends');
    if (match.hand.phase is HandOver) {
      outcomes.addAll(match.hand.outcomes.map((o) => o.type));
    }
  }
  return (outcomes: outcomes, end: match.end!);
}

void _checkState({
  required MatchState before,
  required MatchState after,
  required void Function(bool ok, String what) check,
}) {
  final hand = after.hand;
  final everything = [
    ...hand.hands.expand((cards) => cards),
    ...hand.stock,
    ...hand.discards,
  ];
  check(
    everything.length == 40 && everything.toSet().length == 40,
    'the 40 cards are not all there, once each',
  );
  check(everything.toSet().containsAll(spanishDeck), 'a card is missing');
  check(
    hand.hands.every((cards) => cards.length == 4),
    'a hand without 4 cards',
  );

  for (final team in [0, 1]) {
    check(
      after.scoreNow[team] >= before.scoreNow[team],
      'the score of team $team went down',
    );
  }

  final log = before.hand.log;
  check(
    hand.log.length >= log.length &&
        [
          for (var i = 0; i < log.length; i++) identical(hand.log[i], log[i]),
        ].every((same) => same),
    'the log was rewritten',
  );

  final count = after.count;
  if (count != null) {
    final outcomes = hand.outcomes;
    final ordago = outcomes.last is OrdagoQuerido;
    check(
      ordago || outcomes.length == 4,
      'a finished hand without four lances: $outcomes',
    );
    const order = [Lance.grande, Lance.chica, Lance.pares];
    for (var i = 0; i < outcomes.length; i++) {
      final lance = outcomes[i].lance;
      check(
        i < 3
            ? lance == order[i]
            : lance == Lance.juego || lance == Lance.punto,
        'lances out of order: $outcomes',
      );
    }
    for (final team in [0, 1]) {
      check(
        count.before[team] == after.score[team] + hand.pointsNow[team],
        'the count did not start from the score plus the no quiero points',
      );
      final added = count.lances
          .where((lance) => lance.team == team)
          .fold(0, (sum, lance) => sum + lance.points);
      check(
        count.after[team] - count.before[team] == added,
        'the count of team $team does not add up',
      );
    }
  }

  if (after.isOver) {
    final winner = after.winner!;
    switch (after.end!) {
      case MatchEnd.ordago:
        check(
          hand.outcomes.last is OrdagoQuerido,
          'an órdago end without órdago',
        );
      case MatchEnd.count || MatchEnd.noQuiero:
        check(
          after.scoreNow[winner] >= after.rules.target,
          'a winner below the target',
        );
    }
    check(after.legalMoves(0).isEmpty, 'moves after the end');
  }
}

void main() {
  test('random bots play $_matches matches without breaking an invariant', () {
    final outcomes = <String>{};
    final ends = <MatchEnd>{};
    for (var seed = 0; seed < _matches; seed++) {
      final seen = _simulate(seed);
      outcomes.addAll(seen.outcomes);
      ends.add(seen.end);
    }
    expect(outcomes, {
      'notPlayed',
      'sinDisputa',
      'enPaso',
      'querido',
      'noQuerido',
      'ordagoQuerido',
    });
    expect(ends, MatchEnd.values.toSet());
  });

  for (final seed in _regressions) {
    test('regression: seed $seed', () => _simulate(seed));
  }

  test('a seat only sees its own cards', () {
    final match = MatchState.start(seed: 5);
    for (final seat in [0, 1, 2, 3]) {
      final view = SeatView.of(match, seat);
      expect(view.cards, match.hand.hands[seat]);
      expect(view.legal, match.legalMoves(seat));
      expect(view.log, match.hand.log);
    }
  });

  test('the random bot only chooses legal moves, including discards', () {
    final bot = RandomBot(Random(1));
    var match = MatchState.start(seed: 8, mano: 0);
    for (final seat in [0, 1, 2, 3]) {
      match = match.play(seat, const Mus());
    }
    for (var i = 0; i < 200; i++) {
      final move = bot.choose(SeatView.of(match, 0));
      expect(match.isLegal(0, move), isTrue, reason: '$move');
    }
  });
}
