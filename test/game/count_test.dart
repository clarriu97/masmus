import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/game/count.dart';
import 'package:masmus/game/hand_state.dart';
import 'package:masmus/game/hand_value.dart';
import 'package:masmus/game/move.dart';
import 'package:masmus/game/outcome.dart';
import 'package:masmus/game/table.dart';

import 'scenario.dart';

/// Nobody has pares; juego for seats 0 (31), 1 (32) and 2 (33).
const _juegos = {0: 'R C 7 4', 1: 'R C 7 5', 2: 'R C 7 6', 3: 'S 6 5 4'};

/// Seat 0 par, seat 2 medias, seat 1 duples and juego (40), seat 3 nothing.
const _pares = {0: 'R R 5 4', 1: 'C C S S', 2: '7 7 7 1', 3: '6 5 4 1'};

/// Only seats 0 (medias) and 2 (par) have pares; nobody has juego.
const _paresSinDisputa = {
  0: '7 7 7 1',
  1: 'C 6 5 4',
  2: 'R R 5 4',
  3: 'S 6 5 1',
};

/// Seats 0 and 1 tie at grande; seats 2 and 3 are worse.
const _tiedGrande = {0: 'R R 7 1', 1: 'R R 7 1', 2: 'C 5 4 1', 3: 'S 6 5 4'};

/// Seat 1 has the best grande, duples and juego (40); seat 3 juego (37);
/// seat 0 the best chica.
const _chicaForA = {0: '1 4 5 6', 1: 'R R C C', 2: '1 5 6 7', 3: 'R C S 7'};

List<(int, Move)> _everyonePasses(int mano) => [
  for (final seat in speakingOrder(mano)) (seat, paso),
];

/// Plays [moves] after cutting the mus, then passes in every lance left.
HandState _hand(
  Map<int, String> hands,
  List<(int, Move)> moves, {
  int mano = 0,
}) {
  var state = run(dealt(hands, mano: mano), [(mano, noHayMus), ...moves]);
  while (state.phase is! HandOver) {
    state = run(state, [(state.turn!, paso)]);
  }
  return state;
}

