import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/game/models/card.dart';

class PlayingCardWidget extends StatelessWidget {
  const PlayingCardWidget({
    required this.card,
    super.key,
    this.isSelected = false,
    this.onTap,
    this.width = 60,
    this.isFaceUp = true,
  });

  final MusCard card;
  final bool isSelected;
  final void Function(MusCard)? onTap;
  final double width;
  final bool isFaceUp;

  double get height => width * 1.5;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null ? () => onTap!(card) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, isSelected ? -20 : 0, 0),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF0), // Creamy white
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
          border: Border.all(
            color: isSelected ? Colors.blueAccent : const Color(0xFFD4C4A8),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: isFaceUp ? _buildFace() : _buildBack(),
      ),
    );
  }

  Widget _buildFace() {
    return Stack(
      children: [
        // Top Left Number
        Positioned(
          top: 4,
          left: 4,
          child: Text(
            '${card.faceValue}',
            style: TextStyle(
              fontSize: width * 0.25,
              fontWeight: FontWeight.bold,
              color: _getSuitColor(card.suit),
              fontFamily: 'serif',
            ),
          ),
        ),
        // Bottom Right Number (Inverted)
        Positioned(
          bottom: 4,
          right: 4,
          child: Transform.rotate(
            angle: math.pi,
            child: Text(
              '${card.faceValue}',
              style: TextStyle(
                fontSize: width * 0.25,
                fontWeight: FontWeight.bold,
                color: _getSuitColor(card.suit),
                fontFamily: 'serif',
              ),
            ),
          ),
        ),
        // Center Art
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: CustomPaint(
              size: Size(width * 0.6, height * 0.6),
              painter: SpanishSuitPainter(
                suit: card.suit,
                value: card.faceValue,
                color: _getSuitColor(card.suit),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBack() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E6B), // Azul Casino
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C3E6B), Color(0xFF1A2642)],
        ),
      ),
      child: Center(
        child: Container(
          width: width * 0.6,
          height: height * 0.6,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              'M',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: width * 0.4,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getSuitColor(Suit suit) {
    switch (suit) {
      case Suit.oros:
        return const Color(0xFFD4A017); // Gold
      case Suit.copas:
        return const Color(0xFFB83C3C); // Red
      case Suit.espadas:
        return const Color(0xFF3C7FB8); // Blue
      case Suit.bastos:
        return const Color(0xFF4A7C3C); // Green/Brown
    }
  }
}

class SpanishSuitPainter extends CustomPainter {
  SpanishSuitPainter({
    required this.suit,
    required this.value,
    required this.color,
  });

  final Suit suit;
  final int value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Center point
    final cx = size.width / 2;
    final cy = size.height / 2;
    final double r = size.width * 0.4;

    if (suit == Suit.oros) {
      // Draw Coin (Sun-like)
      canvas.drawCircle(Offset(cx, cy), r, paint);
      // Inner ring
      final paintInner = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(cx, cy), r * 0.7, paintInner);
      // Face detail placeholder?
    } else if (suit == Suit.copas) {
      // Draw Cup (Simple triangle/bowl shape)
      final path = Path();
      path.moveTo(cx - r * 0.8, cy - r * 0.5);
      path.quadraticBezierTo(cx, cy + r, cx + r * 0.8, cy - r * 0.5);
      path.lineTo(cx, cy + r * 0.8); // Stem base
      path.close();
      canvas.drawPath(path, paint);
    } else if (suit == Suit.espadas) {
      // Draw Sword
      final path = Path();
      path.moveTo(cx, cy - r); // Tip
      path.quadraticBezierTo(cx + r * 0.3, cy, cx, cy + r); // Blade R
      path.quadraticBezierTo(cx - r * 0.3, cy, cx, cy - r); // Blade L
      canvas.drawPath(path, paint);
      // Hilt
      canvas.drawLine(
        Offset(cx - r * 0.5, cy + r * 0.2),
        Offset(cx + r * 0.5, cy + r * 0.2),
        paint..strokeWidth = 3,
      );
    } else if (suit == Suit.bastos) {
      // Draw Club (Rough shape)
      final path = Path();
      path.moveTo(cx - r * 0.4, cy + r); // Base
      path.quadraticBezierTo(
        cx - r * 0.6,
        cy,
        cx - r * 0.2,
        cy - r,
      ); // Left curve
      path.quadraticBezierTo(cx + r * 0.2, cy - r * 1.2, cx + r * 0.4, cy - r);
      path.quadraticBezierTo(cx + r * 0.6, cy, cx + r * 0.4, cy + r);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
