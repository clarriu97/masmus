import 'dart:math';
import 'card.dart';

class Deck {
  Deck() {
    _initialize();
  }

  final List<MusCard> _cards = [];
  final Random _random = Random();

  void _initialize() {
    _cards.clear();
    for (final suit in Suit.values) {
      // 1-7
      for (var i = 1; i <= 7; i++) {
        _cards.add(MusCard(suit: suit, faceValue: i));
      }
      // 10-12 (Sota, Caballo, Rey)
      for (var i = 10; i <= 12; i++) {
        _cards.add(MusCard(suit: suit, faceValue: i));
      }
    }
  }

  void shuffle() {
    _cards.shuffle(_random);
  }

  /// Robar una carta. Retorna null si no hay cartas.
  MusCard? draw() {
    if (_cards.isEmpty) {
      return null;
    }
    return _cards.removeLast();
  }

  /// Cantidad de cartas restantes
  int get remaining => _cards.length;

  /// Reinicia y baraja
  void reset() {
    _initialize();
    shuffle();
  }
}
