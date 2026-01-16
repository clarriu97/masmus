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
  final VoidCallback? onTap;
  final double width;
  final bool isFaceUp;

  double get height => width * 1.5;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, isSelected ? -20 : 0, 0),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: isFaceUp ? _buildFace() : _buildBack(),
      ),
    );
  }

  Widget _buildFace() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${card.faceValue}',
          style: TextStyle(
            fontSize: width * 0.3,
            fontWeight: FontWeight.bold,
            color: _getSuitColor(card.suit),
          ),
        ),
        Icon(
          _getSuitIcon(card.suit),
          size: width * 0.4,
          color: _getSuitColor(card.suit),
        ),
      ],
    );
  }

  Widget _buildBack() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        borderRadius: BorderRadius.circular(8),
        image: const DecorationImage(
          image: AssetImage(
            'assets/images/card_back_pattern.png',
          ), // Placeholder or pattern
          fit: BoxFit.cover,
          opacity: 0.5,
        ),
      ),
      child: Center(
        child: Container(
          width: width * 0.6,
          height: height * 0.6,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Color _getSuitColor(Suit suit) {
    switch (suit) {
      case Suit.oros:
        return Colors.amber.shade800;
      case Suit.copas:
        return Colors.red.shade800;
      case Suit.espadas:
        return Colors.blue.shade800;
      case Suit.bastos:
        return Colors.green.shade800;
    }
  }

  IconData _getSuitIcon(Suit suit) {
    // Using Material icons as placeholders if specific suit assets aren't available yet
    switch (suit) {
      case Suit.oros:
        return Icons.circle; // Coin
      case Suit.copas:
        return Icons.local_bar; // Cup
      case Suit.espadas:
        return Icons.catching_pokemon; // Sword-like?
      case Suit.bastos:
        return Icons.nature; // Club
    }
  }
}
