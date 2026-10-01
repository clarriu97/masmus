import 'package:flutter/material.dart';

import '../../bots/heuristic_bot.dart';
import '../theme/app_theme.dart';
import 'face_painter.dart';

/// A bot's face at rest, in its round frame: for lists and pickers.
class Face extends StatelessWidget {
  const Face(this.personality, {this.size = 44, super.key});

  final Personality personality;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: ClipOval(
      child: ColoredBox(
        color: AppColors.avatar,
        child: CustomPaint(
          size: Size.square(size),
          painter: FacePainter(personality, const FacePose()),
        ),
      ),
    ),
  );
}
