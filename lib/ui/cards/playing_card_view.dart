import 'dart:math';

import 'package:flutter/material.dart';

import '../../game/cards.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'card_art.dart';
import 'pip_layout.dart';

/// A card of the deck, face up or down. Tapping it calls [onTap]; a
/// [selected] card (one marked to throw away) rises and is edged in brass.
/// Below [compactWidth] only the number and the suit are drawn, so it still
/// reads at a glance.
class PlayingCardView extends StatelessWidget {
  const PlayingCardView(
    this.card, {
    this.width = 88,
    this.faceUp = true,
    this.selected = false,
    this.onTap,
    super.key,
  });

  static const double aspectRatio = 0.66;
  static const double compactWidth = 64;

  /// How far a selected card rises, as a fraction of its height.
  static const double lift = 0.1;

  final PlayingCard card;
  final double width;
  final bool faceUp;
  final bool selected;
  final VoidCallback? onTap;

  bool get compact => width < compactWidth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final height = width / aspectRatio;
    final radius = BorderRadius.circular(width * 0.075);
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: faceUp
          ? l10n.cardName('${card.number}', card.suit.name)
          : l10n.cardFaceDown,
      button: onTap != null,
      selected: onTap != null ? selected : null,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Transform.translate(
          offset: Offset(0, selected ? -height * lift : 0),
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: selected
                  ? Border.all(color: AppColors.turn, width: 3)
                  : null,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: faceUp ? AppColors.card : null,
                borderRadius: radius,
                border: faceUp
                    ? Border.all(
                        color: AppColors.cardEdge,
                        width: max(1, width * 0.012),
                      )
                    : null,
                boxShadow: AppShadows.raised,
              ),
              child: CustomPaint(
                size: Size(width, height),
                painter: faceUp
                    ? _FacePainter(card, compact: compact)
                    : const _BackPainter(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FacePainter extends CustomPainter {
  const _FacePainter(this.card, {required this.compact});

  final PlayingCard card;
  final bool compact;

  @override
  void paint(Canvas canvas, Size size) {
    final suit = suitArt[card.suit]!;
    if (compact) {
      _number(
        canvas,
        Offset(size.width / 2, size.height * 0.1),
        size.width * 0.46,
      );
      paintArt(
        canvas,
        suit,
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.7),
          width: size.width * 0.52,
          height: size.width * 0.52,
        ),
      );
      return;
    }
    _corner(canvas, size, suit);
    canvas
      ..save()
      ..translate(size.width, size.height)
      ..rotate(pi);
    _corner(canvas, size, suit);
    canvas.restore();

    final area = Rect.fromLTWH(
      artArea.left * size.width,
      artArea.top * size.height,
      artArea.width * size.width,
      artArea.height * size.height,
    );
    Rect box(Offset center, double fraction) => Rect.fromCenter(
      center:
          area.topLeft +
          Offset(center.dx * area.width, center.dy * area.height),
      width: fraction * area.width,
      height: fraction * area.width,
    );
    if (card.number <= 7) {
      final layout = pipLayout(card.number);
      for (final center in layout.centers) {
        paintArt(canvas, suit, box(center, layout.size));
      }
    } else {
      paintArt(
        canvas,
        figureArt(card.number, suitColor(card.suit)),
        box(figureEmblem.center, figureEmblem.size),
      );
      paintArt(canvas, suit, box(figurePip.center, figurePip.size));
    }
  }

  /// The number and a small pip, top left; drawn again upside down.
  void _corner(Canvas canvas, Size size, List<ArtShape> suit) {
    final pip = size.width * 0.15;
    final left = size.width * 0.053;
    _number(
      canvas,
      Offset(left + pip / 2, size.height * 0.025),
      size.width * 0.2,
    );
    paintArt(canvas, suit, Rect.fromLTWH(left, size.height * 0.17, pip, pip));
  }

  /// The card's number, centered on [top].
  void _number(Canvas canvas, Offset top, double fontSize) {
    final text = TextPainter(
      text: TextSpan(
        text: '${card.number}',
        style: AppTheme.cardIndex.copyWith(
          fontSize: fontSize,
          letterSpacing: -fontSize * 0.04,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, top - Offset(text.width / 2, 0));
    text.dispose();
  }

  @override
  bool shouldRepaint(_FacePainter old) =>
      old.card != card || old.compact != compact;
}

/// Maroon stripes inside a cream edge.
class _BackPainter extends CustomPainter {
  const _BackPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(w * 0.075)),
      Paint()..color = AppColors.cardBackEdge,
    );
    final inner = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(w * 0.05),
      Radius.circular(w * 0.045),
    );
    canvas
      ..save()
      ..clipRRect(inner)
      ..drawRRect(inner, Paint()..color = AppColors.cardBack);
    final stripe = Paint()
      ..color = AppColors.cardBackStripe
      ..strokeWidth = w * 0.03;
    final gap = w * 0.06;
    for (var x = -size.height; x < w; x += gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        stripe,
      );
    }
    canvas.restore();
    canvas.drawRRect(
      inner,
      Paint()
        ..color = AppColors.cardBackEdge.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1, w * 0.01),
    );
  }

  @override
  bool shouldRepaint(_BackPainter old) => false;
}
