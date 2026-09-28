import 'dart:ui';

final _token = RegExp(r'[A-Za-z]|-?(?:\d+\.?\d*|\.\d+)');

/// A [Path] from SVG path data, with the commands the deck's art uses:
/// M, L, H, V, C, Q and Z, absolute or relative.
Path svgPath(String data) {
  final tokens = [for (final match in _token.allMatches(data)) match[0]!];
  final path = Path();
  var i = 0;
  var command = '';
  var x = 0.0, y = 0.0, startX = 0.0, startY = 0.0;
  double next() => i < tokens.length
      ? double.parse(tokens[i++])
      : throw FormatException('Path data ends too early', data);
  while (i < tokens.length) {
    if (double.tryParse(tokens[i]) == null) {
      command = tokens[i++];
    }
    final relative = command == command.toLowerCase();
    final dx = relative ? x : 0.0;
    final dy = relative ? y : 0.0;
    switch (command.toUpperCase()) {
      case 'M':
        x = dx + next();
        y = dy + next();
        path.moveTo(x, y);
        (startX, startY) = (x, y);
        command = relative ? 'l' : 'L';
      case 'L':
        x = dx + next();
        y = dy + next();
        path.lineTo(x, y);
      case 'H':
        x = dx + next();
        path.lineTo(x, y);
      case 'V':
        y = dy + next();
        path.lineTo(x, y);
      case 'C':
        final (x1, y1) = (dx + next(), dy + next());
        final (x2, y2) = (dx + next(), dy + next());
        x = dx + next();
        y = dy + next();
        path.cubicTo(x1, y1, x2, y2, x, y);
      case 'Q':
        final (x1, y1) = (dx + next(), dy + next());
        x = dx + next();
        y = dy + next();
        path.quadraticBezierTo(x1, y1, x, y);
      case 'Z':
        path.close();
        (x, y) = (startX, startY);
        command = '';
      default:
        throw FormatException('Unsupported path command', data);
    }
  }
  return path;
}
