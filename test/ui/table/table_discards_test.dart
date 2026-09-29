import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/controllers/match_controller.dart';
import 'package:masmus/game/cards.dart';
import 'package:masmus/game/event.dart';
import 'package:masmus/game/hand_state.dart';
import 'package:masmus/game/move.dart';
import 'package:masmus/services/scheduler.dart';
import 'package:masmus/ui/cards/playing_card_view.dart';
import 'package:masmus/ui/table/seat.dart';

import '../../helpers/table.dart';
import '../../helpers/test_app.dart';

PlayingCardView _card(WidgetTester tester, String code) => tester.widget(
  find.byWidgetPredicate(
    (widget) =>
        widget is PlayingCardView &&
        widget.faceUp &&
        widget.card == PlayingCard.parse(code),
  ),
);

Finder _discard() => find.ancestor(
  of: find.text('Descartar'),
  matching: find.byType(FilledButton),
);

void main() {
  testWidgets('a tap marks a card to throw away, another unmarks it; the '
      'button says how many and needs at least one', (tester) async {
    final controller = tableMoments['discard']!();
    await tester.pumpWidget(buildTestApp(tableScreen(controller)));
    expect(find.text('Toca las cartas que quieres cambiar'), findsOneWidget);
    expect(tester.widget<FilledButton>(_discard()).enabled, isFalse);
    expect(find.text('marca las que cambias'), findsOneWidget);

    await tester.tap(find.byWidget(_card(tester, '5o')));
    await tester.tap(find.byWidget(_card(tester, '4o')));
    await tester.pump();
    expect(_card(tester, '5o').selected, isTrue);
    expect(find.text('2 cartas'), findsOneWidget);
    expect(tester.widget<FilledButton>(_discard()).enabled, isTrue);

    await tester.tap(find.byWidget(_card(tester, '4o')));
    await tester.pump();
    expect(_card(tester, '4o').selected, isFalse);
    expect(find.text('una carta'), findsOneWidget);

    await tester.tap(_discard());
    await tester.pump();
    expect(controller.match.hand.log.last, const Discarded(0, count: 1));
    expect(controller.match.hand.phase, isA<DiscardTurn>());
    expect(find.text('Toca las cartas que quieres cambiar'), findsNothing);
  });

  testWidgets('outside the discards your cards are not buttons', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(tableScreen(tableMoments['grande_open']!())),
    );
    expect(
      tester
          .widgetList<PlayingCardView>(find.byType(PlayingCardView))
          .where((card) => card.onTap != null),
      isEmpty,
    );
  });

  Future<MatchController> discardAll(
    WidgetTester tester,
    ManualScheduler scheduler,
  ) async {
    final controller = tableController(
      hands: const {0: 'R 7 5 4', 1: 'S C 7 6', 2: '4 5 6 1', 3: 'R 5 1 4'},
      moves: [
        for (final seat in [0, 1, 2, 3]) (seat, const Mus()),
      ],
      scheduler: scheduler,
    );
    await tester.pumpWidget(buildTestApp(tableScreen(controller)));
    await tester.pumpAndSettle();
    await tester.tap(find.byWidget(_card(tester, '4o')));
    await tester.pump();
    await tester.tap(_discard());
    await tester.pump();
    for (var bot = 0; bot < 3; bot++) {
      scheduler.advance(Pace.normal.thinking);
      await tester.pump();
    }
    return controller;
  }

  testWidgets('each player shows how many cards it asked for, for the rest '
      'of the hand', (tester) async {
    final controller = await discardAll(tester, ManualScheduler());
    expect(controller.match.hand.phase, isA<MusTurn>());
    for (final seat in find.byType(Seat).evaluate()) {
      expect((seat.widget as Seat).asked, startsWith('pidió'));
    }
  });

  List<PlayingCardView> yourCards(WidgetTester tester) => [
    for (final element in find.byType(PlayingCardView).evaluate())
      if (element.widget case final PlayingCardView card
          when card.faceUp &&
              (element.findAncestorWidgetOfExactType<Visibility>()?.visible ??
                  true))
        card,
  ];

  testWidgets('the cards asked for are dealt from the deck, one after '
      'another, and only then can anyone play', (tester) async {
    final scheduler = ManualScheduler();
    final controller = await discardAll(tester, scheduler);
    final deal = controller.dealing!;
    expect(deal.seats, [
      for (final discard in controller.match.hand.log.whereType<Discarded>())
        for (var i = 0; i < discard.count; i++) discard.seat,
    ], reason: 'what each asked for, from the mano on');
    expect(deal.seats.where((seat) => seat == 0), hasLength(1));
    expect(
      yourCards(tester),
      hasLength(3),
      reason: 'the new one is on its way',
    );
    expect(controller.humanMoves, isEmpty);
    expect(find.text('Te toca'), findsNothing, reason: 'nobody, while dealing');

    await tester.pump(Deal.flight ~/ 2);
    expect(
      find.ancestor(
        of: find.byType(PlayingCardView),
        matching: find.byType(IgnorePointer),
      ),
      findsWidgets,
      reason: 'a card in the air',
    );
    await tester.pump(deal.duration);
    expect(yourCards(tester), hasLength(4));
    scheduler.advance(deal.duration);
    await tester.pump();
    expect(controller.dealing, isNull);
  });

  testWidgets('with reduced motion the cards are there at once', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    final controller = await discardAll(tester, ManualScheduler());
    expect(controller.dealing, isNotNull);
    expect(yourCards(tester), hasLength(4));
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Opacity && widget.opacity < 1,
      ),
      findsNothing,
      reason: 'nor a word said, nor the dots of a bot thinking',
    );
  });
}
