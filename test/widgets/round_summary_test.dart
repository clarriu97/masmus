import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/core/theme/app_text_styles.dart';
import 'package:masmus/game/count.dart';
import 'package:masmus/game/hand_state.dart';
import 'package:masmus/widgets/round_summary.dart';

import '../game/scenario.dart';

const _names = ['Tú', 'El Prudente', 'El Calculador', 'La Temeraria'];

/// Nobody has pares; juego for seats 0 (31), 1 (32) and 2 (33).
HandState _hand() {
  var state = run(
    dealt({0: 'R C 7 4', 1: 'R C 7 5', 2: 'R C 7 6', 3: 'S 6 5 4'}),
    [(0, noHayMus), (0, envido(2)), (1, quiero)],
  );
  while (state.phase is! HandOver) {
    state = run(state, [(state.turn!, paso)]);
  }
  return state;
}

Future<void> _pump(
  WidgetTester tester, {
  required HandCount? count,
  int? winner,
  VoidCallback? onContinue,
}) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: RoundSummary(
        count: count,
        names: _names,
        hands: _hand().hands,
        score: count?.after ?? const [40, 12],
        winner: winner,
        onContinue: onContinue ?? () {},
      ),
    ),
  ),
);

void main() {
  AppTextStyles.useGoogleFonts = false;

  testWidgets('explains every lance and the score after the hand', (
    tester,
  ) async {
    var continued = 0;
    final count = countHand(_hand(), const [0, 0], 40);
    await _pump(tester, count: count, onContinue: () => continued++);

    expect(find.text('Resumen de la mano'), findsOneWidget);
    expect(
      find.text('Nosotros +2 · querido 2 · con R-C-7-6 de El Calculador'),
      findsOneWidget,
    );
    expect(
      find.text('Ellos +1 · en paso · con S-6-5-4 de La Temeraria'),
      findsOneWidget,
    );
    expect(find.text('No se juega'), findsOneWidget);
    expect(
      find.text('Nosotros +5 · en paso · con R-C-7-4 de Tú'),
      findsOneWidget,
    );
    expect(
      find.text('Nosotros ${count.after[0]} · Ellos ${count.after[1]}'),
      findsOneWidget,
    );

    await tester.tap(find.text('Siguiente mano'));
    expect(continued, 1);
  });

  testWidgets('says who won the match', (tester) async {
    await _pump(tester, count: null, winner: 0);
    expect(find.text('¡Ganáis la partida!'), findsOneWidget);
    expect(find.text('Volver'), findsOneWidget);
    await _pump(tester, count: null, winner: 1);
    expect(find.text('Ganan ellos'), findsOneWidget);
  });
}
