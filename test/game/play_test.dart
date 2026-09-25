import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/game/cards.dart';
import 'package:masmus/game/event.dart';
import 'package:masmus/game/hand_state.dart';
import 'package:masmus/game/hand_value.dart';
import 'package:masmus/game/move.dart';
import 'package:masmus/game/outcome.dart';
import 'package:masmus/game/play.dart';

import 'helpers.dart';
import 'scenario.dart';

/// Seats 0 and 1 have pares, only seat 1 has juego (34).
const _someParesOneJuego = {
  0: 'R R 7 1',
  1: 'C C S 4',
  2: '5 4 6 7',
  3: 'S 7 6 1',
};

/// Only the pair of seats 0 and 2 has pares; nobody has juego.
const _oneParesNoJuego = {
  0: 'R R 7 1',
  1: '5 4 6 7',
  2: 'C C 5 4',
  3: 'S 7 6 1',
};

/// Nobody has pares; only seat 3 has juego.
const _noPares = {0: 'R C 7 1', 1: 'S 6 5 4', 2: '7 6 5 1', 3: 'R C S 4'};

Matcher _lanceTurn(Lance lance, {required int seat}) => isA<LanceTurn>()
    .having((p) => p.lance, 'lance', lance)
    .having((p) => p.seat, 'seat', seat);

/// Cuts the mus at once: the grande starts.
HandState _grande(Map<int, String> hands, {int mano = 0}) =>
    run(dealt(hands, mano: mano), [(mano, noHayMus)]);

