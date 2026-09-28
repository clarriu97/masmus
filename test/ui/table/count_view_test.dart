import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/bots/bot.dart';
import 'package:masmus/bots/random_bot.dart';
import 'package:masmus/game/hand_state.dart';
import 'package:masmus/game/match.dart';
import 'package:masmus/ui/cards/playing_card_view.dart';
import 'package:masmus/ui/table/count_view.dart';

import '../../helpers/table.dart';
import '../../helpers/test_app.dart';

const _names = {
  0: 'Tú',
  1: 'El Prudente',
  2: 'El Calculador',
  3: 'La Temeraria',
};

Widget _count(MatchState match, {VoidCallback? onNext}) => buildTestApp(
  CountView(match: match, you: 0, names: _names, onNext: onNext ?? () {}),
);

void main() {
  testWidgets('the four hands face up, each with its owner', (tester) async {
    await tester.pumpWidget(_count(countMoments['count_juego']!().match));
    expect(find.text('Recuento'), findsOneWidget);
    final cards = tester.widgetList<PlayingCardView>(
      find.byType(PlayingCardView),
    );
    expect(cards.where((card) => card.faceUp), hasLength(16));
    for (final name in _names.values) {
      expect(find.text(name), findsOneWidget);
    }
  });

  testWidgets('S-7 lance by lance: who takes it, with what, why and how '
      'many tantos; the score before and after', (tester) async {
    await tester.pumpWidget(_count(countMoments['count_juego']!().match));
    expect(find.text('El Calculador, con R-C-7-6'), findsOneWidget);
    expect(find.text('La Temeraria, con 4-5-6-S'), findsOneWidget);
    expect(find.text('Nadie tenía pares'), findsOneWidget);
    expect(find.text('Tú, con 31'), findsOneWidget);
    expect(find.text('querido 2 · la 31 3 + juego 2'), findsOneWidget);
    expect(find.text('Nosotros +7'), findsOneWidget);
    expect(find.text('Nosotros 0 → 8'), findsOneWidget);
    expect(find.text('Ellos 0 → 1'), findsOneWidget);
  });

  testWidgets('a refused bet says its points were taken during the hand; '
      'a lance only one pair played is sin disputa', (tester) async {
    await tester.pumpWidget(_count(countMoments['count_pares']!().match));
    expect(
      find.textContaining('no quiero: 1 tanto ya contado'),
      findsOneWidget,
    );
    expect(find.textContaining('sin disputa'), findsOneWidget);
  });

  testWidgets('when the match is won in the count, the rest is not counted '
      'and the button goes to the end', (tester) async {
    var ended = false;
    await tester.pumpWidget(
      _count(countMoments['count_won']!().match, onNext: () => ended = true),
    );
    expect(find.text('¡Ganáis la partida!'), findsOneWidget);
    expect(
      find.text('no se cuenta: la partida ya estaba ganada'),
      findsNWidgets(2),
    );
    expect(find.text('Nosotros 38 → 40'), findsOneWidget);
    expect(
      find.text('El Prudente, con duples de reyes y caballos'),
      findsOneWidget,
    );
    await tester.tap(find.text('Ver el final'));
    expect(ended, isTrue);
  });

  testWidgets('«Siguiente mano» deals the next hand at the table', (
    tester,
  ) async {
    final controller = countMoments['count_juego']!();
    await tester.pumpWidget(buildTestApp(tableScreen(controller)));
    expect(find.byType(CountView), findsOneWidget);
    await tester.tap(find.text('Siguiente mano'));
    await tester.pump();
    expect(find.byType(CountView), findsNothing);
    expect(controller.match.hand.phase, isA<MusTurn>());
  });

  testWidgets('«Ver el reparto» adds up the 40 cards', (tester) async {
    await tester.pumpWidget(_count(countMoments['count_juego']!().match));
    await tester.ensureVisible(find.text('Ver el reparto'));
    await tester.tap(find.text('Ver el reparto'));
    await tester.pumpAndSettle();
    expect(
      find.text('Nadie ha descartado: se cortó el mus de entrada.'),
      findsOneWidget,
    );
    expect(
      find.text('16 en las manos + 0 descartadas + 24 en el mazo = 40'),
      findsOneWidget,
    );
  });

  testWidgets('what the count shows always adds up to the engine\'s total, '
      'over hands played by bots', (tester) async {
    for (var seed = 0; seed < 40; seed++) {
      final bots = [
        for (final seat in [0, 1, 2, 3]) RandomBot(Random(seed * 4 + seat)),
      ];
      var match = MatchState.start(seed: seed);
      while (match.hand.phase is! HandOver) {
        final seat = match.hand.turn!;
        match = match.play(seat, bots[seat].choose(SeatView.of(match, seat)));
      }
      await tester.pumpWidget(_count(match));
      final count = match.count!;
      final shown = [0, 0];
      for (final text in tester.widgetList<Text>(find.byType(Text))) {
        final points = RegExp(
          r'^(Nosotros|Ellos) \+(\d+)$',
        ).firstMatch(text.data ?? '');
        if (points != null) {
          shown[points[1] == 'Nosotros' ? 0 : 1] += int.parse(points[2]!);
        }
      }
      for (final team in [0, 1]) {
        expect(
          count.before[team] + shown[team],
          count.after[team],
          reason: 'seed $seed, team $team',
        );
        expect(
          find.textContaining('→ ${count.after[team]}'),
          findsWidgets,
          reason: 'seed $seed',
        );
      }
    }
  });
}
