import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/game/event.dart';
import 'package:masmus/game/hand_value.dart';
import 'package:masmus/game/match.dart';
import 'package:masmus/game/move.dart';
import 'package:masmus/game/outcome.dart';
import 'package:masmus/game/rules.dart';
import 'package:masmus/ui/table/table_view.dart';

import '../../game/helpers.dart';
import '../../game/scenario.dart';

/// Seat 0 has pares and juego, seat 1 pares, seats 2 and 3 neither.
const _hands = {0: 'R R C 1', 1: 'S S 7 6', 2: '4 5 6 7', 3: '4 5 1 7'};

MatchState _match({
  Map<int, String> hands = _hands,
  int mano = 0,
  bool musCorrido = false,
  List<int> score = const [0, 0],
  List<(int, Move)> moves = const [],
}) {
  var match = MatchState(
    rules: const Rules(),
    score: score,
    handNumber: 1,
    hand: dealt(hands, mano: mano, musCorrido: musCorrido),
  );
  for (final (seat, move) in moves) {
    match = match.play(seat, move);
  }
  return match;
}

List<StepProgress> _states(TableView view) => [
  for (final step in view.steps) step.state,
];

void main() {
  test('the score, the mano and the postre are seen from your seat', () {
    final match = _match(mano: 1, score: const [5, 12]);
    final view = TableView.of(match, you: 0);
    expect((view.us, view.them), (5, 12));
    expect(view.mano, 1);
    expect(view.postre, 0);
    expect(view.target, 40);
    final rival = TableView.of(match, you: 1);
    expect((rival.us, rival.them), (12, 5));
  });

  test('at the deal the mus is being played and the rest waits', () {
    final view = TableView.of(_match(), you: 0);
    expect(_states(view), [
      StepProgress.current,
      StepProgress.pending,
      StepProgress.pending,
      StepProgress.pending,
      StepProgress.pending,
    ]);
    expect(view.steps.first.corrido, isFalse);
    expect(view.turn, 0);
    expect(view.yourTurn, isTrue);
    expect(view.said, isEmpty);
    expect(view.stake, isNull);
  });

  test('the first hand says the mus is corrido', () {
    final view = TableView.of(_match(musCorrido: true), you: 0);
    expect(view.steps.first.corrido, isTrue);
  });

  test('cutting the mus opens the grande, and what was said stays until '
      'someone speaks in it', () {
    final cut = TableView.of(_match(moves: [(0, const NoHayMus())]), you: 0);
    expect(cut.steps.first.state, StepProgress.done);
    expect(cut.steps.first.cut, isTrue);
    expect(cut.steps[1].state, StepProgress.current);
    expect(cut.said, {0: const NoHayMusSaid(0)});

    final paso = TableView.of(
      _match(moves: [(0, const NoHayMus()), (0, const Paso())]),
      you: 0,
    );
    expect(paso.said, {0: const PasoSaid(0)});
  });

  test('a bet shows on the table and in the row until it is answered', () {
    final view = TableView.of(
      _match(moves: [(0, const NoHayMus()), (0, const Envido(2))]),
      you: 0,
    );
    expect(view.stake?.stake, 2);
    expect(view.steps[1].envite?.stake, 2);
    expect(view.said[0], isA<EnvidoSaid>());
    expect(view.turn, 1);
  });

  test('a lance over keeps how it went; its last words stay in view', () {
    final view = TableView.of(
      _match(
        moves: [
          (0, const NoHayMus()),
          (0, const Envido(2)),
          (1, const NoQuiero()),
          (3, const NoQuiero()),
        ],
      ),
      you: 0,
    );
    expect(view.steps[1].state, StepProgress.done);
    expect(
      view.steps[1].outcome,
      isA<NoQuerido>()
          .having((o) => o.team, 'team', 0)
          .having((o) => o.points, 'points', 1),
    );
    expect(view.steps[2].state, StepProgress.current);
    expect(view.stake, isNull);
    expect(view.said.keys, unorderedEquals([0, 1, 3]));
    expect(view.said[3], isA<NoQuieroSaid>());
  });

  test('declarations of pares show on every seat', () {
    final view = TableView.of(
      _match(
        moves: [
          (0, const NoHayMus()),
          for (final seat in [0, 1, 2, 3, 0, 1, 2, 3]) (seat, const Paso()),
        ],
      ),
      you: 0,
    );
    expect(view.steps[3].state, StepProgress.current);
    expect(view.said, {
      0: const Declared(0, lance: Lance.pares, has: true),
      1: const Declared(1, lance: Lance.pares, has: true),
      2: const Declared(2, lance: Lance.pares, has: false),
      3: const Declared(3, lance: Lance.pares, has: false),
    });
  });

  test('without juego the last step is the punto', () {
    final view = TableView.of(
      _match(
        hands: const {0: 'R 6 5 4', 1: 'S 7 6 1', 2: '4 5 6 7', 3: '4 5 1 7'},
        moves: [
          (0, const NoHayMus()),
          for (final seat in [0, 1, 2, 3, 0, 1, 2, 3]) (seat, const Paso()),
        ],
      ),
      you: 0,
    );
    expect(view.steps.last.step, TableStep.punto);
    expect(view.steps.last.state, StepProgress.current);
    expect(view.steps[3].outcome, isA<NotPlayed>());
  });

  test('in the discards everyone first still shows "mus", then what they '
      'asked for', () {
    final all = [
      for (final seat in [0, 1, 2, 3]) (seat, const Mus()),
    ];
    final discarding = TableView.of(_match(moves: all), you: 0);
    expect(discarding.steps.first.discarding, isTrue);
    expect(discarding.said.values, everyElement(isA<MusSaid>()));

    final asked = TableView.of(
      _match(moves: [...all, (0, Discard(cards('Rc 1o')))]),
      you: 0,
    );
    expect(asked.said, {0: const Discarded(0, count: 2)});
    expect(asked.asked, {0: 2});
  });

  test('your hand and what it is worth', () {
    final view = TableView.of(_match(), you: 0);
    expect(view.cards, hand('R R C 1'));
    expect(view.value.pares, ParesKind.par);
    expect(view.value.points, 31);
    expect(view.partnerOf(2), isTrue);
    expect(view.partnerOf(1), isFalse);
    expect(view.partnerOf(0), isFalse);
  });

  group('while the table catches up with a move', () {
    final match = _match(
      moves: [
        (0, const NoHayMus()),
        for (final seat in [0, 1, 2, 3, 0, 1, 2, 3]) (seat, const Paso()),
      ],
    );
    final log = match.hand.log;
    final closed = log.indexWhere(
      (event) => event is LanceClosed && event.outcome.lance == Lance.chica,
    );
    TableView at(int shown) => TableView.of(match, you: 0, shown: shown);

    test(
      'the last paso shows alone, in the chica, and nobody has the turn',
      () {
        final view = at(closed);
        expect(view.steps[2].state, StepProgress.current);
        expect(view.said[3], const PasoSaid(3));
        expect(view.turn, isNull);
        expect(view.yourTurn, isFalse);
      },
    );

    test('then the chica closes, en paso, with its words still in view', () {
      final view = at(closed + 1);
      expect(view.steps[2].outcome, isA<EnPaso>());
      expect(view.steps[3].state, StepProgress.pending);
      expect(view.said.values, everyElement(isA<PasoSaid>()));
    });

    test('then each player says whether they have pares, one after another, '
        'in a new step', () {
      for (var i = 1; i <= 4; i++) {
        final view = at(closed + 1 + i);
        expect(view.steps[3].state, StepProgress.current);
        expect(view.said, hasLength(i));
        expect(view.said.values, everyElement(isA<Declared>()));
      }
      expect(at(closed + 5).said, TableView.of(match, you: 0).said);
    });

    test('once all is shown it is your turn again', () {
      expect(at(log.length).turn, 0);
      expect(TableView.of(match, you: 0).turn, 0);
    });
  });

  test('nobody with pares: they still say so one by one before the juego', () {
    final match = _match(
      hands: const {0: 'R 6 5 4', 1: 'S 7 6 1', 2: '4 5 6 7', 3: '4 5 1 7'},
      moves: [
        (0, const NoHayMus()),
        for (final seat in [0, 1, 2, 3, 0, 1, 2, 3]) (seat, const Paso()),
      ],
    );
    final log = match.hand.log;
    final first = log.indexWhere((event) => event is Declared);
    final second = TableView.of(match, you: 0, shown: first + 2);
    expect(second.said, {
      0: const Declared(0, lance: Lance.pares, has: false),
      1: const Declared(1, lance: Lance.pares, has: false),
    });
    expect(second.steps[3].state, StepProgress.current);
    final beforePunto = log.indexWhere(
      (event) => event is LanceStarted && event.lance == Lance.punto,
    );
    final declaringJuego = TableView.of(match, you: 0, shown: beforePunto);
    expect(declaringJuego.steps.last.step, TableStep.juego);
    expect(declaringJuego.steps.last.state, StepProgress.current);
    expect(declaringJuego.said.values.last, isA<Declared>());
  });

  test('the points of a «no quiero» count once its close is shown', () {
    final match = _match(
      moves: [
        (0, const NoHayMus()),
        (0, const Envido(2)),
        (1, const NoQuiero()),
        (3, const NoQuiero()),
      ],
    );
    final noQuiero = match.hand.log.indexWhere(
      (event) => event is NoQuieroSaid && event.seat == 3,
    );
    final said = TableView.of(match, you: 0, shown: noQuiero + 1);
    expect(said.us, 0);
    expect(said.bet?.stake, 2);
    expect(said.stake, isNull, reason: 'nothing to answer while showing');
    expect(TableView.of(match, you: 0, shown: noQuiero + 2).us, 1);
  });

  test('during mus corrido the mano moves only when the table shows it', () {
    final match = _match(
      musCorrido: true,
      moves: [(0, const Mus()), (1, const NoHayMus())],
    );
    final moved = match.hand.log.indexWhere((event) => event is ManoMoved);
    expect(TableView.of(match, you: 0, shown: moved).mano, 0);
    expect(TableView.of(match, you: 0, shown: moved + 1).mano, 1);
    expect(TableView.of(match, you: 0).mano, 1);
  });
}
