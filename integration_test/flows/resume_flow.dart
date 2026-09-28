import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/services/match_store.dart';
import 'package:masmus/ui/cards/playing_card_view.dart';
import 'package:masmus/ui/table/table_screen.dart';

import '../helpers.dart';

void resumeFlows() {
  testWidgets('a match survives the app being killed: it opens again at '
      'the same point, with the same cards', (tester) async {
    final directory = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('masmus_e2e_'),
    ))!;
    addTearDown(() => directory.delete(recursive: true));
    final store = (await tester.runAsync(() => MatchStore.open(directory)))!;
    await launchApp(tester, store: store);
    await tester.tap(find.text('Nueva partida'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Empezar partida'));

    final mus = find.widgetWithText(FilledButton, 'Mus');
    await waitUntil(
      tester,
      () => store.saved != null || mus.evaluate().isNotEmpty,
    );
    if (store.saved == null) {
      await tester.tap(mus);
    }
    await waitUntil(tester, () => store.saved != null);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    final left = store.saved!;
    await relaunchApp(tester, directory);

    expect(find.text('PARTIDA EN CURSO'), findsOneWidget);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.byType(TableScreen), findsOneWidget);
    final yours = tester
        .widgetList<PlayingCardView>(find.byType(PlayingCardView))
        .where((card) => card.faceUp)
        .map((card) => card.card);
    expect(yours, unorderedEquals(left.match.hand.hands[0]));
  });
}
