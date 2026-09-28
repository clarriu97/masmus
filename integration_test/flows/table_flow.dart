import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/bots/heuristic_bot.dart';
import 'package:masmus/bots/strategic_bot.dart';
import 'package:masmus/controllers/match_controller.dart';
import 'package:masmus/game/hand_state.dart';
import 'package:masmus/game/match.dart';
import 'package:masmus/game/rules.dart';
import 'package:masmus/l10n/app_localizations.dart';
import 'package:masmus/services/match_store.dart';
import 'package:masmus/services/scheduler.dart';
import 'package:masmus/ui/table/table_screen.dart';
import 'package:masmus/ui/theme/app_theme.dart';

import '../../test/game/scenario.dart';
import '../helpers.dart';

const _bots = {
  1: Personality.prudente,
  2: Personality.calculador,
  3: Personality.temeraria,
};

void tableFlows() {
  testWidgets('a whole hand at the new table, from a stacked deck: you cut '
      'the mus, pass or refuse until the count, then deal the next hand', (
    tester,
  ) async {
    final controller = MatchController(
      match: MatchState(
        rules: const Rules(),
        score: const [0, 0],
        handNumber: 1,
        hand: dealt(const {
          0: 'R C 7 4',
          1: 'S S 6 5',
          2: '1 1 7 6',
          3: 'R R 5 4',
        }),
      ),
      bots: {
        for (final MapEntry(key: seat, value: personality) in _bots.entries)
          seat: StrategicBot(personality, Random(seat)),
      },
      scheduler: Scheduler(),
      store: MatchStore.inMemory(),
      pace: Pace.fast,
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.tapete,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TableScreen(
          controller: controller,
          bots: _bots,
          onExit: () {},
          onRematch: () {},
        ),
      ),
    );
    await tester.tap(find.text('No hay mus'));
    await tester.pump();

    final answers = [
      for (final label in ['Paso', 'No quiero'])
        find.widgetWithText(FilledButton, label),
    ];
    bool over() => controller.match.hand.phase is HandOver;
    while (!over()) {
      await waitUntil(
        tester,
        () => over() || answers.any((answer) => answer.evaluate().isNotEmpty),
      );
      if (!over()) {
        await tester.tap(
          answers.firstWhere((answer) => answer.evaluate().isNotEmpty),
        );
        await tester.pump();
      }
    }
    expect(controller.match.count, isNotNull);
    await tester.pump();
    expect(find.text('Recuento'), findsOneWidget);
    await tester.tap(find.text('Siguiente mano'));
    await tester.pump();
    expect(controller.match.hand.phase, isA<MusTurn>());
    expect(tester.takeException(), isNull);
  });
}
