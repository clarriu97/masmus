// The app's icon and splash, drawn with the deck's own art. The PNGs they
// write are what flutter_launcher_icons and flutter_native_splash turn into
// the platforms' assets. After changing the mark:
//   flutter test --update-goldens --tags golden test/goldens/branding_test.dart
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
@Tags(['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/game/cards.dart';
import 'package:masmus/ui/cards/card_art.dart';
import 'package:masmus/ui/theme/app_theme.dart';

/// Two cream cards on the felt: a copas behind, an oros in front.
class _Mark extends CustomPainter {
  const _Mark({this.felt = false, this.mono = false, this.scale = 1});

  final bool felt;

  /// A single-colour silhouette, for the system to tint.
  final bool mono;

  /// The cards' size, where 1 fills about two thirds of the canvas.
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    if (felt) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(0, -0.2),
            radius: 0.85,
            colors: [AppColors.feltLight, AppColors.felt, AppColors.feltDark],
            stops: [0, 0.6, 1],
          ).createShader(Offset.zero & size),
      );
    }
    canvas
      ..saveLayer(Offset.zero & size, Paint())
      ..translate(size.width / 2, size.height / 2)
      ..scale(size.width / 1024 * scale);
    _card(canvas, const Offset(-96, -8), -0.22, Suit.copas);
    _card(canvas, const Offset(96, 24), 0.13, Suit.oros);
    canvas.restore();
  }

  void _card(Canvas canvas, Offset center, double angle, Suit suit) {
    final card = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 380, height: 560),
      const Radius.circular(44),
    );
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(angle);
    if (mono) {
      canvas
        ..drawRRect(card.inflate(14), Paint()..blendMode = BlendMode.clear)
        ..drawRRect(card, Paint()..color = const Color(0xFFFFFFFF));
      final pip = _pip();
      canvas
        ..save()
        ..translate(pip.left, pip.top)
        ..scale(pip.width / 100);
      for (final shape in suitArt[suit]!) {
        if (shape.fill != null) {
          canvas.drawPath(shape.path, Paint()..blendMode = BlendMode.clear);
        }
      }
      canvas.restore();
    } else {
      canvas
        ..drawRRect(
          card.shift(const Offset(0, 14)),
          Paint()
            ..color = AppColors.shadow
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
        )
        ..drawRRect(card, Paint()..color = AppColors.card)
        ..drawRRect(
          card.deflate(5),
          Paint()
            ..color = AppColors.cardEdge
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10,
        );
      paintArt(canvas, suitArt[suit]!, _pip());
    }
    canvas.restore();
  }

  Rect _pip() => Rect.fromCenter(center: Offset.zero, width: 250, height: 250);

  @override
  bool shouldRepaint(_Mark old) => false;
}

final Map<String, _Mark> _artwork = {
  // iOS and older Android: full bleed, on the felt.
  'app_icon': const _Mark(felt: true),
  // Android adaptive foreground: transparent. flutter_launcher_icons insets
  // it by 16 %, so it is drawn larger to fill the safe zone.
  'app_icon_foreground': const _Mark(scale: 1.2),
  // Android 13 themed icon: one colour, tinted by the system.
  'app_icon_monochrome': const _Mark(mono: true, scale: 1.2),
  // Splash: the cards alone, centred on the felt colour.
  'splash': const _Mark(scale: 0.9),
  // Android 12 splash: shown inside a circle two thirds of its size.
  'splash_android12': const _Mark(scale: 0.7),
};

void main() {
  _artwork.forEach((name, mark) {
    testWidgets(name, (tester) async {
      tester.view
        ..physicalSize = const Size(1024, 1024)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        RepaintBoundary(
          child: CustomPaint(size: const Size(1024, 1024), painter: mark),
        ),
      );
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('../../assets/branding/$name.png'),
      );
    });
  });
}