void main() {
  group('R-MUS-2 · mus', () {
    test('goes round from the mano; one "no hay mus" starts the grande, '
        'with the mano speaking first', () {
      final start = dealt(_someParesOneJuego, mano: 1);
      expect(start.turn, 1);
      expect(legalMoves(start, 1), {MoveKind.mus, MoveKind.noHayMus});
      for (final seat in [0, 2, 3]) {
        expect(legalMoves(start, seat), isEmpty);
      }
      final state = run(start, [(1, mus), (2, mus), (3, noHayMus)]);
      expect(state.phase, _lanceTurn(Lance.grande, seat: 1));
      expect(state.log, const [
        MusSaid(1),
        MusSaid(2),
        NoHayMusSaid(3),
        LanceStarted(Lance.grande, seats: [1, 2, 3, 0]),
      ]);
    });

    test('four "mus" lead to the discard, starting with the mano', () {
      final state = run(dealt(_someParesOneJuego, mano: 2), [
        (2, mus),
        (3, mus),
        (0, mus),
        (1, mus),
      ]);
      expect(state.phase, isA<DiscardTurn>().having((p) => p.seat, 'seat', 2));
      expect(legalMoves(state, 2), {MoveKind.discard});
    });

    test('a move out of turn is refused', () {
      final start = dealt(_someParesOneJuego);
      expect(isLegal(start, 1, mus), isFalse);
      expect(() => play(start, 1, mus), throwsStateError);
    });
  });

  group('R-MUS-3 · discards', () {
    HandState allSayMus() => run(dealt(_someParesOneJuego), [
      (0, mus),
      (1, mus),
      (2, mus),
      (3, mus),
    ]);

    test('everyone picks 1 to 4 of their cards, then all are served from the '
        'top of the stock in speaking order and mus is spoken again', () {
      final before = allSayMus();
      final stock = before.stock;
      final state = run(before, [
        (0, discard('7o 1o')),
        (1, discard('4o')),
        (2, discard('5o 4c 6o 7c')),
        (3, discard('Sc 7e 6c')),
      ]);
      expect(state.hands[0], [...cards('Ro Rc'), ...stock.sublist(0, 2)]);
      expect(state.hands[1], [...cards('Co Cc So'), stock[2]]);
      expect(state.hands[2], stock.sublist(3, 7));
      expect(state.hands[3], [...cards('1c'), ...stock.sublist(7, 10)]);
      expect(state.stock, stock.sublist(10));
      expect(state.discards, cards('7o 1o 4o 5o 4c 6o 7c Sc 7e 6c'));
      expect(state.phase, isA<MusTurn>().having((p) => p.seat, 'seat', 0));
      expect(state.mano, 0);
      expect(since(before, state), const [
        Discarded(0, count: 2),
        Discarded(1, count: 1),
        Discarded(2, count: 4),
        Discarded(3, count: 3),
      ]);
    });

    test('an empty, repeated or foreign discard is illegal', () {
      final state = allSayMus();
      expect(isLegal(state, 0, const Discard([])), isFalse);
      expect(isLegal(state, 0, discard('Ro Ro')), isFalse);
      expect(isLegal(state, 0, discard('Co')), isFalse);
      expect(isLegal(state, 0, discard('Ro Rc 7o 1o')), isTrue);
      expect(() => play(state, 0, discard('Co')), throwsStateError);
    });
  });

  test('R-MUS-4 · when the stock runs out, the discards are shuffled into a '
      'new one and no card is lost or repeated', () {
    var state = dealt(_someParesOneJuego);
    for (var round = 0; round < 2; round++) {
      state = run(state, [(0, mus), (1, mus), (2, mus), (3, mus)]);
      for (final seat in [0, 1, 2, 3]) {
        state = run(state, [(seat, Discard(state.hands[seat]))]);
      }
    }
    expect(state.log.whereType<Reshuffled>(), hasLength(1));
    final everything = [
      ...state.hands.expand((hand) => hand),
      ...state.stock,
      ...state.discards,
    ];
    expect(everything, hasLength(40));
    expect(everything.toSet(), spanishDeck.toSet());
    expect(state.stock, hasLength(24));
    expect(state.discards, isEmpty);
  });

  group('R-MUS-5 · mus corrido', () {
    HandState afterTwoRounds({required bool musCorrido}) {
      var state = dealt(_someParesOneJuego, musCorrido: musCorrido);
      for (var round = 0; round < 2; round++) {
        final order = [for (var i = 0; i < 4; i++) (state.mano + i) % 4];
        state = run(state, [for (final seat in order) (seat, mus)]);
        state = run(state, [
          for (final seat in order) (seat, Discard([state.hands[seat].last])),
        ]);
      }
      return state;
    }

    test('S-12 · the mano moves on after every round of mus, and whoever '
        'cuts it becomes mano', () {
      final before = afterTwoRounds(musCorrido: true);
      expect(before.mano, 2);
      expect(before.log.whereType<ManoMoved>(), const [
        ManoMoved(1),
        ManoMoved(2),
      ]);
      final state = run(before, [(2, mus), (3, mus), (0, mus), (1, noHayMus)]);
      expect(state.mano, 1);
      expect(state.phase, _lanceTurn(Lance.grande, seat: 1));
      expect(
        state.log.last,
        const LanceStarted(Lance.grande, seats: [1, 2, 3, 0]),
      );
    });

    test('without it the mano stays and the lances start with it', () {
      final before = afterTwoRounds(musCorrido: false);
      expect(before.mano, 0);
      expect(before.log.whereType<ManoMoved>(), isEmpty);
      final state = run(before, [(0, mus), (1, mus), (2, mus), (3, noHayMus)]);
      expect(state.mano, 0);
      expect(state.phase, _lanceTurn(Lance.grande, seat: 0));
    });
  });

  group('declarations', () {
    test('R-DEC-1 · everyone declares pares from the mano and only those '
        'with pares speak; R-DEC-3 · juego only one pair has goes unbet', () {
      final before = run(_grande(_someParesOneJuego), [
        for (final seat in [0, 1, 2, 3]) (seat, paso),
        for (final seat in [0, 1, 2, 3]) (seat, paso),
      ]);
      expect(before.phase, _lanceTurn(Lance.pares, seat: 0));
      expect(
        before.phase,
        isA<LanceTurn>().having((p) => p.eligible, 'eligible', [0, 1]),
      );
      expect(before.log.reversed.take(6).toList().reversed, const [
        LanceClosed(EnPaso(Lance.chica)),
        Declared(0, lance: Lance.pares, has: true),
        Declared(1, lance: Lance.pares, has: true),
        Declared(2, lance: Lance.pares, has: false),
        Declared(3, lance: Lance.pares, has: false),
        LanceStarted(Lance.pares, seats: [0, 1]),
      ]);
      expect(legalMoves(before, 2), isEmpty);

      final state = run(before, [(0, paso), (1, paso)]);
      expect(since(before, state), const [
        PasoSaid(0),
        PasoSaid(1),
        LanceClosed(EnPaso(Lance.pares)),
        Declared(0, lance: Lance.juego, has: false),
        Declared(1, lance: Lance.juego, has: true),
        Declared(2, lance: Lance.juego, has: false),
        Declared(3, lance: Lance.juego, has: false),
        LanceClosed(SinDisputa(Lance.juego, team: 1)),
        HandEnded(),
      ]);
      expect(state.phase, isA<HandOver>());
    });

    test('R-DEC-2 · pares only one pair has are not bet on (sin disputa); '
        'R-DEC-3 · nobody with juego: punto, for all four', () {
      final state = run(_grande(_oneParesNoJuego), [
        for (final seat in [0, 1, 2, 3]) (seat, paso),
        for (final seat in [0, 1, 2, 3]) (seat, paso),
      ]);
      expect(state.outcomes, const [
        EnPaso(Lance.grande),
        EnPaso(Lance.chica),
        SinDisputa(Lance.pares, team: 0),
      ]);
      expect(state.phase, _lanceTurn(Lance.punto, seat: 0));
      expect(
        state.log.last,
        const LanceStarted(Lance.punto, seats: [0, 1, 2, 3]),
      );
    });

    test('R-DEC-2 · nobody with pares: no lance', () {
      final state = run(_grande(_noPares), [
        for (final seat in [0, 1, 2, 3]) (seat, paso),
        for (final seat in [0, 1, 2, 3]) (seat, paso),
      ]);
      expect(state.outcomes, const [
        EnPaso(Lance.grande),
        EnPaso(Lance.chica),
        NotPlayed(Lance.pares),
        SinDisputa(Lance.juego, team: 1),
      ]);
      expect(state.phase, isA<HandOver>());
    });
  });

  group('envites', () {
    test(
      'R-ENV-1 · before any envite: paso, envido of 2 or more, or órdago',
      () {
        final state = _grande(_someParesOneJuego);
        expect(legalMoves(state, 0), {
          MoveKind.paso,
          MoveKind.envido,
          MoveKind.ordago,
        });
        expect(() => Envido(1), throwsA(isA<AssertionError>()));
        expect(isLegal(state, 0, envido(2)), isTrue);
        expect(isLegal(state, 0, envido(30)), isTrue);
      },
    );

    test('R-ENV-2 · when everybody passes the lance is en paso', () {
      final before = _grande(_someParesOneJuego);
      final state = run(before, [
        for (final seat in [0, 1, 2, 3]) (seat, paso),
      ]);
      expect(state.outcomes, const [EnPaso(Lance.grande)]);
      expect(state.phase, _lanceTurn(Lance.chica, seat: 0));
    });

    test('R-ENV-2 · in pares the lance closes after the last player who can '
        'speak, even when the postre cannot', () {
      final before = run(_grande(_someParesOneJuego), [
        for (final seat in [0, 1, 2, 3]) (seat, paso),
        for (final seat in [0, 1, 2, 3]) (seat, paso),
      ]);
      final state = run(before, [(0, paso), (1, paso)]);
      expect(state.outcomes, contains(const EnPaso(Lance.pares)));
      expect(state.phase, isA<HandOver>());
    });

    test('R-ENV-3 · the first rival after the bettor answers; when they '
        'decline, their partner decides; one quiero is enough', () {
      final before = run(_grande(_someParesOneJuego), [
        (0, paso),
        (1, envido(2)),
      ]);
      expect(before.phase, _lanceTurn(Lance.grande, seat: 2));
      expect(legalMoves(before, 2), {
        MoveKind.quiero,
        MoveKind.noQuiero,
        MoveKind.envido,
        MoveKind.ordago,
      });
      final state = run(before, [(2, noQuiero), (0, quiero)]);
      expect(since(before, state).take(3), const [
        NoQuieroSaid(2, partnerDecides: true),
        QuieroSaid(0),
        LanceClosed(Querido(Lance.grande, stake: 2)),
      ]);
      expect(state.phase, _lanceTurn(Lance.chica, seat: 0));
    });

    test('R-ENV-3 · the first quiero closes it', () {
      final state = run(_grande(_someParesOneJuego), [
        (0, envido(2)),
        (1, quiero),
      ]);
      expect(state.outcomes, const [Querido(Lance.grande, stake: 2)]);
    });

    test('R-ENV-3 · a partner who cannot play the lance does not answer', () {
      final before = run(_grande(_someParesOneJuego), [
        for (final seat in [0, 1, 2, 3]) (seat, paso),
        for (final seat in [0, 1, 2, 3]) (seat, paso),
      ]);
      final state = run(before, [(0, envido(2)), (1, noQuiero)]);
      expect(since(before, state).take(3), const [
        EnvidoSaid(0, amount: 2, stake: 2),
        NoQuieroSaid(1, partnerDecides: false),
        LanceClosed(NoQuerido(Lance.pares, team: 0, points: 1)),
      ]);
    });

    test('R-ENV-3 · having passed does not stop a player from answering', () {
      final state = run(_grande(_someParesOneJuego), [
        (0, paso),
        (1, paso),
        (2, paso),
        (3, envido(2)),
      ]);
      expect(state.phase, _lanceTurn(Lance.grande, seat: 0));
      expect((state.phase as LanceTurn).envite?.responders, [0, 2]);
    });

    test('R-ENV-4 · a raise is answered by the pair that bet', () {
      final state = run(_grande(_someParesOneJuego), [
        (0, envido(2)),
        (1, envido(5)),
      ]);
      expect(state.log.last, const EnvidoSaid(1, amount: 5, stake: 7));
      expect(state.phase, _lanceTurn(Lance.grande, seat: 2));
      final envite = (state.phase as LanceTurn).envite!;
      expect(envite.responders, [2, 0]);
      expect(envite.stake, 7);
      expect(envite.accepted, 2);
    });

    test('R-ENV-5 · quiero closes the lance with what is on the table', () {
      final state = run(_grande(_someParesOneJuego), [
        (0, envido(2)),
        (1, envido(5)),
        (2, quiero),
      ]);
      expect(state.outcomes, const [Querido(Lance.grande, stake: 7)]);
      expect(state.pointsNow, [0, 0]);
    });

    test('R-ENV-6 · S-3: envido 2, 5 más, no quiero pays 2 at once', () {
      final state = run(_grande(_someParesOneJuego), [
        (0, envido(2)),
        (1, envido(5)),
        (2, noQuiero),
        (0, noQuiero),
      ]);
      expect(state.outcomes, const [
        NoQuerido(Lance.grande, team: 1, points: 2),
      ]);
      expect(state.pointsNow, [0, 2]);
    });

    test('R-ENV-6 · S-4: envido 2, 5 más, 10 más, no quiero pays 7', () {
      final state = run(_grande(_someParesOneJuego), [
        (0, envido(2)),
        (1, envido(5)),
        (2, envido(10)),
        (3, noQuiero),
        (1, noQuiero),
      ]);
      expect(state.outcomes, const [
        NoQuerido(Lance.grande, team: 0, points: 7),
      ]);
      expect(state.pointsNow, [7, 0]);
    });

    test('R-ENV-6 · a first envite refused pays 1', () {
      final state = run(_grande(_someParesOneJuego), [
        (0, envido(2)),
        (1, noQuiero),
        (3, noQuiero),
      ]);
      expect(state.outcomes, const [
        NoQuerido(Lance.grande, team: 0, points: 1),
      ]);
    });

    test('R-ENV-7 · an órdago cannot be raised, and accepting it ends the '
        'hand at once', () {
      final before = run(_grande(_someParesOneJuego), [(0, ordago)]);
      expect(legalMoves(before, 1), {MoveKind.quiero, MoveKind.noQuiero});
      final state = run(before, [(1, quiero)]);
      expect(state.outcomes, const [OrdagoQuerido(Lance.grande)]);
      expect(state.phase, isA<HandOver>());
      expect(since(before, state), const [
        QuieroSaid(1),
        LanceClosed(OrdagoQuerido(Lance.grande)),
        HandEnded(),
      ]);
    });

    test('R-ENV-7 · an órdago refused pays what was on the table before it, '
        'or 1', () {
      final afterEnvite = run(_grande(_someParesOneJuego), [
        (0, envido(2)),
        (1, ordago),
        (2, noQuiero),
        (0, noQuiero),
      ]);
      expect(afterEnvite.outcomes, const [
        NoQuerido(Lance.grande, team: 1, points: 2),
      ]);
      final alone = run(_grande(_someParesOneJuego), [
        (0, ordago),
        (1, noQuiero),
        (3, noQuiero),
      ]);
      expect(alone.outcomes, const [
        NoQuerido(Lance.grande, team: 0, points: 1),
      ]);
    });

    test('R-ENV-8 · a closed lance never reopens, and nobody moves once the '
        'hand is over', () {
      final state = run(_grande(_someParesOneJuego), [
        (0, envido(2)),
        (1, quiero),
        for (final seat in [0, 1, 2, 3]) (seat, paso),
        (0, paso),
        (1, paso),
      ]);
      expect(state.outcomes.map((o) => o.lance), [
        Lance.grande,
        Lance.chica,
        Lance.pares,
        Lance.juego,
      ]);
      expect(state.phase, isA<HandOver>());
      expect(state.turn, isNull);
      for (final seat in [0, 1, 2, 3]) {
        expect(legalMoves(state, seat), isEmpty);
      }
    });
  });

  test('a whole hand: grande, chica, pares and juego, in order', () {
    final start = dealt(_someParesOneJuego);
    final state = run(start, [
      (0, noHayMus),
      (0, envido(2)),
      (1, quiero),
      for (final seat in [0, 1, 2, 3]) (seat, paso),
      (0, envido(2)),
      (1, envido(3)),
      (0, quiero),
    ]);
    expect(state.outcomes, const [
      Querido(Lance.grande, stake: 2),
      EnPaso(Lance.chica),
      Querido(Lance.pares, stake: 5),
      SinDisputa(Lance.juego, team: 1),
    ]);
    expect(state.log.first, const NoHayMusSaid(0));
    expect(state.log.last, const HandEnded());
    expect(state.pointsNow, [0, 0]);
  });
}
