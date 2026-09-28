import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The green felt everything is played on: lighter where the lamp falls,
/// with the grain of the cloth.
class Felt extends StatelessWidget {
  const Felt({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(0, -0.16),
        radius: 1.1,
        stops: [0, 0.55, 1],
        colors: [AppColors.feltLight, AppColors.felt, AppColors.feltDark],
      ),
    ),
    child: Stack(
      children: [
        const Positioned.fill(
          child: RepaintBoundary(child: CustomPaint(painter: _Grain())),
        ),
        child,
      ],
    ),
  );
}

class _Grain extends CustomPainter {
  const _Grain();

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(7);
    final count = (size.width * size.height / 28).round();
    Offset dot() => Offset(
      random.nextDouble() * size.width,
      random.nextDouble() * size.height,
    );
    for (final color in [AppColors.grainLight, AppColors.grainDark]) {
      canvas.drawPoints(
        PointMode.points,
        [for (var i = 0; i < count ~/ 2; i++) dot()],
        Paint()
          ..color = color
          ..strokeWidth = 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(_Grain oldDelegate) => false;
}