void main() {
  test('a whole count, lance by lance (S-7 in juego)', () {
    final hand = _hand(_juegos, [
      ..._everyonePasses(0),
      ..._everyonePasses(0),
      (0, envido(2)),
      (1, quiero),
    ]);
    final count = countHand(hand, const [0, 0], 40);
    final [grande, chica, pares, juego] = count.lances;

    expect(grande.outcome, const EnPaso(Lance.grande));
    expect((grande.team, grande.seat, grande.points), (0, 2, 1));

    expect(chica.outcome, const EnPaso(Lance.chica));
    expect((chica.team, chica.seat, chica.points), (1, 3, 1));

    expect(pares.outcome, const NotPlayed(Lance.pares));
    expect((pares.team, pares.points), (null, 0));

    expect(juego.outcome, const Querido(Lance.juego, stake: 2));
    expect((juego.team, juego.seat), (0, 0));
    expect((juego.stake, juego.combinations, juego.points), (2, 5, 7));

    expect(count.after, [8, 1]);
    expect(count.winner, isNull);
  });

  group('R-REC-2 · grande and chica', () {
    test('S-1 · en paso: 1 point for the best hand', () {
      final hand = _hand(_juegos, []);
      final grande = countHand(hand, const [0, 0], 40).lances.first;
      expect((grande.team, grande.stake, grande.points), (0, 1, 1));
    });

    test('S-2 · querido: the stake for the best hand', () {
      final hand = _hand(_juegos, [(0, envido(2)), (1, quiero)]);
      final grande = countHand(hand, const [0, 0], 40).lances.first;
      expect(grande.outcome, const Querido(Lance.grande, stake: 2));
      expect((grande.team, grande.seat, grande.points), (0, 2, 2));
    });

    test('no querido: nothing more at the count, it was paid at once', () {
      final hand = _hand(_juegos, [
        (0, envido(2)),
        (1, noQuiero),
        (3, noQuiero),
      ]);
      final count = countHand(hand, const [1, 0], 40);
      final grande = count.lances.first;
      expect((grande.team, grande.seat), (0, null));
      expect((grande.paidAtOnce, grande.points), (1, 0));
      expect(count.before, [1, 0]);
    });
  });

  group('R-REC-3 · pares', () {
    test('S-5 · refused: the pair that bet takes its own pares, though the '
        'rivals had better ones', () {
      final hand = _hand(_pares, [
        ..._everyonePasses(0),
        ..._everyonePasses(0),
        (0, envido(2)),
        (1, noQuiero),
      ]);
      expect(hand.pointsNow, [1, 0]);
      final count = countHand(hand, const [1, 0], 40);
      final pares = count.lances[2];
      expect(pares.outcome, const NoQuerido(Lance.pares, team: 0, points: 1));
      expect((pares.team, pares.seat), (0, 2));
      expect((pares.paidAtOnce, pares.combinations, pares.points), (1, 3, 3));
      final juego = count.lances[3];
      expect(juego.outcome, const SinDisputa(Lance.juego, team: 1));
      expect((juego.team, juego.seat, juego.points), (1, 1, 2));
      expect(count.after, [5, 3]);
    });

    test('S-6 · sin disputa: the only pair with pares takes them all', () {
      final hand = _hand(_paresSinDisputa, []);
      final pares = countHand(hand, const [0, 0], 40).lances[2];
      expect(pares.outcome, const SinDisputa(Lance.pares, team: 0));
      expect((pares.team, pares.seat, pares.points), (0, 0, 3));
    });

    test('querido: the stake and the pares of the best pair', () {
      final hand = _hand(_pares, [
        ..._everyonePasses(0),
        ..._everyonePasses(0),
        (0, envido(2)),
        (1, quiero),
      ]);
      final pares = countHand(hand, const [0, 0], 40).lances[2];
      expect((pares.team, pares.seat), (1, 1));
      expect((pares.stake, pares.combinations, pares.points), (2, 3, 5));
    });
  });

  group('R-REC-5 · punto', () {
    test('S-8 · en paso: 1', () {
      final punto = countHand(_hand(_paresSinDisputa, []), const [
        0,
        0,
      ], 40).lances.last;
      expect(punto.outcome, const EnPaso(Lance.punto));
      expect((punto.team, punto.seat, punto.points), (0, 2, 1));
    });

    test('S-8 · querido: the stake plus 1', () {
      final hand = _hand(_paresSinDisputa, [
        ..._everyonePasses(0),
        ..._everyonePasses(0),
        (0, envido(2)),
        (1, quiero),
      ]);
      final punto = countHand(hand, const [0, 0], 40).lances.last;
      expect(punto.outcome, const Querido(Lance.punto, stake: 2));
      expect((punto.team, punto.points), (0, 3));
    });

    test('no querido: 1 at the count for the pair that bet', () {
      final hand = _hand(_paresSinDisputa, [
        ..._everyonePasses(0),
        ..._everyonePasses(0),
        (0, envido(2)),
        (1, noQuiero),
        (3, noQuiero),
      ]);
      final punto = countHand(hand, const [1, 0], 40).lances.last;
      expect((punto.team, punto.paidAtOnce, punto.points), (0, 1, 1));
    });
  });

  test('R-LAN-7 · a tie goes to the player who speaks first', () {
    final withMano0 = countHand(_hand(_tiedGrande, []), const [
      0,
      0,
    ], 40).lances.first;
    expect((withMano0.team, withMano0.seat), (0, 0));

    final withMano1 = countHand(_hand(_tiedGrande, [], mano: 1), const [
      0,
      0,
    ], 40).lances.first;
    expect((withMano1.team, withMano1.seat), (1, 1));
  });

  test('R-REC-6 · S-10: the first pair to reach 40 wins, later lances are '
      'not counted', () {
    final hand = _hand(_chicaForA, [
      ..._everyonePasses(0),
      (0, envido(2)),
      (1, quiero),
    ]);
    final count = countHand(hand, const [38, 36], 40);
    final [grande, chica, pares, juego] = count.lances;
    expect((grande.team, grande.points, grande.counted), (1, 1, true));
    expect((chica.team, chica.points, chica.counted), (0, 2, true));
    expect(pares.outcome, const SinDisputa(Lance.pares, team: 1));
    expect((pares.counted, pares.points), (false, 0));
    expect((juego.counted, juego.points), (false, 0));
    expect(count.after, [40, 37]);
    expect(count.winner, 0);
  });

  test('R-FIN-1 · the target can be 30', () {
    final hand = _hand(_juegos, [
      ..._everyonePasses(0),
      ..._everyonePasses(0),
      (0, envido(2)),
      (1, quiero),
    ]);
    expect(countHand(hand, const [22, 25], 40).winner, isNull);
    final to30 = countHand(hand, const [22, 25], 30);
    expect(to30.after, [30, 26]);
    expect(to30.winner, 0);
  });

  test('R-FIN-3 · an accepted órdago decides on its own; the other lances '
      'are not counted', () {
    final hand = _hand(_juegos, [
      (0, envido(2)),
      (1, quiero),
      (0, ordago),
      (1, quiero),
    ]);
    final count = countHand(hand, const [10, 10], 40);
    final [grande, chica] = count.lances;
    expect(grande.counted, isFalse);
    expect(chica.outcome, const OrdagoQuerido(Lance.chica));
    expect((chica.team, chica.seat, chica.counted), (1, 3, true));
    expect(count.winner, 1);
    expect(count.after, [10, 10]);
  });
}
