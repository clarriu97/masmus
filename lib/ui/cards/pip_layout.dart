import 'dart:ui';

/// Where the art of a card goes, as fractions of the card: clear of the
/// corner indexes.
const artArea = Rect.fromLTWH(0.197, 0.15, 0.606, 0.7);

/// How the pips of a card from 1 to 7 sit in the [artArea]: their centers,
/// as fractions of it, and their size, as a fraction of its width.
typedef PipLayout = ({List<Offset> centers, double size});

PipLayout pipLayout(int number) => switch (number) {
  1 => (centers: const [Offset(0.5, 0.5)], size: 0.85),
  2 => (centers: const [Offset(0.5, 0.2), Offset(0.5, 0.8)], size: 0.55),
  3 => (
    centers: const [Offset(0.5, 0.15), Offset(0.5, 0.5), Offset(0.5, 0.85)],
    size: 0.48,
  ),
  4 => (
    centers: const [
      Offset(0.25, 0.2),
      Offset(0.75, 0.2),
      Offset(0.25, 0.8),
      Offset(0.75, 0.8),
    ],
    size: 0.42,
  ),
  5 => (
    centers: const [
      Offset(0.25, 0.16),
      Offset(0.75, 0.16),
      Offset(0.5, 0.5),
      Offset(0.25, 0.84),
      Offset(0.75, 0.84),
    ],
    size: 0.4,
  ),
  6 => (
    centers: const [
      Offset(0.25, 0.14),
      Offset(0.75, 0.14),
      Offset(0.25, 0.5),
      Offset(0.75, 0.5),
      Offset(0.25, 0.86),
      Offset(0.75, 0.86),
    ],
    size: 0.4,
  ),
  7 => (
    centers: const [
      Offset(0.25, 0.11),
      Offset(0.75, 0.11),
      Offset(0.5, 0.33),
      Offset(0.25, 0.56),
      Offset(0.75, 0.56),
      Offset(0.25, 0.89),
      Offset(0.75, 0.89),
    ],
    size: 0.35,
  ),
  _ => throw ArgumentError.value(number, 'number', 'Not a numeral card'),
};

/// The sota, caballo and rey: their emblem above, a pip of their suit
/// below, in the same terms as [PipLayout].
const figureEmblem = (center: Offset(0.5, 0.3), size: 0.78);
const figurePip = (center: Offset(0.5, 0.78), size: 0.45);
