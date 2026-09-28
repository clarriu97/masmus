import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/game/cards.dart';
import 'package:masmus/ui/cards/card_art.dart';
import 'package:masmus/ui/cards/playing_card_view.dart';

import '../../helpers/test_app.dart';

void main() {
  for (final (code, name) in [
    ('1o', 'As de oros'),
    ('7c', 'Siete de copas'),
    ('Se', 'Sota de espadas'),
    ('Cb', 'Caballo de bastos'),
    ('Ro', 'Rey de oros'),
  ]) {
    testWidgets('a screen reader hears $name', (tester) async {
      await tester.pumpWidget(
        buildTestComponent(PlayingCardView(PlayingCard.parse(code))),
      );
      expect(find.bySemanticsLabel(name), findsOneWidget);
    });
  }

  testWidgets('face down it gives nothing away', (tester) async {
    await tester.pumpWidget(
      buildTestComponent(
        PlayingCardView(PlayingCard.parse('Ro'), faceUp: false),
      ),
    );
    expect(find.bySemanticsLabel('Carta boca abajo'), findsOneWidget);
    expect(find.bySemanticsLabel('Rey de oros'), findsNothing);
  });

  testWidgets('keeps the proportions of a Spanish card', (tester) async {
    await tester.pumpWidget(
      buildTestComponent(PlayingCardView(PlayingCard.parse('4b'), width: 99)),
    );
    expect(
      tester.getSize(find.byType(CustomPaint).last),
      const Size(99, 99 / PlayingCardView.aspectRatio),
    );
  });

  testWidgets('a tap marks it, and a marked card rises and says so', (
    tester,
  ) async {
    var selected = false;
    await tester.pumpWidget(
      buildTestComponent(
        StatefulBuilder(
          builder: (context, setState) => PlayingCardView(
            PlayingCard.parse('5c'),
            selected: selected,
            onTap: () => setState(() => selected = !selected),
          ),
        ),
      ),
    );
    final resting = tester.getTopLeft(find.byType(CustomPaint).last);
    expect(
      tester.getSemantics(find.byType(PlayingCardView)),
      matchesSemantics(
        label: 'Cinco de copas',
        isButton: true,
        hasTapAction: true,
        hasSelectedState: true,
      ),
    );

    await tester.tap(find.byType(PlayingCardView));
    await tester.pump();
    expect(selected, isTrue);
    expect(
      tester.getSemantics(find.byType(PlayingCardView)),
      matchesSemantics(
        label: 'Cinco de copas',
        isButton: true,
        hasTapAction: true,
        hasSelectedState: true,
        isSelected: true,
      ),
    );
    final risen = tester.getTopLeft(find.byType(CustomPaint).last);
    expect(
      resting.dy - risen.dy,
      closeTo(88 / PlayingCardView.aspectRatio * PlayingCardView.lift, 0.01),
    );
  });

  testWidgets('without a callback it is only a picture', (tester) async {
    await tester.pumpWidget(
      buildTestComponent(PlayingCardView(PlayingCard.parse('5c'))),
    );
    expect(
      tester.getSemantics(find.byType(PlayingCardView)),
      matchesSemantics(label: 'Cinco de copas'),
    );
  });

  test('small cards show only the number and the suit', () {
    final card = PlayingCard.parse('7e');
    expect(PlayingCardView(card, width: 52).compact, isTrue);
    expect(PlayingCardView(card).compact, isFalse);
  });

  test('every suit and figure has its art', () {
    for (final suit in Suit.values) {
      expect(suitArt[suit], isNotEmpty);
      for (final number in [10, 11, 12]) {
        expect(figureArt(number, suitColor(suit)), isNotEmpty);
      }
    }
    expect(() => figureArt(7, suitColor(Suit.oros)), throwsArgumentError);
  });
}
