import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/controllers/match_controller.dart';
import 'package:masmus/game/event.dart';
import 'package:masmus/game/move.dart';
import 'package:masmus/ui/table/seat.dart';
import 'package:masmus/ui/table/table_actions.dart';
import 'package:masmus/ui/widgets/hold_button.dart';

import '../../helpers/table.dart';
import '../../helpers/test_app.dart';

Future<MatchController> _pump(WidgetTester tester, String moment) async {
  final controller = tableMoments[moment]!();
  await tester.pumpWidget(buildTestApp(tableScreen(controller)));
  return controller;
}

GameEvent? _last(MatchController controller) => controller.match.hand.log
    .where((event) => event is! LanceStarted && event is! Declared)
    .lastOrNull;

Finder _button(String label) =>
    find.ancestor(of: find.text(label), matching: find.byType(FilledButton));

void main() {
  testWidgets('at the mus: mus or no hay mus, and nothing else', (
    tester,
  ) async {
    final controller = await _pump(tester, 'mus');
    expect(_button('Mus'), findsOneWidget);
    expect(_button('No hay mus'), findsOneWidget);
    expect(find.byType(FilledButton), findsNWidgets(2));

    await tester.tap(_button('No hay mus'));
    await tester.pump();
    expect(_last(controller), const NoHayMusSaid(0));
  });

  testWidgets('opening a lance: paso, envido with its amount and órdago', (
    tester,
  ) async {
    final controller = await _pump(tester, 'mus');
    controller.play(const NoHayMus());
    catchUp(controller);
    await tester.pump();
    expect(_button('Paso'), findsOneWidget);
    expect(_button('Envido'), findsOneWidget);
    expect(find.byType(HoldButton), findsOneWidget);
    expect(find.text('2'), findsWidgets);

    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(_button('Envido'));
    await tester.pump();
    expect(
      _last(controller),
      isA<EnvidoSaid>().having((e) => e.amount, 'amount', 5),
    );
  });

  testWidgets('any other amount, chosen without leaving the table', (
    tester,
  ) async {
    final controller = await _pump(tester, 'mus');
    controller.play(const NoHayMus());
    catchUp(controller);
    await tester.pump();
    await tester.tap(find.text('Otra'));
    await tester.pumpAndSettle();
    expect(find.text('¿Cuánto?'), findsOneWidget);
    await tester.tap(find.byTooltip('Más'));
    await tester.pump();
    await tester.tap(find.text('Envidar 3'));
    await tester.pumpAndSettle();
    expect(find.text('3'), findsWidgets);

    await tester.tap(_button('Envido'));
    await tester.pump();
    expect(
      _last(controller),
      isA<EnvidoSaid>().having((e) => e.amount, 'amount', 3),
    );
  });

  testWidgets('the órdago only goes off when held; a tap says so', (
    tester,
  ) async {
    final controller = await _pump(tester, 'mus');
    controller.play(const NoHayMus());
    catchUp(controller);
    await tester.pump();

    await tester.tap(find.byType(HoldButton));
    await tester.pump();
    expect(find.text('Mantén pulsado para echar el órdago'), findsOneWidget);
    expect(_last(controller), const NoHayMusSaid(0));
    await tester.pump(const Duration(seconds: 3));

    final hold = await tester.startGesture(
      tester.getCenter(find.byType(HoldButton)),
    );
    Future<void> hold100ms(int times) async {
      for (var i = 0; i < times; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await hold100ms(5);
    expect(_last(controller), const NoHayMusSaid(0));
    await hold100ms(5);
    await hold.up();
    await tester.pump();
    expect(_last(controller), const OrdagoSaid(0));
  });

  testWidgets('screen readers throw the órdago with a long press', (
    tester,
  ) async {
    final controller = await _pump(tester, 'mus');
    controller.play(const NoHayMus());
    catchUp(controller);
    await tester.pump();
    tester.semantics.longPress(find.semantics.byLabel('Órdago'));
    await tester.pump();
    expect(_last(controller), const OrdagoSaid(0));
  });

  testWidgets('answering an envite: who bet what, then no quiero with what it '
      'gives, quiero, raise by any amount or órdago', (tester) async {
    final controller = await _pump(tester, 'chica_answer');
    expect(find.text('La Temeraria envida 5 a la chica'), findsOneWidget);
    expect(find.text('Ellos +1'), findsOneWidget);
    for (final label in ['No quiero', 'Quiero', 'Subir']) {
      expect(_button(label), findsOneWidget);
    }
    expect(find.byType(HoldButton), findsOneWidget);

    await tester.tap(_button('Subir'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Más'));
    await tester.pump();
    await tester.tap(find.text('Envidar 3'));
    await tester.pumpAndSettle();
    expect(
      _last(controller),
      isA<EnvidoSaid>()
          .having((e) => e.amount, 'amount', 3)
          .having((e) => e.stake, 'stake', 8),
    );
  });

  testWidgets('an órdago can only be wanted or not, and your partner shows '
      'it left the answer to you', (tester) async {
    final controller = await _pump(tester, 'partner_decides');
    final partner = tester.widget<Seat>(
      find.ancestor(
        of: find.text('El Calculador'),
        matching: find.byType(Seat),
      ),
    );
    expect(partner.said, 'Tú decides');
    expect(find.text('El Prudente echa órdago a la grande'), findsOneWidget);
    expect(find.byType(FilledButton), findsNWidgets(2));
    expect(find.byType(HoldButton), findsNothing);

    await tester.tap(_button('No quiero'));
    await tester.pump();
    expect(_last(controller), isA<LanceClosed>());
  });

  testWidgets('while it is not your turn there are no moves, only whose '
      'turn it is', (tester) async {
    await _pump(tester, 'grande_envite');
    expect(find.byType(TableActions), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
    expect(find.text('Turno de El Calculador'), findsOneWidget);
  });
}
