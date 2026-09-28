import 'dart:ui';

import '../../game/cards.dart';
import '../theme/app_theme.dart';
import 'svg_path.dart';

/// One shape of the deck's art, drawn in a 100 × 100 box: filled, then
/// outlined.
final class ArtShape {
  ArtShape(
    this.path, {
    this.fill,
    this.stroke = AppColors.cardInk,
    this.strokeWidth = 4.5,
  });

  ArtShape.circle(
    double x,
    double y,
    double radius, {
    Color? fill,
    Color stroke = AppColors.cardInk,
    double strokeWidth = 4.5,
  }) : this(
         Path()..addOval(Rect.fromCircle(center: Offset(x, y), radius: radius)),
         fill: fill,
         stroke: stroke,
         strokeWidth: strokeWidth,
       );

  ArtShape.box(
    double left,
    double top,
    double width,
    double height,
    double radius, {
    Color? fill,
  }) : this(
         Path()..addRRect(
           RRect.fromLTRBR(
             left,
             top,
             left + width,
             top + height,
             Radius.circular(radius),
           ),
         ),
         fill: fill,
       );

  final Path path;
  final Color? fill;
  final Color stroke;
  final double strokeWidth;
}

Color suitColor(Suit suit) => switch (suit) {
  Suit.oros => AppColors.oros,
  Suit.copas => AppColors.copas,
  Suit.espadas => AppColors.espadas,
  Suit.bastos => AppColors.bastos,
};

/// The four suits, told apart by their shape as much as by their color: a
/// coin, a cup, a sword and a club.
final Map<Suit, List<ArtShape>> suitArt = {
  Suit.oros: [
    ArtShape.circle(50, 50, 44, fill: AppColors.oros, strokeWidth: 5),
    ArtShape.circle(50, 50, 28, fill: AppColors.card, strokeWidth: 3.5),
    ArtShape.circle(50, 50, 14, fill: AppColors.oros, strokeWidth: 3.5),
  ],
  Suit.copas: [
    ArtShape(
      svgPath(
        'M16 10 H84 C84 38 70 54 57 58 V72 C57 77 62 79 70 81 '
        'C77 83 79 86 79 92 H21 C21 86 23 83 30 81 C38 79 43 77 43 72 V58 '
        'C30 54 16 38 16 10 Z',
      ),
      fill: AppColors.copas,
      strokeWidth: 5,
    ),
    ArtShape(svgPath('M24 20 H76'), strokeWidth: 3),
  ],
  Suit.espadas: [
    ArtShape(svgPath('M50 2 L61 16 V59 H39 V16 Z'), fill: AppColors.espadas),
    ArtShape(
      svgPath('M50 13 V54'),
      stroke: AppColors.espadasShine,
      strokeWidth: 3,
    ),
    ArtShape.box(22, 59, 56, 11, 5.5, fill: AppColors.espadas),
    ArtShape.box(44, 70, 12, 17, 0, fill: AppColors.espadas),
    ArtShape.circle(50, 91, 7, fill: AppColors.espadas),
  ],
  Suit.bastos: [
    ArtShape(
      svgPath('M58 22 C64 12 72 10 80 8 C78 16 72 22 62 26 Z'),
      fill: AppColors.bastos,
    ),
    ArtShape(
      svgPath(
        'M44 97 C43 84 42 72 41 62 C37 60 36 55 40 53 C39 44 38 36 37 28 '
        'C33 26 32 21 36 19 C36 12 42 5 51 5 C60 5 65 12 64 21 '
        'C68 23 68 28 64 30 C63 40 62 50 60 60 C64 62 64 67 59 69 '
        'C58 78 57 88 56 97 Z',
      ),
      fill: AppColors.bastos,
    ),
    ArtShape(
      svgPath('M47 16 C49 30 50 50 50 70 M52 80 L52 90'),
      stroke: AppColors.bastosShade,
      strokeWidth: 2.5,
    ),
  ],
};

/// What sets the sota, the caballo and the rey apart, in the suit's color:
/// a page in a feathered cap, a horse's head and a crown.
List<ArtShape> figureArt(int number, Color color) => switch (number) {
  10 => [
    ArtShape(
      svgPath('M20 94 C20 68 33 57 50 57 C67 57 80 68 80 94 Z'),
      fill: color,
    ),
    ArtShape.circle(50, 36, 15, fill: AppColors.card),
    ArtShape(
      svgPath('M28 26 C30 12 70 12 72 26 C62 22 38 22 28 26 Z'),
      fill: color,
    ),
    ArtShape(
      svgPath('M66 17 C76 6 86 8 94 2 C90 12 80 18 68 21 Z'),
      fill: color,
    ),
  ],
  11 => [
    ArtShape(
      svgPath(
        'M72 94 L30 94 C29 82 33 73 40 67 C30 65 21 61 15 55 '
        'C10 50 10 44 16 41 C26 37 33 31 39 23 C42 17 46 13 51 10 '
        'L54 2 L60 11 C75 17 85 33 85 52 C85 69 78 82 72 94 Z',
      ),
      fill: color,
    ),
    ArtShape.circle(41, 33, 3.8, fill: AppColors.card, strokeWidth: 2.5),
    ArtShape(svgPath('M60 16 C70 24 76 36 77 50'), strokeWidth: 3),
  ],
  12 => [
    ArtShape(
      svgPath('M14 78 L9 34 L31 54 L50 20 L69 54 L91 34 L86 78 Z'),
      fill: color,
    ),
    ArtShape.box(12, 72, 76, 13, 3, fill: color),
    ArtShape.circle(9, 30, 6, fill: color),
    ArtShape.circle(50, 16, 6, fill: color),
    ArtShape.circle(91, 30, 6, fill: color),
  ],
  _ => throw ArgumentError.value(number, 'number', 'Not a figure'),
};

/// Draws [shapes] from their 100 × 100 box into the square [box].
void paintArt(Canvas canvas, List<ArtShape> shapes, Rect box) {
  canvas
    ..save()
    ..translate(box.left, box.top)
    ..scale(box.width / 100);
  for (final shape in shapes) {
    final fill = shape.fill;
    if (fill != null) {
      canvas.drawPath(shape.path, Paint()..color = fill);
    }
    canvas.drawPath(
      shape.path,
      Paint()
        ..color = shape.stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = shape.strokeWidth
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }
  canvas.restore();
}
