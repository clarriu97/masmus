import 'ai_profile.dart';
import 'card.dart';

class Player {
  Player({required this.id, required this.name, this.aiProfile});

  final String id;
  final String name;
  final AiProfile? aiProfile;
  final List<MusCard> hand = [];
  bool isHandPrivate = true; // Si se muestran las cartas o no (para UI local)

  bool get isAi => aiProfile != null;

  void receiveCards(List<MusCard> cards) {
    hand.addAll(cards);
  }

  void clearHand() {
    hand.clear();
  }

  void discard(List<MusCard> cardsToDiscard) {
    for (final card in cardsToDiscard) {
      hand.remove(card);
    }
  }

  @override
  String toString() => 'Player($name, cards: ${hand.length})';
}
