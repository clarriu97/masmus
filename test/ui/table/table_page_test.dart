import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/bots/heuristic_bot.dart';
import 'package:masmus/controllers/match_controller.dart';
import 'package:masmus/game/rules.dart';
import 'package:masmus/l10n/app_localizations.dart';
import 'package:masmus/l10n/localized_names.dart';
import 'package:masmus/services/scheduler.dart';
import 'package:masmus/ui/table/seat.dart';
import 'package:masmus/ui/table/table_page.dart';
import 'package:masmus/ui/table/table_screen.dart';
import 'package:masmus/ui/widgets/table_chip.dart';

import '../../helpers/test_app.dart';

final _l10n = lookupAppLocalizations(const Locale('es'));

Future<List<Seat>> _seats(WidgetTester tester, {required int seed}) async {
  await tester.pumpWidget(
    buildTestApp(
      TablePage(
        partner: Personality.farolero,
        rules: const Rules(target: 30),
        seed: seed,
        scheduler: ManualScheduler(),
      ),
    ),
  );
  return tester.widgetList<Seat>(find.byType(Seat)).toList();
}

void main() {
  testWidgets('your partner sits across and two other personalities are '
      'the rivals', (tester) async {
    final seats = await _seats(tester, seed: 3);
    final partner = seats.singleWhere(
      (seat) => seat.role.startsWith('compañero'),
    );
    expect(partner.name, _l10n.personalityName(Personality.farolero));
    final rivals = {
      for (final seat in seats)
        if (!seat.role.startsWith('compañero')) seat.name,
    };
    expect(rivals, hasLength(2));
    expect(rivals, isNot(contains(partner.name)));
    expect(find.text('a 30'), findsOneWidget);
  });

  testWidgets('the same seed brings the same rivals', (tester) async {
    final first = [
      for (final seat in await _seats(tester, seed: 11)) seat.name,
    ];
    final again = [
      for (final seat in await _seats(tester, seed: 11)) seat.name,
    ];
    expect(again, first);
  });

  testWidgets('Salir goes back to where the match was started', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TablePage(
                  partner: Personality.calculador,
                  rules: const Rules(),
                  seed: 1,
                  scheduler: ManualScheduler(),
                ),
              ),
            ),
            child: const Text('jugar'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('jugar'));
    await tester.pumpAndSettle();
    expect(find.byType(TableScreen), findsOneWidget);
    await tester.tap(find.text('Salir'));
    await tester.pumpAndSettle();
    expect(find.byType(TableScreen), findsNothing);
    expect(find.text('jugar'), findsOneWidget);
  });

  testWidgets('the bots play at the pace of Ajustes, and the hand help can '
      'be off', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        TablePage(
          partner: Personality.calculador,
          rules: const Rules(),
          pace: Pace.slow,
          handHelp: false,
          seed: 2,
          scheduler: ManualScheduler(),
        ),
      ),
    );
    final table = tester.widget<TableScreen>(find.byType(TableScreen));
    expect(table.controller.pace, Pace.slow);
    expect(
      tester
          .widgetList<TableChip>(find.byType(TableChip))
          .map((chip) => chip.label)
          .where(
            (label) =>
                RegExp('^(Punto|Juego|Par|Medias|Duples)').hasMatch(label),
          ),
      isEmpty,
    );
  });
}
