import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/game/match.dart';
import 'package:masmus/game/move.dart';
import 'package:masmus/game/rules.dart';
import 'package:masmus/ui/table/hand_history.dart';
import 'package:masmus/ui/table/table_view.dart';

import '../../game/scenario.dart';
import '../../helpers/table.dart';
import '../../helpers/test_app.dart';

const _names = {
  0: 'Tú',
  1: 'El Prudente',
  2: 'El Calculador',
  3: 'La Temeraria',
};

Future<void> _pump(WidgetTester tester, MatchState match) => tester.pumpWidget(
  buildTestComponent(
    HandHistory(
      log: match.hand.log,
      view: TableView.of(match, you: 0),
      names: _names,
    ),
  ),
);

MatchState _match(List<(int, Move)> moves, {bool musCorrido = false}) {
  var match = MatchState(
    rules: const Rules(),
    score: const [0, 0],
    handNumber: 1,
    hand: dealt(const {
      0: 'R R C 1',
      1: 'S S 7 6',
      2: '4 5 6 7',
      3: '4 5 1 7',
    }, musCorrido: musCorrido),
  );
  for (final (seat, move) in moves) {
    match = match.play(seat, move);
  }
  return match;
}

void main() {
  testWidgets('before anyone speaks, it says so', (tester) async {
    await _pump(tester, _match(const []));
    expect(find.text('Todavía no ha hablado nadie.'), findsOneWidget);
  });

  testWidgets('each one says whether they have pares, in their own step', (
    tester,
  ) async {
    await _pump(
      tester,
      _match([(0, const NoHayMus()), ...passes(0), ...passes(0)]),
    );
    for (final line in [
      'Tú: No hay mus',
      '→ en paso',
      'Tú: Pares: sí',
      'El Prudente: Pares: sí',
      'El Calculador: Pares: no',
      'La Temeraria: Pares: no',
    ]) {
      expect(find.text(line), findsWidgets, reason: line);
    }
    for (final step in ['Mus', 'Grande', 'Chica', 'Pares']) {
      expect(find.text(step), findsOneWidget, reason: step);
    }
  });

  testWidgets('during mus corrido, who becomes mano', (tester) async {
    await _pump(
      tester,
      _match([(0, const Mus()), (1, const NoHayMus())], musCorrido: true),
    );
    expect(find.text('Tú: Mus'), findsOneWidget);
    expect(find.text('El Prudente: No hay mus'), findsOneWidget);
    expect(find.text('→ El Prudente pasa a ser mano'), findsOneWidget);
  });
}
