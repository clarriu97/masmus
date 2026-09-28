import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/bots/bot.dart';
import 'package:masmus/game/event.dart';
import 'package:masmus/game/match.dart';
import 'package:masmus/game/move.dart';

void main() {
  test('R-ORD-5 · a seat sees its own cards, and of the others only how '
      'many they changed', () {
    var match = MatchState.start(seed: 3, mano: 0);
    for (final seat in [0, 1, 2, 3]) {
      match = match.play(seat, const Mus());
    }
    final thrown = match.hand.hands[1].take(2).toList();
    match = match
        .play(0, Discard(match.hand.hands[0].take(1).toList()))
        .play(1, Discard(thrown));
    final view = SeatView.of(match, 0);
    expect(view.cards, match.hand.hands[0]);
    expect(
      view.log.whereType<Discarded>().map((event) => (event.seat, event.count)),
      [(0, 1), (1, 2)],
    );
  });
}
