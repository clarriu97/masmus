import 'dart:math';

import 'package:flutter/rendering.dart';

import '../../bots/heuristic_bot.dart';
import '../../game/senas.dart';
import '../theme/app_theme.dart';

/// What a face is doing at one instant: how closed its eyes are, where it
/// looks, whether its mouth is open, and the seña it is making, if any.
final class FacePose {
  const FacePose({
    this.blink = 0,
    this.gaze = Offset.zero,
    this.talking = 0,
    this.sena,
  });

  /// 0 eyes open, 1 shut.
  final double blink;

  /// Where the eyes look, each axis from -1 to 1.
  final Offset gaze;

  /// 0 mouth closed, 1 open as when speaking.
  final double talking;

  final Sena? sena;
}

/// A bot's face, drawn in a 100 × 100 box in the flat inks of the deck:
/// each personality with its own hair and features, and every seña with
/// its gesture as the rulebooks describe it (R-SEN-1).
class FacePainter extends CustomPainter {
  const FacePainter(this.personality, this.pose);

  final Personality personality;
  final FacePose pose;

  static const _ink = AppColors.cardInk;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 100, size.height / 100);
    _shoulders(canvas);
    _backHair(canvas);
    _head(canvas);
    _frontHair(canvas);
    _brows(canvas);
    _eyes(canvas);
    if (personality == Personality.calculador) {
      _glasses(canvas);
    }
    _nose(canvas);
    _mouth(canvas);
    if (personality == Personality.prudente) {
      _mustache(canvas);
    }
    canvas.restore();
  }

  Paint _fill(Color color) => Paint()..color = color;

  Paint _stroke(double width, [Color color = _ink]) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void _shoulders(Canvas canvas) {
    final cloth = switch (personality) {
      Personality.prudente => AppColors.hairBrown,
      Personality.temeraria => AppColors.cardBack,
      Personality.calculador => AppColors.espadas,
      Personality.farolero => AppColors.bastos,
    };
    final body = Path()
      ..moveTo(8, 100)
      ..quadraticBezierTo(10, 82, 34, 80)
      ..lineTo(66, 80)
      ..quadraticBezierTo(90, 82, 92, 100)
      ..close();
    canvas
      ..drawPath(body, _fill(cloth))
      ..drawPath(body, _stroke(2));
    final collar = Path()
      ..moveTo(38, 80)
      ..lineTo(50, 92)
      ..lineTo(62, 80);
    canvas.drawPath(
      collar,
      _stroke(
        2.4,
        personality == Personality.calculador ? AppColors.card : _ink,
      ),
    );
    if (personality == Personality.calculador) {
      final tie = Path()
        ..moveTo(47, 86)
        ..lineTo(53, 86)
        ..lineTo(51, 100)
        ..lineTo(49, 100)
        ..close();
      canvas.drawPath(tie, _fill(AppColors.copas));
    }
  }

  void _nose(Canvas canvas) {
    final nose = Path()
      ..moveTo(50, 54)
      ..quadraticBezierTo(46, 62, 49, 63.5)
      ..quadraticBezierTo(51, 64.5, 53, 63);
    canvas.drawPath(nose, _stroke(1.8, AppColors.skinShade));
  }

  void _head(Canvas canvas) {
    final face = Rect.fromCenter(
      center: const Offset(50, 50),
      width: 60,
      height: 66,
    );
    canvas
      ..drawCircle(const Offset(20, 52), 6, _fill(AppColors.skinShade))
      ..drawCircle(const Offset(80, 52), 6, _fill(AppColors.skinShade))
      ..drawOval(face, _fill(AppColors.skin))
      ..drawOval(face, _stroke(2));
    if (personality == Personality.farolero) {
      final stubble = Path()
        ..moveTo(26, 60)
        ..quadraticBezierTo(50, 98, 74, 60)
        ..quadraticBezierTo(50, 80, 26, 60)
        ..close();
      canvas.drawPath(stubble, _fill(AppColors.skinShade));
    }
    if (personality == Personality.temeraria) {
      canvas
        ..drawCircle(const Offset(20, 61), 2.8, _fill(AppColors.oros))
        ..drawCircle(const Offset(80, 61), 2.8, _fill(AppColors.oros));
    }
  }

  void _backHair(Canvas canvas) {
    if (personality == Personality.temeraria) {
      final bob = Path()
        ..moveTo(16, 62)
        ..quadraticBezierTo(10, 14, 50, 12)
        ..quadraticBezierTo(90, 14, 84, 62)
        ..lineTo(76, 62)
        ..lineTo(76, 40)
        ..lineTo(24, 40)
        ..lineTo(24, 62)
        ..close();
      canvas.drawPath(bob, _fill(AppColors.hairDark));
    }
  }

  void _frontHair(Canvas canvas) {
    switch (personality) {
      case Personality.prudente:
        final boina = Rect.fromCenter(
          center: const Offset(54, 22),
          width: 76,
          height: 22,
        );
        canvas
          ..drawOval(boina, _fill(AppColors.hairDark))
          ..drawLine(const Offset(56, 11), const Offset(58, 5), _stroke(3))
          ..drawLine(
            const Offset(20, 40),
            const Offset(22, 47),
            _stroke(3, AppColors.hairGrey),
          )
          ..drawLine(
            const Offset(80, 40),
            const Offset(78, 47),
            _stroke(3, AppColors.hairGrey),
          );
      case Personality.temeraria:
        final fringe = Path()
          ..moveTo(20, 40)
          ..quadraticBezierTo(30, 16, 62, 22)
          ..quadraticBezierTo(80, 26, 80, 40)
          ..quadraticBezierTo(60, 30, 44, 34)
          ..quadraticBezierTo(30, 36, 20, 40)
          ..close();
        canvas.drawPath(fringe, _fill(AppColors.hairDark));
      case Personality.calculador:
        final parted = Path()
          ..moveTo(19, 44)
          ..quadraticBezierTo(18, 16, 50, 16)
          ..quadraticBezierTo(82, 16, 81, 44)
          ..quadraticBezierTo(76, 28, 60, 26)
          ..lineTo(42, 28)
          ..quadraticBezierTo(26, 30, 19, 44)
          ..close();
        canvas.drawPath(parted, _fill(AppColors.hairBrown));
      case Personality.farolero:
        final slick = Path()
          ..moveTo(19, 42)
          ..quadraticBezierTo(20, 14, 52, 14)
          ..quadraticBezierTo(84, 16, 81, 42)
          ..quadraticBezierTo(70, 22, 40, 28)
          ..quadraticBezierTo(26, 32, 19, 42)
          ..close();
        canvas
          ..drawPath(slick, _fill(AppColors.hairDark))
          ..drawLine(
            const Offset(20, 44),
            const Offset(21, 56),
            _stroke(4, AppColors.hairDark),
          )
          ..drawLine(
            const Offset(80, 44),
            const Offset(79, 56),
            _stroke(4, AppColors.hairDark),
          );
    }
  }

  void _brows(Canvas canvas) {
    final raised = pose.sena == Sena.duples ? 8.0 : 0.0;
    final bold = personality == Personality.temeraria ? 3.4 : 2.6;
    for (final x in [38.0, 62.0]) {
      final y = 38 - raised;
      final brow = Path()
        ..moveTo(x - 7, y + 1.5)
        ..quadraticBezierTo(x, y - 2.5 - raised / 3, x + 7, y + 1.5);
      canvas.drawPath(brow, _stroke(bold));
    }
  }

  void _eyes(Canvas canvas) {
    final sena = pose.sena;
    for (final (i, x) in [38.0, 62.0].indexed) {
      final shut = switch (sena) {
        Sena.ciego => 1.0,
        Sena.treintaYUna || Sena.treinta when i == 1 => 1.0,
        _ => pose.blink,
      };
      final center = Offset(x, 47);
      if (shut > 0.8) {
        final lid = Path()
          ..moveTo(x - 6.5, 47)
          ..quadraticBezierTo(x, 51, x + 6.5, 47);
        canvas.drawPath(lid, _stroke(2.4));
        continue;
      }
      final height = 11 * (1 - shut);
      canvas
        ..drawOval(
          Rect.fromCenter(center: center, width: 13, height: height),
          _fill(AppColors.card),
        )
        ..drawOval(
          Rect.fromCenter(center: center, width: 13, height: height),
          _stroke(1.6),
        );
      final pupil = center + Offset(pose.gaze.dx * 3, pose.gaze.dy * 2.4);
      canvas
        ..save()
        ..clipRect(Rect.fromCenter(center: center, width: 13, height: height))
        ..drawCircle(pupil, 3.4, _fill(_ink))
        ..restore();
    }
  }

  void _glasses(Canvas canvas) {
    final frame = _stroke(2);
    canvas
      ..drawCircle(const Offset(38, 47), 9.5, frame)
      ..drawCircle(const Offset(62, 47), 9.5, frame)
      ..drawLine(const Offset(47.5, 46), const Offset(52.5, 46), frame);
  }

  void _mouth(Canvas canvas) {
    const y = 70.0;
    final sena = pose.sena;
    switch (sena) {
      case Sena.dosReyes:
        canvas
          ..drawLine(
            const Offset(41, y + 2),
            const Offset(59, y + 2),
            _stroke(3.4, AppColors.lip),
          )
          ..drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(44, y - 2, 12, 4.5),
              const Radius.circular(1.2),
            ),
            _fill(AppColors.card),
          )
          ..drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(44, y - 2, 12, 4.5),
              const Radius.circular(1.2),
            ),
            _stroke(1.2),
          );
        return;
      case Sena.mediasReyes || Sena.medias:
        final aside = Path()
          ..moveTo(46, y + 1)
          ..quadraticBezierTo(56, y + 1, 63, y - 5);
        canvas.drawPath(aside, _stroke(3, AppColors.lip));
        return;
      case Sena.dosAses || Sena.mediasAses:
        final side = sena == Sena.mediasAses ? 7.0 : 0.0;
        canvas
          ..drawOval(
            Rect.fromCenter(
              center: Offset(50 + side, y + 3.5),
              width: 8,
              height: 7,
            ),
            _fill(AppColors.tongue),
          )
          ..drawOval(
            Rect.fromCenter(
              center: Offset(50 + side, y + 3.5),
              width: 8,
              height: 7,
            ),
            _stroke(1.2),
          )
          ..drawLine(
            const Offset(42, y),
            const Offset(58, y),
            _stroke(3, AppColors.lip),
          );
        return;
      case Sena.ciego ||
          Sena.duples ||
          Sena.treintaYUna ||
          Sena.treinta ||
          null:
        break;
    }
    final open = pose.talking;
    final smile = personality == Personality.farolero ? 4.0 : 2.0;
    if (open > 0.1) {
      final mouth = Rect.fromCenter(
        center: const Offset(50, y + 1),
        width: 14,
        height: 2 + 8 * open,
      );
      canvas
        ..drawOval(mouth, _fill(AppColors.cardBack))
        ..drawOval(mouth, _stroke(2, AppColors.lip));
      return;
    }
    final line = Path()
      ..moveTo(42, y)
      ..quadraticBezierTo(50, y + smile * 1.5, 58, y - max(0, smile - 2));
    canvas.drawPath(line, _stroke(3, AppColors.lip));
  }

  void _mustache(Canvas canvas) {
    final moustache = Path()
      ..moveTo(38, 67)
      ..quadraticBezierTo(44, 61, 50, 65)
      ..quadraticBezierTo(56, 61, 62, 67)
      ..quadraticBezierTo(50, 69, 38, 67)
      ..close();
    canvas.drawPath(moustache, _fill(AppColors.hairGrey));
  }

  @override
  bool shouldRepaint(FacePainter old) =>
      old.personality != personality ||
      old.pose.blink != pose.blink ||
      old.pose.gaze != pose.gaze ||
      old.pose.talking != pose.talking ||
      old.pose.sena != pose.sena;
}
