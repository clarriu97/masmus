import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/game/hand_state.dart';
import 'package:masmus/game/move.dart';
import 'package:masmus/game/play.dart';
import 'package:masmus/game/rules.dart';
import 'package:masmus/game/senas.dart';

import 'scenario.dart';

const _filler = {1: '4 5 6 S', 2: '4 5 6 S', 3: '4 5 6 C'};

/// The señas seat 0 has made with [cards], after [moves].
List<Sena> _senas(
  String cards, {
  List<(int, Move)> moves = const [],
  bool musCorrido = false,
  Rules rules = const Rules(),
  Map<int, String> others = _filler,
}) {
  var hand = dealt({0: cards, ...others}, musCorrido: musCorrido, rules: rules);
  for (final (seat, move) in moves) {
    hand = play(hand, seat, move);
  }
  return senasOf(hand, 0);
}

void main() {
  group('R-SEN-1 · each hand makes its seña', () {
    for (final (cards, senas) in [
      ('R R 7 5', [Sena.dosReyes]),
      ('3 R 7 5', [Sena.dosReyes]),
      ('R R R 5', [Sena.mediasReyes]),
      ('1 1 7 5', [Sena.dosAses]),
      ('1 2 7 5', [Sena.dosAses]),
      ('1 1 1 5', [Sena.mediasAses]),
      ('R R 7 7', [Sena.duples]),
      ('R R R R', [Sena.duples]),
      ('R C 7 4', [Sena.treintaYUna]),
      ('7 6 5 4', [Sena.ciego]),
    ]) {
      test('$cards: $senas', () => expect(_senas(cards), senas));
    }

    test('with 4 reyes the treses and doses are just themselves', () {
      expect(_senas('3 R 7 5', rules: const Rules(kings: Kings.four)), [
        Sena.ciego,
      ]);
    });

    test('a juego other than la 31, or a par of anything but reyes or '
        'ases, makes none', () {
      expect(_senas('R C 7 5'), isEmpty);
      expect(_senas('7 7 5 4'), isEmpty);
    });
  });

  group('R-SEN-2 · true and complete', () {
    test('la 31 goes before the pares, and both are made', () {
      expect(_senas('R R 7 4'), [Sena.treintaYUna, Sena.dosReyes]);
    });

    test('with duples, the duples and never each pair', () {
      expect(_senas('R R 1 1'), [Sena.duples]);
    });
  });

  group('R-SEN-3 · when the cards are seen, never during mus corrido', () {
    test('at the deal of a normal hand, before anyone speaks', () {
      expect(_senas('R R 7 5'), [Sena.dosReyes]);
    });

    test('mus corrido: none while it goes round, all once it is cut', () {
      expect(_senas('R R 7 5', musCorrido: true), isEmpty);
      expect(
        _senas('R R 7 5', musCorrido: true, moves: [(0, const Mus())]),
        isEmpty,
      );
      expect(
        _senas(
          'R R 7 5',
          musCorrido: true,
          moves: [(0, const Mus()), (1, const NoHayMus())],
        ),
        [Sena.dosReyes],
      );
    });
  });

  group('R-SEN-4 · medias and treinta wait for their moment', () {
    test('medias of another card, once the grande has closed', () {
      final grande = [(0, const NoHayMus())];
      expect(_senas('7 7 7 5', moves: grande), isEmpty);
      expect(
        _senas(
          '7 7 7 5',
          moves: [
            ...grande,
            for (final seat in [0, 1, 2, 3]) (seat, const Paso()),
          ],
        ),
        [Sena.medias],
      );
    });

    test('treinta, once nobody has juego and the punto is played', () {
      const nobody = {1: '4 5 6 1', 2: '4 5 6 1', 3: '4 5 6 7'};
      expect(_senas('S C 6 4', others: nobody), isEmpty);
      final toPunto = [
        (0, const NoHayMus()),
        for (var i = 0; i < 8; i++) (i % 4, const Paso()),
      ];
      expect(_senas('S C 6 4', others: nobody, moves: toPunto), [Sena.treinta]);
    });
  });

  test('R-SEN-5 · a match without señas makes none', () {
    expect(_senas('R R 7 5', rules: const Rules(senas: false)), isEmpty);
    expect(const Rules().senas, isTrue);
    expect(
      Rules.fromJson(const {'kings': 'eight', 'target': 40}).senas,
      isTrue,
    );
  });

  test('a hand always makes the señas of what it holds, and only those', () {
    final hand = dealt(const {
      0: 'R R 7 5',
      1: '1 1 1 4',
      2: 'S S 7 7',
      3: '7 6 5 4',
    });
    expect(hand.phase, isA<MusTurn>());
    expect(senasOf(hand, 1), [Sena.mediasAses]);
    expect(senasOf(hand, 2), [Sena.duples]);
    expect(senasOf(hand, 3), [Sena.ciego]);
  });
}
