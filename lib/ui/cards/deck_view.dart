import 'package:flutter/material.dart';

import '../../game/cards.dart';
import 'playing_card_view.dart';

/// The deck, face down, a few cards squared up: it sits by the mano, on
/// the side of the postre who deals, as at a real table.
class DeckView extends StatelessWidget {
  const DeckView({this.width = cardWidth, super.key});

  static const cardWidth = 22.0;
  static const _back = PlayingCard(Suit.oros, 1);
  static const _layers = 3;
  static const _step = 2.0;

  final double width;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: width + _step * (_layers - 1),
      height: width / PlayingCardView.aspectRatio + _step * (_layers - 1),
      child: Stack(
        children: [
          for (var i = 0; i < _layers; i++)
            Positioned(
              left: i * _step,
              top: (_layers - 1 - i) * _step,
              child: PlayingCardView(_back, width: width, faceUp: false),
            ),
        ],
      ),
    ),
  );
}
